// Generated by CoffeeScript 1.3.3
var ad, do_posting, get_next_ad, max_price, next_step, steps, zip;

get_next_ad = toggler(["Free MLS Report for San Tan Valley 85140", "Homes for sale in Queen Creek 85142", "Get a list of homes for sale in Mesa 85212", "Search MLS Data for Gilbert 85298", "Listings in Gilbert 85297", "Custom Search Homes in Gilbert 85295", "Active real estate listings in Gilbert 85296", "Beautiful Gilbert Homes in Gilbert 85234", "Available Homes in Mesa 85209", "Up-to-date Real Estate listings 85206", "Mesa Homes on the Market in Mesa 85208", "Mesa Single Family Homes in 85207", "Apache Junction Homes in 85120", "Mesa Homes Located in 85213", "View Pictures of homes for sale in Mesa 85201", "Available Real Estate in Mesa 85210", "Homes located in zip 85233 (Gilbert) For Sale", "Find your next home! Free Search in Mesa 85204"]);

ad = "";

zip = "";

max_price = "";

steps = [];

do_posting = function() {
  steps = [search_for_next_ad, wait_til_ad_finishes_loading, get_listing_details, download_image, create_tab, cl_home, go_to_posting, wait_for_redirect, check_housing_offered, check_real_estate_by_broker, check_east_valley, fill_posting, agree_to_map, close_cl_tab, do_next_posting];
  return next_step();
};

next_step = function() {
  var step;
  step = steps.shift();
  return typeof step === "function" ? step() : void 0;
};

chrome.browserAction.onClicked.addListener(function(tab) {
  return do_posting();
});
