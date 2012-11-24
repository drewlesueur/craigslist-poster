get_next_ad = null
next_step = null

nexter = (list) ->
  togglerIndex = 0
  ->
    ret = list[togglerIndex]
    togglerIndex += 1
    ret

debug = false
debug_on = -> debug = true
debug_off = -> debug = false


stepper = (steps) ->
  steps = _.clone steps
  (message) ->
    step = steps.shift()
    console.log "calling next step: #{message}"
    step?()

setup_ad_cycle = -> get_next_ad = nexter ads

start_posting = ->
  setup_ad_cycle()
  do_posting()

do_posting = () ->
  next_step = stepper posting_steps
  next_step("do posting")

two_hours = 7200000
fifteen_min = 900000 

give_or_take_15 = ->
  _.random -fifteen_min, fifteen_min

two_minutes = 120000

do_next_posting = ->
  wait two_hours + give_or_take_15(), ->
  # wait two_minutes, ->
    do_posting()
  
wait_for = (condition, args, callback) ->
  timeout = 20000
  poll_time = 300
  time = Date.now() 
  try_it = ->
    console.log "testing..."
    if Date.now() - time >= timeout
      console.log "error. Time expired"
      return callback('time expired')

    exec_with_args condition, args, (err, results) ->
      console.log console.log JSON.stringify results
      
      if results[0]
        console.log "pass"
        callback(null, results[0])
      else
        console.log "fail"
        wait poll_time, try_it
        console.log "going to try again"
  try_it()
    

callbacker = (fn) ->
  (args...) ->
    (cb) ->
      fn args..., cb
    
ids = {} 

wait = (time, func) -> setTimeout func, time


exec = (fn, args..., cb=->) ->
  exec_with_args fn, args, cb

exec_with_args = (fn, args, cb=->) ->
  code = ";(" + fn.toString() + ").apply(null, #{JSON.stringify(args)});"
  # nav "javascript:" + (code) + ";void(0);", cb

  # this lives in isolated world if i do it like this, with only access to dom.
  # https://developer.chrome.com/extensions/content_scripts.html#execution-environment
  chrome.tabs.executeScript null,
    file: "jquery.js"
  , () ->
    chrome.tabs.executeScript null, 
      code: code
      runAt: 'document_end'
    , (results) ->
      cb null, results

  
waiting_for_nav = false
wait_for_nav = ->
  waiting_for_nav = true

chrome.tabs.onUpdated.addListener (tab_id, change_info) -> 
  if tab_id of ids
    if change_info.status == "complete" and waiting_for_nav
      setTimeout (-> next_step("tab complete")), _.random(1000,3000)
      waiting_for_nav = false


create_tab = (cb) ->
  chrome.tabs.create {url: "about:blank"}, (tab) -> 
    cb null, tab

homeseekr_tab = null
craigslist_tab = null

create_homeseekr_tab = (cb) ->
  create_tab (err, tab) ->
    homeseekr_tab = tab
    cb()

create_craigslist_tab = (cb) ->
  create_tab (err, tab) ->
    craigslist_tab = tab
    cb()

select_homeseekr_tab = () ->
  console.log "select home seekr tab"
  chrome.tabs.update homeseekr_tab.id, {selected: true}, (-> next_step("select homeseeker tab"))

select_craigslist_tab = () ->
  console.log "select craigslist"
  chrome.tabs.update craigslist_tab.id, {selected: true}, (-> next_step("select craigslist tab"))

make_2_new_tabs = (cb) ->
  async.series [
    create_homeseekr_tab 
    create_craigslist_tab 
  ], cb

  
nav = (url, cb) -> 
  chrome.tabs.update
    url: url
  , (tab) ->
    wait_for_nav()
    ids[tab.id] = tab
    cb? null, tab

new_posting = () ->

cragslist_home = () ->
  console.log "cl home"
  nav "http://phoenix.craigslist.org/"

homeseekr_home = () ->
  console.log "homeseekr home"
  nav "http://homeseekr.com"

go_to_posting = () ->
  console.log "cl posting"
  nav "https://post.craigslist.org/c/phx?lang=en"

wait_for_redirect = ->
  console.log "wait for redirect"
  wait_for_nav()
  # will hit this one as it redirects

check_housing_offered = ->
  console.log "clicking housing offered"
  exec ->
    $('[name="id"][value="ho"]').prop 'checked', true
    $('form').submit()
  , -> wait_for_nav()

