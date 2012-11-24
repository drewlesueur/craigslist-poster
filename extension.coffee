ads = [
  # "Get a list of homes for sale in Mesa 85212"
  # "Custom Search Homes in Gilbert 85295"
  # "Beautiful Gilbert Homes in Gilbert 85234"
  "Free MLS Report for San Tan Valley 85140"
  "Homes for sale in Queen Creek 85142"
  "Search MLS Data for Gilbert 85298"
  "Listings in Gilbert 85297"
  "Active real estate listings in Gilbert 85296"
  "Available Homes in Mesa 85209"
  "Up-to-date Real Estate listings 85206"
  "Mesa Homes on the Market in Mesa 85208"
  "Mesa Single Family Homes in 85207"
  "Apache Junction Homes in 85120"
  "Mesa Homes Located in 85213"
  "View Pictures of homes for sale in Mesa 85201"
  "Available Real Estate in Mesa 85210"
  "Homes located in zip 85233 (Gilbert) For Sale"
  "Find your next home! Free Search in Mesa 85204"
]


posting_steps = [
  select_homeseekr_tab
  homeseekr_home
  wait_til_ad_finishes_loading
  search_for_next_ad 
  wait_til_ad_finishes_loading
  get_listing_details
  # download_image
  select_craigslist_tab
  cragslist_home
  go_to_posting
  # wait_for_redirect
  check_housing_offered
  check_real_estate_by_broker
  check_east_valley
  fill_posting
  agree_to_map
  # upload_image # this works
  done_images
  click_continue
  do_next_posting
]

chrome.browserAction.onClicked.addListener (tab) ->
  #chrome.tabs.captureVisibleTab null, null, (data_url) ->
  #  window.open data_url

  make_2_new_tabs start_posting
  

