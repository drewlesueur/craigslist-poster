// Generated by CoffeeScript 1.3.3
var ad, agree_to_map, callbacker, check_east_valley, check_housing_offered, check_real_estate_by_broker, click_continue, cragslist_home, craigslist_tab, create_craigslist_tab, create_homeseekr_tab, create_tab, data_url, debug, debug_off, debug_on, details, do_next_posting, do_posting, done_images, download_image, exec, exec_with_args, fill_posting, get_listing_details, get_next_ad, go_to_posting, homeseekr_home, homeseekr_tab, ids, listing, make_2_new_tabs, nav, new_posting, next_step, search_for_next_ad, select_craigslist_tab, select_homeseekr_tab, setup_ad_cycle, start_posting, stepper, toggler, upload_image, wait, wait_for, wait_for_nav, wait_for_redirect, wait_til_ad_finishes_loading, waiting_for_nav, zip,
  __slice = [].slice;

get_next_ad = null;

next_step = null;

toggler = function(list) {
  var togglerIndex;
  togglerIndex = 0;
  return function() {
    var ret;
    ret = list[togglerIndex];
    togglerIndex += 1;
    if (togglerIndex === list.length) {
      togglerIndex = 0;
    }
    return ret;
  };
};

debug = false;

debug_on = function() {
  return debug = true;
};

debug_off = function() {
  return debug = false;
};

stepper = function(steps) {
  steps = _.clone(steps);
  return function(message) {
    var step;
    step = steps.shift();
    console.log("calling next step: " + message);
    return typeof step === "function" ? step() : void 0;
  };
};

setup_ad_cycle = function() {
  return get_next_ad = toggler(ads);
};

start_posting = function() {
  setup_ad_cycle();
  return do_posting();
};

do_posting = function() {
  next_step = stepper(posting_steps);
  return next_step("do posting");
};

do_next_posting = function() {
  return wait(1000, function() {
    return do_posting();
  });
};

wait_for = function(condition, args, callback) {
  var poll_time, time, timeout, try_it;
  timeout = 20000;
  poll_time = 300;
  time = Date.now();
  try_it = function() {
    console.log("testing...");
    if (Date.now() - time >= timeout) {
      console.log("error. Time expired");
      return callback('time expired');
    }
    return exec_with_args(condition, args, function(err, results) {
      console.log(console.log(JSON.stringify(results)));
      if (results[0]) {
        console.log("pass");
        return callback(null, results[0]);
      } else {
        console.log("fail");
        wait(poll_time, try_it);
        return console.log("going to try again");
      }
    });
  };
  return try_it();
};

callbacker = function(fn) {
  return function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return function(cb) {
      return fn.apply(null, __slice.call(args).concat([cb]));
    };
  };
};

ids = {};

wait = function(time, func) {
  return setTimeout(func, time);
};

exec = function() {
  var args, cb, fn, _i;
  fn = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), cb = arguments[_i++];
  if (cb == null) {
    cb = function() {};
  }
  return exec_with_args(fn, args, cb);
};

exec_with_args = function(fn, args, cb) {
  var code;
  if (cb == null) {
    cb = function() {};
  }
  code = ";(" + fn.toString() + (").apply(null, " + (JSON.stringify(args)) + ");");
  return chrome.tabs.executeScript(null, {
    file: "jquery.js"
  }, function() {
    return chrome.tabs.executeScript(null, {
      code: code,
      runAt: 'document_end'
    }, function(results) {
      return cb(null, results);
    });
  });
};

waiting_for_nav = false;

wait_for_nav = function() {
  return waiting_for_nav = true;
};

chrome.tabs.onUpdated.addListener(function(tab_id, change_info) {
  if (tab_id in ids) {
    if (change_info.status === "complete" && waiting_for_nav) {
      setTimeout((function() {
        return next_step("tab complete");
      }), _.random(1000, 3000));
      return waiting_for_nav = false;
    }
  }
});

create_tab = function(cb) {
  return chrome.tabs.create({
    url: "about:blank"
  }, function(tab) {
    return cb(null, tab);
  });
};

homeseekr_tab = null;

craigslist_tab = null;

create_homeseekr_tab = function(cb) {
  return create_tab(function(err, tab) {
    homeseekr_tab = tab;
    return cb();
  });
};

create_craigslist_tab = function(cb) {
  return create_tab(function(err, tab) {
    craigslist_tab = tab;
    return cb();
  });
};

select_homeseekr_tab = function() {
  console.log("select home seekr tab");
  return chrome.tabs.update(homeseekr_tab.id, {
    selected: true
  }, (function() {
    return next_step("select homeseeker tab");
  }));
};

select_craigslist_tab = function() {
  console.log("select craigslist");
  return chrome.tabs.update(craigslist_tab.id, {
    selected: true
  }, (function() {
    return next_step("select craigslist tab");
  }));
};

make_2_new_tabs = function(cb) {
  return async.series([create_homeseekr_tab, create_craigslist_tab], cb);
};

nav = function(url, cb) {
  return chrome.tabs.update({
    url: url
  }, function(tab) {
    wait_for_nav();
    ids[tab.id] = tab;
    return typeof cb === "function" ? cb(null, tab) : void 0;
  });
};

new_posting = function() {};

