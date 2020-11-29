import dom, jsffi, strutils, strformat
from math import round, `mod`

const
  colorsTable = {
    "colorLight": "#f8f9fa",
    "colorLightMedium": "#d4d4d4",
    "colorMedium": "#c4c4c4",
    "colorMediumDark": "#999999",
    "colorDark": "#727272",
    "colorClickableBlue": "#3497e4",
    "colorDecorativeBlue": "#17a2d2",
    "colorNavbarBackground": "#001629",
    "colorNavbarText": "#e9e9e9",
    "colorTypographyBlack": "#212529",
    "colorSuccessBackground": "#6fcf97",
    "colorSuccessText": "#105727",
    "colorWarningBackground": "#f8d7da",
    "colorWarningText": "#721c24",
    "colorButtonSecondary": "#5a6268",
    "colorButtonDisabled": "#dcddde",
  }

type
  RGB = object
    r, g, b: float
  HSL = object
    h: range[0.0..360.0]
    s, l: float

func `$`(c: RGB): string =
  let
    r = int(c.r * 256)
    g = int(c.g * 256)
    b = int(c.b * 256)
  fmt"#{toHex(r, 2)}{toHex(g, 2)}{toHex(b, 2)}"

func `$`(c: HSL): string =
  fmt"{c.h.float:>5.1f}°, {c.s:>5.3f}, {c.l:>5.3f}".replace(" ", "&nbsp;")

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

func toHSL(c: RGB): HSL =
  var
    maxValue = max([c.r, c.g, c.b])
    minValue = min([c.r, c.g, c.b])
  result.l = (minValue + maxValue) / 2.0
  if maxValue == minValue:
    result.s = 0
    result.h = 0
  else:
    let chroma = maxValue - minValue
    result.s =
      if result.l >= 0.5:
        chroma / (2.0 - maxValue - minValue)
      else:
        chroma / (maxValue + minValue)
    result.h =
      if maxValue == c.r: (c.g - c.b) / chroma + (if c.g < c.b: 6.0 else: 0.0)
      elif maxValue == c.g: (c.b - c.r) / chroma + 2.0
      elif maxValue == c.b: (c.r - c.g) / chroma + 4.0
      else: assert false; 0.0
    result.h *= 60
    result.h = round(result.h, 1)
    result.s = round(result.s, 3)
    result.l = round(result.l, 3)
assert toHSL(RGB(r: 0.0, g: 0.5, b: 0.0)) == HSL(h: 120, s: 1.0, l: 0.25)
assert toHSL(RGB(r: 0.5, g: 1.0, b: 1.0)) == HSL(h: 180, s: 1.0, l: 0.75)
assert toHSL(RGB(r: 0.116, g: 0.675, b: 0.255)) == HSL(h: 134.9, s: 0.707, l: 0.396)
assert toHSL(RGB(r: 0.941, g: 0.785, b: 0.053)) == HSL(h: 49.5, s: 0.893, l: 0.497)

func toRGB(c: HSL): RGB =
  func f(n: float): float =
    let k = (n + c.h / 30.0) mod 12
    c.l - c.s * min(c.l, 1 - c.l) * max(-1, min(k - 3, min(9 - k, 1.0)))

  result.r = f(0.0).round(3)
  result.g = f(8.0).round(3)
  result.b = f(4.0).round(3)
assert toRGB(HSL(h: 120, s: 1.0, l: 0.25)) == RGB(r: 0.0, g: 0.5, b: 0.0)
assert toRGB(HSL(h: 180, s: 1.0, l: 0.75)) == RGB(r: 0.5, g: 1.0, b: 1.0)
assert toRGB(HSL(h: 134.9, s: 0.707, l: 0.396)) == RGB(r: 0.116, g: 0.676, b: 0.255)
assert toRGB(HSL(h: 49.5, s: 0.893, l: 0.497)) == RGB(r: 0.941, g: 0.785, b: 0.053)

var
  appCalculator = document.getElementById("app-calculator")
  table = document.createElement("table")
  tr = document.createElement("tr")
  td = document.createElement("td")

  stats = [
    "Old RGB",
    "Old HSL",
    "Old color",
    "New color",
    "New HSL",
    "New RGB",
  ]

block:
  var nameTr = tr.cloneNode(false)
  nameTr.appendChild(td.cloneNode(false))
  for s in stats:
    var td = td.cloneNode(false)
    td.innerText = s
    nameTr.appendChild(td)
  table.appendChild(nameTr)

for (name, color) in colorsTable:
  let
    rgb = hexToRGB(color)
    hsl = rgb.toHSL
  var
    tr = tr.cloneNode(false)
    td1 = td.cloneNode(false)
    td2 = td.cloneNode(false)
    td3 = td.cloneNode(false)
    td4 = td.cloneNode(false)
    td5 = td.cloneNode(false)
    td6 = td.cloneNode(false)
    td7 = td.cloneNode(false)
  td1.innerText = name
  td2.innerText = color
  td3.innerHtml = $hsl
  td4.style.backgroundColor = color
  tr.appendChild(td1)
  tr.appendChild(td2)
  tr.appendChild(td3)
  tr.appendChild(td4)
  tr.appendChild(td5)
  tr.appendChild(td6)
  tr.appendChild(td7)
  table.appendChild(tr)

appCalculator.appendChild(table)


# Animation
###########

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
