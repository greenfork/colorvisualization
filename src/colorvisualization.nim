import dom, strutils, strformat
from math import round, `mod`, pow

type
  RGB = object
    r, g, b: float
  HSL = object
    h: range[0.0..360.0]
    s, l: float
  XYZ = object
    x, y, z: float
  WhitePoint = enum
    d65, d50
  LaB = object
    l: range[0..100]
    a, b: float
    whitePoint: WhitePoint

const
  colorsTable = {
    "colorLight": ("#f8f9fa", HSL(h: 210.0, s: 0.143, l: 0.973)),
    "colorLightMedium": ("#d4d4d4", HSL(l: 0.828)),
    "colorMedium": ("#c4c4c4", HSL(l: 0.766)),
    "colorMediumDark": ("#999999", HSL(l: 0.598)),
    "colorDark": ("#727272", HSL(l: 0.445)),
    "colorClickableBlue": ("#3497e4", HSL(h: 206.3, s: 0.759, l: 0.547)),
    "colorDecorativeBlue": ("#17a2d2", HSL(h: 195.4, s: 0.803, l: 0.455)),
    "colorNavbarBackground": ("#001629", HSL(h: 207.8, s: 1.0, l: 0.08)),
    "colorNavbarText": ("#e9e9e9", HSL(l: 0.91)),
    "colorTypographyBlack": ("#212529", HSL(h: 210.0, s: 0.108, l: 0.145)),
    "colorSuccessBackground": ("#6fcf97", HSL(h: 145.0, s: 0.495, l: 0.621)),
    "colorSuccessText": ("#105727", HSL(h: 139.4, s: 0.689, l: 0.201)),
    "colorWarningBackground": ("#f8d7da", HSL(h: 354.5, s: 0.673, l: 0.904)),
    "colorWarningText": ("#721c24", HSL(h: 354.4, s: 0.606, l: 0.277)),
    "colorButtonSecondary": ("#5a6268", HSL(h: 205.7, s: 0.072, l: 0.379)),
    "colorButtonDisabled": ("#dcddde", HSL(h: 210.0, s: 0.029, l: 0.863)),
  }
  contrastPairsTable = {
    "navbar": ("colorNavbarBackground", "colorNavbarText"),
    "body": ("colorLight", "colorTypographyBlack"),
    "success": ("colorSuccessBackground", "colorSuccessText"),
    "warning": ("colorWarningBackground", "colorWarningText"),
  }

func toHex(c: RGB): string =
  let
    r = int(c.r * 256)
    g = int(c.g * 256)
    b = int(c.b * 256)
  fmt"#{toHex(r, 2)}{toHex(g, 2)}{toHex(b, 2)}"

func `$`(c: RGB): string =
  fmt"{c.r:>5.3f}, {c.g:>5.3f}, {c.b:>5.3f}".replace(" ", "&nbsp;")

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
    assert false; RGB(r: 0.0, g: 0.0, b: 0.0)
  else:
    RGB(
      r: parseHexInt(s[1..2]).float / 256,
      g: parseHexInt(s[3..4]).float / 256,
      b: parseHexInt(s[5..6]).float / 256
    )

# https://stackoverflow.com/questions/2353211/hsl-to-rgb-color-conversion
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

# https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB_alternative
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

# http://www.easyrgb.com/en/math.php
func toXYZ(c: RGB): XYZ =
  var
    r = c.r
    g = c.g
    b = c.b
  r = if r > 0.04045: pow(((r + 0.055) / 1.055), 2.4) else: r / 12.92
  g = if g > 0.04045: pow(((g + 0.055) / 1.055), 2.4) else: g / 12.92
  b = if b > 0.04045: pow(((b + 0.055) / 1.055), 2.4) else: b / 12.92
  r *= 100
  g *= 100
  b *= 100
  result.x = r * 0.4124 + g * 0.3576 + b * 0.1805
  result.y = r * 0.2126 + g * 0.7152 + b * 0.0722
  result.z = r * 0.0193 + g * 0.1192 + b * 0.9505

# http://www.easyrgb.com/en/math.php
func toRGB(c: XYZ): RGB =
  var
    r = c.x *  3.2406 + c.y * -1.5372 + c.z * -0.4986
    g = c.x * -0.9689 + c.y *  1.8758 + c.z *  0.0415
    b = c.x *  0.0557 + c.y * -0.2040 + c.z *  1.0570
  r = if r > 0.0031308: 1.055 * pow(r, (1 / 2.4)) - 0.055 else: 12.92 * r
  g = if g > 0.0031308: 1.055 * pow(g, (1 / 2.4)) - 0.055 else: 12.92 * g
  b = if b > 0.0031308: 1.055 * pow(b, (1 / 2.4)) - 0.055 else: 12.92 * b
  result.r = r
  result.g = g
  result.b = b

# https://en.wikipedia.org/wiki/CIELAB_color_space#Converting_between_CIELAB_and_CIEXYZ_coordinates
func toLaB(c: XYZ): LaB =
  discard

# https://en.wikipedia.org/wiki/CIELAB_color_space#Converting_between_CIELAB_and_CIEXYZ_coordinates
func toXYZ(c: LaB): XYZ =
  discard