cragslist_home = function() {
  console.log("cl home");
  return nav("http://phoenix.craigslist.org/");
};

homeseekr_home = function() {
  console.log("homeseekr home");
  return nav("http://homeseekr.com");
};

go_to_posting = function() {
  console.log("cl posting");
  return nav("https://post.craigslist.org/c/phx?lang=en");
};

wait_for_redirect = function() {
  console.log("wait for redirect");
  return wait_for_nav();
};

check_housing_offered = function() {
  console.log("clicking housing offered");
  return exec(function() {
    $('[name="id"][value="ho"]').prop('checked', true);
    return $('form').submit();
  }, function() {
    return wait_for_nav();
  });
};

check_real_estate_by_broker = function() {
  console.log("clicking housing offered");
  return exec(function() {
    $('[name="id"][value="144"]').prop('checked', true);
    return $('form').submit();
  }, function() {
    return wait_for_nav();
  });
};

check_east_valley = function() {
  return exec(function() {
    $("label:contains(east valley)").find("input").prop('checked', true);
    return $('form').submit();
  }, function() {
    return wait_for_nav();
  });
};

fill_posting = function() {
  return exec(function(details, ad, zip, max_price) {
    $("span:contains(Price:)").nextAll('input').val(details.ListPrice);
    $("span:contains(# BR:)").nextAll('select').val(details.BedsTotal);
    $("span:contains(Posting Title:)").nextAll('input').val(ad);
    $("span:contains(SqFt)").nextAll('input').val(details.BuildingAreaTotal);
    $("span:contains(Posting Description:)").nextAll('textarea').val("<img src=\"http://homeseekr.com/cached_image/image?zip=" + zip + "&max_price=" + max_price + "&page=1\">\n" + details.PublicRemarks);
    $("span:contains(Specific Location:)").nextAll('input').val(details.UnparsedAddress);
    $("span:contains(Street:)").nextAll('input').first().val("" + details.StreetNumber + " " + details.StreetDirPrefix + " " + details.StreetName);
    $("span:contains(City:)").nextAll('input').first().val(details.City);
    $("#region").val(details.StateOrProvince);
    $("#postal_code").val(details.PostalCode);
    return $('form').submit();
  }, details, ad, zip, max_price, function() {
    return wait_for_nav();
  });
};

ad = "";

zip = "";

search_for_next_ad = function() {
  var max_price;
  console.log("search for next ad");
  ad = get_next_ad();
  console.log("ad is", ad);
  zip = ad.match(/\d{5}/)[0];
  console.log("zip");
  max_price = 200000;
  return exec(function(max_price, zip) {
    return window.location = "#" + zip + "/" + max_price + "/1";
  }, max_price, zip, function() {
    return next_step("search for next ad");
  });
};

wait_til_ad_finishes_loading = function() {
  console.log("waiting til add finishes loading");
  return wait_for(function() {
    return $(".listing").length;
  }, [], function(err) {
    return next_step("wait til ad finishes loading");
  });
};

listing = {};

details = {};

get_listing_details = function() {
  console.log("getting listing details!");
  return exec(function() {
    return $(".listing").first().find("script").html();
  }, function(err, json) {
    listing = JSON.parse(json[0]);
    details = listing.StandardFields;
    console.log("json is", details);
    return next_step("get listing details");
  });
};

agree_to_map = function() {
  return exec(function() {
    return $(".skipmap").click();
  }, function() {
    return wait_for_nav();
  });
};

data_url = "";

download_image = function() {
  return chrome.tabs.captureVisibleTab(null, null, function(_data_url) {
    data_url = _data_url;
    return exec(function(data_url, id) {
      $(document.body).append("<a id=\"download-image\" href=\"" + data_url + "\" download=\"" + id + ".jpg\">download image</a>");
      return $("#download-image")[0].click();
    }, data_url, listing.Id, function() {
      return next_step("download image");
    });
  });
};

upload_image = function() {
  console.log("upload image");
  return exec(function(data_url) {
    
    function dataURItoBlob(dataURI) {
        var binary = atob(dataURI.split(',')[1]);
        var array = [];
        for(var i = 0; i < binary.length; i++) {
            array.push(binary.charCodeAt(i));
        }
        return new Blob([new Uint8Array(array)], {type: 'image/jpeg'});
    }

    ;

    var b, f, form, r, url;
    b = dataURItoBlob(data_url);
    r = new XMLHttpRequest();
    form = $('form').eq(0);
    url = form.attr("action");
    form.find('[name="file"]').remove();
    f = new FormData(form[0]);
    f.append("file", b);
    r.open("POST", url);
    r.send(f);
    return r.onload = function(e) {
      if (r.status === 200) {
        return chrome.extension.sendMessage({
          method: "next_step"
        });
      }
    };
  }, data_url, function() {});
};

chrome.extension.onMessage.addListener(function(req, sender, send_res) {
  console.log("message");
  if (req.method === "next_step") {
    return next_step("listener");
  }
});

done_images = function() {
  console.log("done images");
  return exec(function() {
    return $("form").eq(1).submit();
  }, function() {
    return wait_for_nav();
  });
};

click_continue = function() {
  return exec(function() {
    return $("button:contains(Continue)").click();
  }, function() {
    return wait_for_nav();
  });
};
