# This script takes a screenshot of the "art.html" page, which renders cover
# art suitable for iTunes, and saves it to the img directory.
# This script works best with SlimerJS: http://slimerjs.org/
page = require("webpage").create()
system = require("system")


url = "http://www.abstractfactory.tv/art.html"
page.viewportSize = { width: 1400, height: 1400 }

page.open url, (status) ->
  [date,time] = new Date().toISOString().split("T")
  page.render "img/art/"+date+".jpg"
  phantom.exit()
