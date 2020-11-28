import dom, jsffi, strutils

const
  colorLight = "#f8f9fa"
  colorLightMedium = "#d4d4d4"
  colorMedium = "#c4c4c4"
  colorMediumDark = "#999999"
  colorDark = "#727272"
  colorClickableBlue = "#3497e4"
  colorDecorativeBlue = "#17a2d2"
  colorNavbarBackground = "#001629"
  colorNavbarText = "#e9e9e9"
  colorTypographyBlack = "#212529"
  colorSuccessBackground = "#6fcf97"
  colorSuccessText = "#105727"
  colorWarningBackground = "#f8d7da"
  colorWarningText = "#721c24"
  colorButtonSecondary = "#5a6268"
  colorButtonDisabled = "#dcddde"
  allColors = [
    colorLight,
    colorLightMedium,
    colorMedium,
    colorMediumDark,
    colorDark,
    colorClickableBlue,
    colorDecorativeBlue,
    colorNavbarBackground,
    colorNavbarText,
    colorTypographyBlack,
    colorSuccessBackground,
    colorSuccessText,
    colorWarningBackground,
    colorWarningText,
    colorButtonSecondary,
    colorButtonDisabled,
  ]

type
  RGB = object
    r, g, b: float

func hexToRGB(s: string): RGB =
  if s.len != 7 or
     s[0] != '#' or
     s[1] notin HexDigits or
     s[2] notin HexDigits or
     s[3] notin HexDigits or
     s[4] notin HexDigits or
     s[5] notin HexDigits or
     s[6] notin HexDigits:
    RGB(r: 0.0, g: 0.0, b: 0.0)
  else:
    RGB(
      r: parseHexInt(s[1..2]).float / 256,
      g: parseHexInt(s[3..4]).float / 256,
      b: parseHexInt(s[5..6]).float / 256
    )

echo hexToRGB("#222222")

var
  appCalculator = document.getElementById("app-calculator")
  table = document.createElement("table")
  tr = document.createElement("tr")
  td = document.createElement("td")

  tdRGBOld = td.cloneNode(false)
  tdRGBNew = td.cloneNode(false)
  tdHSLOld = td.cloneNode(false)
  tdHSLNew = td.cloneNode(false)
  tdColorOld = td.cloneNode(false)
  tdColorNew = td.cloneNode(false)

  trRGBOld = tr.cloneNode(false)
  trRGBNew = tr.cloneNode(false)
  trHSLOld = tr.cloneNode(false)
  trHSLNew = tr.cloneNode(false)
  trColorOld = tr.cloneNode(false)
  trColorNew = tr.cloneNode(false)

  rows = [
    trRGBOld,
    trHSLOld,
    trColorOld,
    trColorNew,
    trHSLNew,
    trRGBNew,
  ]

tdRGBOld.innerText = "Old RGB"
tdRGBNew.innerText = "New RGB"
tdHSLOld.innerText = "Old HSL"
tdHSLNew.innerText = "New HSL"
tdColorOld.innerText = "Old color"
tdColorNew.innerText = "New color"

trRGBOld.appendChild(tdRGBOld)
trRGBNew.appendChild(tdRGBNew)
trHSLOld.appendChild(tdHSLOld)
trHSLNew.appendChild(tdHSLNew)
trColorOld.appendChild(tdColorOld)
trColorNew.appendChild(tdColorNew)

for color in allColors:
  var
    oldRGB = td.cloneNode(false)
  oldRGB.innerText = color
  trRGBOld.appendChild(oldRGB)

for tr in rows:
  table.appendChild(tr)

appCalculator.appendChild(table)

var Three {.importjs: "THREE".}: JsObject

var Width = 640
var Height = 400

document.getElementsByTagName("h1")[0].innerText = "Color visualization HSL".cstring
var
  appCanvas = document.getElementById("app-canvas")
  scene = jsNew Three.Scene
  camera = jsNew Three.PerspectiveCamera(75, Width / Height, 0.1, 1000)
  renderer = jsNew Three.WebGLRenderer
renderer.setSize(Width, Height)
appCanvas.appendChild(renderer.domElement.to(Node))

var
  geometry = jsNew Three.BoxGeometry()
  material = jsNew Three.MeshBasicMaterial(JsObject{color: 0x00ff00})
  cube = jsNew Three.Mesh(geometry, material)
scene.add(cube)

camera.position.set(0, 0, 5)
camera.lookAt(0, 0, 0)

proc animate(time: float = 0) =
  discard window.requestAnimationFrame(animate)
  cube.rotation.x = cube.rotation.x.to(float) + 0.01
  cube.rotation.y = cube.rotation.y.to(float) + 0.01
  renderer.render(scene, camera)

animate()