check_real_estate_by_broker = ->
  console.log "clicking housing offered"
  exec ->
    $('[name="id"][value="144"]').prop 'checked', true
    $('form').submit()
  , -> wait_for_nav()

check_east_valley = ->
  exec ->
    $("label:contains(east valley)").find("input").prop 'checked', true
    $('form').submit()
  , -> wait_for_nav()

fill_posting = ->
  exec (details, ad, zip, max_price) ->
    $("span:contains(Price:)").nextAll('input').val(details.ListPrice)
    $("span:contains(# BR:)").nextAll('select').val(details.BedsTotal)
    $("span:contains(Posting Title:)").nextAll('input').val(ad)
    $("span:contains(SqFt)").nextAll('input').val(details.BuildingAreaTotal)
    $("span:contains(Posting Description:)").nextAll('textarea').val """
      <a href="http://homeseekr.com/##{zip}/#{max_price}/1"><img src="http://homeseekr.com:8502/cached_image?zip=#{zip}&max_price=#{max_price}&page=1"></a>
      #{details.PublicRemarks}
    """

    $("span:contains(Specific Location:)").nextAll('input').val(details.UnparsedAddress)
    $("span:contains(Street:)").nextAll('input').first().val("#{details.StreetNumber} #{details.StreetDirPrefix} #{details.StreetName}")
    $("span:contains(City:)").nextAll('input').first().val(details.City)
    $("#region").val(details.StateOrProvince)
    $("#postal_code").val(details.PostalCode)
    $('form').submit()
  , details, ad, zip, max_price, -> wait_for_nav()

ad = ""
zip = ""
max_price = ""

search_for_next_ad = ->
  console.log "search for next ad"
  ad = get_next_ad()
  console.log "ad is", ad
  zip = ad.match(/\d{5}/)[0]
  console.log "zip"
  max_price = 200000
  exec (max_price, zip) -> 
    window.location = "##{zip}/#{max_price}/1"
  , max_price, zip, ->
    next_step("search for next ad")




wait_til_ad_finishes_loading = ->
  console.log "waiting til add finishes loading"
  wait_for ->
    return $(".listing").length
  , [], (err)-> next_step("wait til ad finishes loading")

listing = {}
details = {}
get_listing_details = ->
  console.log "getting listing details!"
  exec ->
    $(".listing").first().find("script").html()
  , (err, json) ->
    listing = JSON.parse(json[0])
    details = listing.StandardFields
    console.log "json is", details
    next_step("get listing details")

agree_to_map = () ->
  exec ->
    # 40975 N Arbor San Tan Valley, AZ 85140
    # $(".continue").click()
    $(".skipmap").click()
  , -> wait_for_nav()

data_url = ""
download_image = () ->
  chrome.tabs.captureVisibleTab null, null, (_data_url) ->
    data_url = _data_url
    exec (data_url, id) ->
      $(document.body).append """
        <a id="download-image" href="#{data_url}" download="#{id}.jpg">download image</a>
      """
      $("#download-image")[0].click()
    , data_url, listing.Id, ->
      next_step("download image")

upload_image = ->
  console.log "upload image"
  exec (data_url) ->
    `
    function dataURItoBlob(dataURI) {
        var binary = atob(dataURI.split(',')[1]);
        var array = [];
        for(var i = 0; i < binary.length; i++) {
            array.push(binary.charCodeAt(i));
        }
        return new Blob([new Uint8Array(array)], {type: 'image/jpeg'});
    }

    `  
    b = dataURItoBlob(data_url)
    r = new XMLHttpRequest()
    form = $('form').eq(0)
    url = form.attr("action")
    form.find('[name="file"]').remove()
    f = new FormData(form[0])
    f.append("file", b)
    r.open("POST", url)
    r.send(f)
    r.onload = (e) ->
      if r.status == 200
        chrome.extension.sendMessage({method: "next_step"})

  , data_url, ->

chrome.extension.onMessage.addListener (req, sender, send_res) ->
  console.log "message"
  if req.method == "next_step"
    next_step("listener")

done_images = ->
  console.log "done images"
  exec ->
    $("form").eq(1).submit() 
  , -> wait_for_nav()

click_continue = ->
  exec ->
    $("button:contains(Continue)").click() 
  , -> wait_for_nav()
