#!/bin/bash -x
date
cd /home/developers/botgarden
HOST=$1
##############################################################################
# extract metadata (dead and alive) info from CSpace
##############################################################################
time psql  -F $'\t' -R"@@" -A -U reporter -d "host=$HOST.cspace.berkeley.edu dbname=nuxeo password=xxxpasswordxxx" -f botgardenMetadataV1alive.sql -o d1a.csv
time psql  -F $'\t' -R"@@" -A -U reporter -d "host=$HOST.cspace.berkeley.edu dbname=nuxeo password=xxxpasswordxxx" -f botgardenMetadataV1dead.sql -o d1b.csv
# some fix up required, alas: data from cspace is dirty: contain csv delimiters, newlines, etc. that's why we used @@ as temporary record separator
time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' d1b.csv > d2.csv
time perl -pe 's/[\r\n]/ /g;s/\@\@/\n/g' d1a.csv >> d2.csv
time perl -ne 'print unless /\(\d+ rows\)/' d2.csv > d3.csv
time perl -ne '$x = $_ ;s/[^\t]//g; if (length eq 32) { print $x;} '     d3.csv > d4.csv
time perl -ne '$x = $_ ;s/[^\t]//g; unless (length eq 32) { print $x;} ' d3.csv > errors.csv &
##############################################################################
# temporary hack to parse Locality into County/State/Country
##############################################################################
perl fixLocalites.pl d4.csv > metadata.csv
cut -f10 metadata.csv | perl -pe 's/\|/\n/g;' | sort | uniq -c | perl -pe 's/^ *(\d+) /\1\t/' > county.csv
cut -f11 metadata.csv | perl -pe 's/\|/\n/g;' | sort | uniq -c | perl -pe 's/^ *(\d+) /\1\t/' > state.csv
cut -f12 metadata.csv | perl -pe 's/\|/\n/g;' | sort | uniq -c | perl -pe 's/^ *(\d+) /\1\t/' > country.csv
rm d3.csv
##############################################################################
# we want to recover and use our "special" solr-friendly header, which got buried
##############################################################################
grep csid metadata.csv | head -1 > header4Solr.csv
grep -v csid metadata.csv > d7.csv
cat header4Solr.csv d7.csv | perl -pe 's/␥/|/g' > 4solr.$HOST.metadata.csv
##############################################################################
# here are the schema changes needed: copy all the _s and _ss to _txt, and vv.
##############################################################################
perl -pe 's/\t/\n/g' header4Solr.csv| perl -ne 'chomp; next unless /_txt/; s/_txt$//; print "    <copyField source=\"" .$_."_txt\" dest=\"".$_."_s\"/>\n"' > schemaFragment.xml
perl -pe 's/\t/\n/g' header4Solr.csv| perl -ne 'chomp; next unless /_s$/; s/_s$//; print "    <copyField source=\"" .$_."_s\" dest=\"".$_."_txt\"/>\n"' >> schemaFragment.xml
perl -pe 's/\t/\n/g' header4Solr.csv| perl -ne 'chomp; next unless /_ss$/; s/_ss$//; print "    <copyField source=\"" .$_."_ss\" dest=\"".$_."_txt\"/>\n"' >> schemaFragment.xml
##############################################################################
# here are the solr csv update parameters needed for multivalued fields
##############################################################################
perl -pe 's/\t/\n/g' header4Solr.csv| perl -ne 'chomp; next unless /_ss/; next if /blob/; print "f.$_.split=true&f.$_.separator=%7C&"' > uploadparms.txt

rm d7.csv
wc -l *.csv
#
curl "http://localhost:8983/solr/${HOST}-metadata/update" --data '<delete><query>*:*</query></delete>' -H 'Content-type:text/xml; charset=utf-8'  
curl "http://localhost:8983/solr/${HOST}-metadata/update" --data '<commit/>' -H 'Content-type:text/xml; charset=utf-8'
time curl "http://localhost:8983/solr/${HOST}-metadata/update/csv?commit=true&header=true&trim=true&separator=%09&f.collcounty_ss.split=true&f.collcounty_ss.separator=%7C&f.collstate_ss.split=true&f.collstate_ss.separator=%7C&f.collcountry_ss.split=true&f.collcountry_ss.separator=%7C&f.blobs_ss.split=true&f.blobs_ss.separator=,&encapsulator=\\" --data-binary @4solr.$HOST.metadata.csv -H 'Content-type:text/plain; charset=utf-8'
date
