When(/^I search for "([^"]*)" and enter "([^"]*)"$/) do |query1, query2|
    fill_in "text", :with => query1
    fill_in "maxresults", :with => query2
    click_button "Search"
end

Then(/^I see "([^"]*)" images displayed$/) do |img|
    page.has_content?(img.to_s + " images displayed for 20 objects")
end

When(/^I click on museum number "([^"]*)"$/) do |arg1|
    #click_link(arg1) does not work due to another page opening
    visit 'https://webapps' + env_config['server'] + '.cspace.berkeley.edu/' + $ginstitution + '/search/search/?displayType=full&maxresults=1&resultsOnly=True&text=%22'+ arg1.to_s + '%22'
end

Then(/^I see a page with these headers "([^"]*)"$/) do |headers|
    headers.split(', ').each do |header|
        page.has_content?(header)
    end
end

Then(/^I see a table with (\d+) headers "([^"]*)" and (\d+) cols "([^"]*)"$/) do |numHeaders, headers, numCols, cols|
    for header in headers.split(', ')
        find('tr', text: header).should have_content(header)
    end 
    for col in cols.split(', ')
        all('tr', text: col, :between => 3..10)[0].should have_content(col)
    end 
end