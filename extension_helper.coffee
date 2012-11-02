toggler = (list) ->
  togglerIndex = 0
  ->
    ret = list[togglerIndex]
    togglerIndex += 1
    if togglerIndex == list.length
      togglerIndex = 0
    ret

callbacker = (fn) ->
  (args...) ->
    (cb) ->
      fn args..., cb
    
ids = {} 

do_next_posting = ->
  setTimeout do_posting, 1000

exec = (fn, args..., cb=->) ->
  code = ";(" + fn.toString() + ").apply(null, #{JSON.stringify(args)});"
  console.log code
  # nav "javascript:" + (code) + ";void(0);", cb

  # this lives in isolated world if I do it like this, with only access to dom.
  # https://developer.chrome.com/extensions/content_scripts.html#execution-environment
  chrome.tabs.executeScript null,
    file: "jquery.js"
  , () ->
    chrome.tabs.executeScript null, 
      code: code
      runAt: 'document_end'
    , (results) ->
      cb null, results

  

chrome.tabs.onUpdated.addListener (tab_id, change_info) -> 
  if tab_id of ids
    console.log tab_id, change_info
    if change_info.status == "complete"
      setTimeout next_step, _.random(1000,3000)

create_tab = () ->
  chrome.tabs.create {url: "about:blank"}, (tab) ->
    next_step()
  
nav = (url, cb) -> 
  chrome.tabs.update
    url: url
  , (tab) ->
    ids[tab.id] = tab
    cb? null, tab

new_posting = () ->

cl_home = () ->
  console.log "cl home"
  nav "http://phoenix.craigslist.org/"

go_to_posting = () ->
  console.log "cl posting"
  nav "https://post.craigslist.org/c/phx?lang=en"

wait_for_redirect = ->
  console.log "wait for redirect"
  # will hit this one as it redirects

check_housing_offered = ->
  console.log "clicking housing offered"
  exec ->
    $('[name="id"][value="ho"]').prop 'checked', true
    $('form').submit()

check_real_estate_by_broker = ->
  console.log "clicking housing offered"
  exec ->
    $('[name="id"][value="144"]').prop 'checked', true
    $('form').submit()

check_east_valley = ->
  exec ->
    $("label:contains(east valley)").find("input").prop 'checked', true
    $('form').submit()

fill_posting = ->
  exec (details) ->
    $("span:contains(Price:)").nextAll('input').val(details.ListPrice)
    $("span:contains(# BR:)").nextAll('select').val(details.BedsTotal)
    $("span:contains(Posting Title:)").nextAll('input').val(ad)
    $("span:contains(SqFt)").nextAll('input').val(details.BuildingAreaTotal)
    $("span:contains(Posting Description:)").nextAll('textarea').val """
      <img src="http://homeseekr.com/cached_image/image?zip=#{zip}&max_price=#{max_price}&page=1">
      #{details.PublicRemarks}
    """

    $("span:contains(Specific Location:)").nextAll('input').val(details.UnparsedAddress)
    $("span:contains(Street:)").nextAll('input').first().val("#{details.StreetNumber} #{details.StreetDirPrefix} #{details.StreetName}")
    $("span:contains(City:)").nextAll('input').first().val(details.City)
    $("#region").val(details.StateOrProvince)
    $("#postal_code").val(details.PostalCode)
    $('form').submit()
  , details, ->

ad = ""
zip = ""

search_for_next_ad = ->
  ad = get_next_ad()
  console.log "ad is", ad
  zip = ad.match(/\d{5}/)[0]
  console.log "zip"
  max_price = 200000
  exec (max_price, zip) ->
    console.log zip
    $('[name="zip"]').val zip
    $('[name="max_price"]').val max_price
    $('form').submit()
  , max_price, zip, ->

wait_til_ad_finishes_loading = ->
  # todo make it smarter
  setTimeout next_step, 7000

listing = {}
details = {}
get_listing_details = ->
  exec ->
    $(".listing").first().find("script").html()
  , (err, json) ->
    listing = JSON.parse(json[0])
    details = listing.StandardFields
    console.log "json is", details
    next_step()

close_cl_tab = ->
  crome.tabs.remove()

agree_to_map = () ->
  exec ->
    $(".continue").click()

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
      next_step()

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
    next_step()

done_images = ->
  console.log "done images"
  exec ->
    $("form").eq(1).submit() 

click_continue = ->
  exec ->
    $("button:contains(Continue)").click() 