var
  appCalculator = document.getElementById("app-calculator")
  table = document.createElement("table")
  tr = document.createElement("tr")
  td = document.createElement("td")

block palette:
  var
    paletteHtmlTable = table.cloneNode(false)
    stats = [
      "Old RGB",
      "Old HSL",
      "Old color",
      "New color",
      "New HSL",
      "New RGB",
    ]
    nameTr = tr.cloneNode(false)
  paletteHtmlTable.id = "palette-table"

  nameTr.appendChild(td.cloneNode(false))
  for s in stats:
    var td = td.cloneNode(false)
    td.innerText = s
    nameTr.appendChild(td)
  paletteHtmlTable.appendChild(nameTr)

  for (name, colors) in colorsTable:
    let
      (oldHexColor, newHSLColor) = colors
      oldRGB = hexToRGB(oldHexColor)
      oldHSL = oldRGB.toHSL
      newHSL = newHSLColor
      newRGB = newHSL.toRGB()
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
    td2.innerText = oldHexColor
    td3.innerHtml = $oldHSL
    td4.style.backgroundColor = oldHexColor
    td5.style.backgroundColor = newRGB.toHex()
    td6.innerHtml = $newHSL
    td7.innerText = newRGB.toHex()
    tr.appendChild(td1)
    tr.appendChild(td2)
    tr.appendChild(td3)
    tr.appendChild(td4)
    tr.appendChild(td5)
    tr.appendChild(td6)
    tr.appendChild(td7)
    paletteHtmlTable.appendChild(tr)

  appCalculator.appendChild(paletteHtmlTable)

block contrastPairs:
  var
    contrastPairsHtmlTable = table.cloneNode(false)
    nameTr = tr.cloneNode(false)
    oldBgTr = tr.cloneNode(false)
    oldFgTr = tr.cloneNode(false)
    oldContrastTr = tr.cloneNode(false)
    newBgTr = tr.cloneNode(false)
    newFgTr = tr.cloneNode(false)
    newContrastTr = tr.cloneNode(false)
    oldFirstBgTd = td.cloneNode(false)
    oldFirstFgTd = td.cloneNode(false)
    oldFirstContrastTd = td.cloneNode(false)
    newFirstBgTd = td.cloneNode(false)
    newFirstFgTd = td.cloneNode(false)
    newFirstContrastTd = td.cloneNode(false)
  contrastPairsHtmlTable.id = "contrast-pairs-table"

  oldFirstBgTd.innerText = "Old background"
  oldFirstFgTd.innerText = "Old foreground"
  oldFirstContrastTd.innerText = "Old contrast"
  newFirstBgTd.innerText = "New background"
  newFirstFgTd.innerText = "New foreground"
  newFirstContrastTd.innerText = "New contrast"

  nameTr.appendChild(td.cloneNode(false))
  oldBgTr.appendChild(oldFirstBgTd)
  oldFgTr.appendChild(oldFirstFgTd)
  oldContrastTr.appendChild(oldFirstContrastTd)
  newBgTr.appendChild(newFirstBgTd)
  newFgTr.appendChild(newFirstFgTd)
  newContrastTr.appendChild(newFirstContrastTd)

  func tableFind(t: openArray[(string, (string, HSL))], key: string): (string, HSL) =
    for index, elem in t.pairs():
      if elem[0] == key: return elem[1]

  for (name, colorNames) in contrastPairsTable:
    let
      (bgName, fgName) = colorNames
      (oldBgHexColor, newBgHSLColor) = colorsTable.tableFind(bgName)
      (oldfgHexColor, newfgHSLColor) = colorsTable.tableFind(fgName)
      newBgHexColor = newBgHSLColor.toRGB.toHex
      newFgHexColor = newFgHSLColor.toRGB.toHex
    var
      nameTd = td.cloneNode(false)
      oldBgTd = td.cloneNode(false)
      oldFgTd = td.cloneNode(false)
      oldContrastTd = td.cloneNode(false)
      newBgTd = td.cloneNode(false)
      newFgTd = td.cloneNode(false)
      newContrastTd = td.cloneNode(false)

    nameTd.innerText = name
    oldBgTd.style.backgroundColor = oldBgHexColor
    oldFgTd.style.backgroundColor = oldFgHexColor
    oldContrastTd.innerText = "0"
    newBgTd.style.backgroundColor = newBgHexColor
    newFgTd.style.backgroundColor = newFgHexColor
    newContrastTd.innerText = "0"

    nameTr.appendChild(nameTd)
    oldBgTr.appendChild(oldBgTd)
    oldFgTr.appendChild(oldFgTd)
    oldContrastTr.appendChild(oldContrastTd)
    newBgTr.appendChild(newBgTd)
    newFgTr.appendChild(newFgTd)
    newContrastTr.appendChild(newContrastTd)

  contrastPairsHtmlTable.appendChild(nameTr)
  contrastPairsHtmlTable.appendChild(oldBgTr)
  contrastPairsHtmlTable.appendChild(oldFgTr)
  contrastPairsHtmlTable.appendChild(oldContrastTr)
  contrastPairsHtmlTable.appendChild(newBgTr)
  contrastPairsHtmlTable.appendChild(newFgTr)
  contrastPairsHtmlTable.appendChild(newContrastTr)
  appCalculator.appendChild(contrastPairsHtmlTable)
