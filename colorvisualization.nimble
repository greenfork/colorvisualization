# Package

version = "0.3.0"
author = "Dmitry Matveyev"
description = "A new awesome nimble package"
license = "MIT"
srcDir = "src"
namedBin["colorvisualization"] = "colorvisualization-dev"
binDir = "js"
backend = "js"


# Dependencies

requires "nim >= 1.4.0"

task release, "Update release version of JS file for use in index.html":
  var indexContent = readFile("index-dev.html")
  indexContent = indexContent.replace(
    "js/colorvisualization-dev.js",
    "js/colorvisualization.js?v=" & version
  )
  writeFile("index.html", indexContent)
  exec "nim js -d:release -o:js/colorvisualization.js src/colorvisualization.nim"
