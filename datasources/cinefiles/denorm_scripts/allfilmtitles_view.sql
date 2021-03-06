-- allfilmtitles_view table used in CineFiles denorm
--
-- CRH 2/23/2014
--
-- this script creates a temporary table, which will be renamed
-- after all of the denorm tables have been successfully created.
--
-- Modified GLJ 8/3/2014

DROP TABLE IF EXISTS cinefiles_denorm.allfilmtitles_viewtmp;

CREATE TABLE cinefiles_denorm.allfilmtitles_viewtmp AS
   SELECT
      -- h1.name filmCSID,
      wc.shortidentifier film_id,
      wtg.termdisplayname title
   FROM
      hierarchy h1
      INNER JOIN works_common wc
         ON ( h1.id = wc.id AND h1.primarytype = 'WorkitemTenant50' )
      INNER JOIN misc m
         ON ( wc.id = m.id AND m.lifecyclestate <> 'deleted' )
      LEFT OUTER JOIN hierarchy h3
         ON ( h3.parentid = h1.id AND h3.primarytype = 'workTermGroup')
      LEFT OUTER JOIN worktermgroup wtg
         ON ( h3.id = wtg.id)
   ORDER BY wc.shortidentifier, h3.pos;

GRANT SELECT ON cinefiles_denorm.allfilmtitles_viewtmp TO GROUP reporters;
GRANT SELECT ON cinefiles_denorm.allfilmtitles_viewtmp TO GROUP cinereaders;

SELECT COUNT(1) FROM cinefiles_denorm.allfilmtitles_view;
SELECT COUNT(1) FROM cinefiles_denorm.allfilmtitles_viewtmp;

