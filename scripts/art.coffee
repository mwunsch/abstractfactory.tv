# This script takes a screenshot of the "art.html" page, which renders cover
# art suitable for iTunes, and saves it to the img directory.
# This script works best with SlimerJS: http://slimerjs.org/
page = require("webpage").create()
system = require("system")

url = "http://www.abstractfactory.tv/art.html"
fgcolor = system.args[1]
bgcolor = system.args[2]

page.viewportSize = { width: 1400, height: 1400 }

url += "?fg=#{fgcolor}" if fgcolor?
url += "&bg=#{bgcolor}" if bgcolor?

page.open url, (status) ->
  [date,time] = new Date().toISOString().split("T")
  page.render "img/art/"+date+".jpg"
  phantom.exit()
