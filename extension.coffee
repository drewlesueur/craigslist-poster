zips = [
  "85015"
  "85048"
  "85044"
  "85258"
  "85253"
  "85250"
  "85018"
  "85251"
  "85008"
  "85257"
  "85281"
  "85282"
  "85283"
  "85284"
  "85226"
  "85256"
  "85201"
  "85210"
  "85202"
  "85224"
  "85248"
  "85203"
  "85213"
  "85204"
  "85233"
  "85225"
  "85286"
  "85249"
  "85205"
  "85206"
  "85234"
  "85296"
  "85295"
  "85297"
  "85298"
  "85207"
  "85215"
  "85120"
  "85208"
  "85209"
  "85212"
  "85142"
  "85119"
  "85140"
  "85143"
  "85138"
  "85139"
  "85193"
  "85122"
  "85194"
  "85128"
]

max_prices = [
  100
  110
  120
  130
  140
  150
  160
  170
  180
  190
  200
  210
  220
  230
  240
  250
]

posting_steps = [
  select_homeseekr_tab
  homeseekr_home
  wait_til_ad_finishes_loading
  search_for_next_ad 
  wait_til_ad_finishes_loading
  get_listing_details
  #### download_image
  select_craigslist_tab
  cragslist_home
  go_to_posting
  #### wait_for_redirect
  check_housing_offered
  check_real_estate_by_broker
  check_east_valley
  fill_posting
  agree_to_map
  #### upload_image # this works
  done_images
  click_continue
  do_next_posting
]

chrome.browserAction.onClicked.addListener (tab) ->
  #chrome.tabs.captureVisibleTab null, null, (data_url) ->
  #  window.open data_url

  make_2_new_tabs start_posting
  

