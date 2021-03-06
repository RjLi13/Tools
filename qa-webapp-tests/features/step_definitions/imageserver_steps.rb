Then(/^I will click Grid and see a page of images\.$/) do
    check('pixonly')
    click_button("Grid")
end

Then(/^I will click an image with id "(.*?)" and observe url contains imageserver$/) do |id|
    visit 'https://webapps' + env_config['server'] +'.cspace.berkeley.edu/' + $ginstitution + '/imageserver/blobs/' + id
    expect(current_url).to have_content('https://webapps' + env_config['server'] + '.cspace.berkeley.edu/' + $ginstitution + '/imageserver/')
    screenshot_and_open_image
end

Then(/^I will navigate to a bad id "(.*?)" and observe the 'image not available' jpg$/) do |id| 
    visit 'https://webapps' + env_config['server'] +'.cspace.berkeley.edu/' + $ginstitution + "/imageserver/blobs/" + id + "13"
    screenshot_and_open_image
end