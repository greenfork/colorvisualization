import dom
from math import round, `mod`, pow, sqrt
from strformat import fmt
from strutils import replace, HexDigits, toHex, parseHexInt

type
  RGB* = object
    r*, g*, b*: range[0.0..1.0]
  HSL* = object
    h*: range[0.0..360.0]
    s*, l*: range[0.0..1.0]
  WhitePoint* = enum # only d65 is currently used
    d65, d55, d50, a, c, e, icc
  ReferenceValue* = object
    x*, y*, z*: float
    wp*: WhitePoint
  XYZ* = object
    x*, y*, z*: float
    wp*: WhitePoint
  Lab* = object
    l*: range[0.0..100.0]
    a*, b*: float
    wp*: WhitePoint

func findReferenceValues(wp: WhitePoint): ReferenceValue =
  const
    # https://www.mathworks.com/help/images/ref/whitepoint.html
    # With normalization Y = 100.
    referenceValues = [
      ReferenceValue(wp: WhitePoint.d65, x: 95.047, y: 100.0, z: 108.883),
    ]
  for rv in referenceValues:
    if rv.wp == wp: return rv

const
  colorsTable = {
    "colorLight": ("#f8f9fa", HSL(h: 0.0, s: 0.0, l: 0.973)),
    "colorLightMedium": ("#d4d4d4", HSL(l: 0.82)),
    "colorMedium": ("#c4c4c4", HSL(l: 0.566)),
    "colorMediumDark": ("#999999", HSL(l: 0.456)),
    "colorDark": ("#727272", HSL(l: 0.266)),
    "colorClickableBlue": ("#3497e4", HSL(h: 206.3, s: 0.759, l: 0.547)),
    "colorDecorativeBlue": ("#17a2d2", HSL(h: 195.4, s: 0.803, l: 0.455)),
    "colorNavbarBackground": ("#001629", HSL(h: 207.8, s: 1.0, l: 0.08)),
    "colorNavbarText": ("#e9e9e9", HSL(l: 0.91)),
    "colorTypographyBlack": ("#212529", HSL(h: 210.0, s: 0.108, l: 0.145)),
    "colorSuccessBackground": ("#6fcf97", HSL(h: 145.0, s: 0.7, l: 0.9)),
    "colorSuccessText": ("#105727", HSL(h: 145.0, s: 0.7, l: 0.232)),
    "colorWarningBackground": ("#f8d7da", HSL(h: 5.0, s: 0.7, l: 0.9)),
    "colorWarningText": ("#721c24", HSL(h: 5.0, s: 0.6, l: 0.277)),
    "colorButtonSecondary": ("#5a6268", HSL(h: 205.7, s: 0.072, l: 0.379)),
    "colorButtonDisabled": ("#dcddde", HSL(h: 210.0, s: 0.029, l: 0.863)),
  }
  contrastPairsTable = {
    "navbar": ("colorNavbarBackground", "colorNavbarText"),
    "body": ("colorLight", "colorTypographyBlack"),
    "success": ("colorSuccessBackground", "colorSuccessText"),
    "warning": ("colorWarningBackground", "colorWarningText"),
    "buttons": ("colorClickableBlue", "colorDecorativeBlue"),
    "grey 1": ("colorLight", "colorLightMedium"),
    "grey 2": ("colorLightMedium", "colorMedium"),
    "grey 3": ("colorMedium", "colorMediumDark"),
    "grey 4": ("colorMediumDark", "colorDark"),
    "success bg": ("colorLight", "colorSuccessBackground"),
    "warning bg": ("colorLight", "colorWarningBackground"),
  }

func toHex*(c: RGB): string =
  let
    r = int(c.r * 256)
    g = int(c.g * 256)
    b = int(c.b * 256)
  fmt"#{toHex(r, 2)}{toHex(g, 2)}{toHex(b, 2)}"

func `$`*(c: RGB): string =
  fmt"{c.r:>3.1f}, {c.g:>3.1f}, {c.b:>3.1f}".replace(" ", "&nbsp;")

func `$`*(c: HSL): string =
  fmt"{c.h.float:>5.1f}°, {c.s.float:>3.1f}, {c.l.float:>3.1f}".replace(" ", "&nbsp;")

func `$`*(c: Lab): string =
  fmt"{c.l.float:>5.1f}, {c.a:>5.1f}, {c.b:>5.1f}".replace(" ", "&nbsp;")

func hexToRGB*(s: string): RGB =
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
func toHSL*(c: RGB): HSL =
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

# https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB_alternative
func toRGB*(c: HSL): RGB =
  func f(n: float): float =
    let k = (n + c.h / 30.0) mod 12
    c.l - c.s * min(c.l, 1 - c.l) * max(-1, min(k - 3, min(9 - k, 1.0)))

  result.r = f(0.0).round(3)
  result.g = f(8.0).round(3)
  result.b = f(4.0).round(3)

# http://www.easyrgb.com/en/math.php
func toXYZ*(c: RGB): XYZ =
  var
    r = c.r.float
    g = c.g.float
    b = c.b.float
  r = if r > 0.04045: pow(((r + 0.055) / 1.055), 2.4) else: r / 12.92
  g = if g > 0.04045: pow(((g + 0.055) / 1.055), 2.4) else: g / 12.92
  b = if b > 0.04045: pow(((b + 0.055) / 1.055), 2.4) else: b / 12.92
  r *= 100
  g *= 100
  b *= 100
  result.x = r * 0.4124 + g * 0.3576 + b * 0.1805
  result.y = r * 0.2126 + g * 0.7152 + b * 0.0722
  result.z = r * 0.0193 + g * 0.1192 + b * 0.9505
  result.x = round(result.x, 3)
  result.y = round(result.y, 3)
  result.z = round(result.z, 3)
  result.wp = WhitePoint.d65

# http://www.easyrgb.com/en/math.php
func toRGB*(c: XYZ): RGB =
  var
    x = c.x / 100.0
    y = c.y / 100.0
    z = c.z / 100.0
    r = x *  3.2406 + y * -1.5372 + z * -0.4986
    g = x * -0.9689 + y *  1.8758 + z *  0.0415
    b = x *  0.0557 + y * -0.2040 + z *  1.0570
  r = if r > 0.0031308: 1.055 * pow(r, (1 / 2.4)) - 0.055 else: 12.92 * r
  g = if g > 0.0031308: 1.055 * pow(g, (1 / 2.4)) - 0.055 else: 12.92 * g
  b = if b > 0.0031308: 1.055 * pow(b, (1 / 2.4)) - 0.055 else: 12.92 * b
  result.r = r.round(3)
  result.g = g.round(3)
  result.b = b.round(3)

# http://www.easyrgb.com/en/math.php
func toLab*(c: XYZ): Lab =
  let rv = findReferenceValues(c.wp)
  var
    x = c.x / rv.x
    y = c.y / rv.y
    z = c.z / rv.z
  x = if x > 0.008856: pow(x, 1.0 / 3.0) else: 7.787 * x + 16.0 / 116.0
  y = if y > 0.008856: pow(y, 1.0 / 3.0) else: 7.787 * y + 16.0 / 116.0
  z = if z > 0.008856: pow(z, 1.0 / 3.0) else: 7.787 * z + 16.0 / 116.0
  result.l = 116 * y - 16
  result.a = 500 * (x - y)
  result.b = 200 * (y - z)
  result.l = round(result.l, 3)
  result.a = round(result.a, 3)
  result.b = round(result.b, 3)

# http://www.easyrgb.com/en/math.php
func toXYZ*(c: Lab): XYZ =
  let rv = findReferenceValues(c.wp)
  var
    y = (c.l + 16) / 116.0
    x = c.a / 500.0 + y
    z = y - c.b / 200.0
  let
    cubicY = pow(y, 3)
    cubicX = pow(x, 3)
    cubicZ = pow(z, 3)
  y = if cubicY > 0.008856: cubicY else: (y - 16.0 / 116.0) / 7.787
  x = if cubicY > 0.008856: cubicX else: (x - 16.0 / 116.0) / 7.787
  z = if cubicY > 0.008856: cubicZ else: (z - 16.0 / 116.0) / 7.787
  result.x = x * rv.x
  result.y = y * rv.y
  result.z = z * rv.z
  result.x = round(result.x, 3)
  result.y = round(result.y, 3)
  result.z = round(result.z, 3)

# http://www.easyrgb.com/en/math.php
# Euclidian distance
func deltaE*(m, p: Lab): float =
  let
    ld = m.l - p.l
    ad = m.a - p.a
    bd = m.b - p.b
  sqrt(ld*ld + ad*ad + bd*bd).round(1)

func deltaE*(m, p: RGB): float = deltaE(m.toXYZ.toLab, p.toXYZ.toLab)

func luminance(c: RGB): float =
  let
    r = if c.r > 0.3928: pow((c.r + 0.055) / 1.055, 2.4) else: c.r / 12.92
    g = if c.g > 0.3928: pow((c.g + 0.055) / 1.055, 2.4) else: c.g / 12.92
    b = if c.b > 0.3928: pow((c.b + 0.055) / 1.055, 2.4) else: c.b / 12.92
  0.2126 * r + 0.7152 * g + 0.0722 * b

# https://www.w3.org/TR/WCAG20-TECHS/G18.html#G18-tests
func contrastRatio(m, p: RGB): float =
  let
    luminance1 = m.luminance
    luminance2 = p.luminance
  result =
    if luminance1 > luminance2: (luminance1 + 0.05) / (luminance2 + 0.05)
    else: (luminance2 + 0.05) / (luminance1 + 0.05)
  result = result.round(1)

when isMainModule:
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
        "Old L*a*b*",
        "Old color",
        "New color",
        "New L*a*b*",
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
        oldLab = oldRGB.toXYZ.toLab
        newHSL = newHSLColor
        newRGB = newHSL.toRGB
        newLab = newRGB.toXYZ.toLab
      var
        tr = tr.cloneNode(false)
        td1 = td.cloneNode(false)
        td2 = td.cloneNode(false)
        td3 = td.cloneNode(false)
        td4 = td.cloneNode(false)
        td5 = td.cloneNode(false)
        td6 = td.cloneNode(false)
        td7 = td.cloneNode(false)
        td8 = td.cloneNode(false)
        td9 = td.cloneNode(false)
      td1.innerText = name
      td2.innerText = oldHexColor
      td3.innerHtml = $oldHSL
      td4.innerHtml = $oldLab
      td5.style.backgroundColor = oldHexColor
      td6.style.backgroundColor = newRGB.toHex()
      td7.innerHtml = $newLab
      td8.innerHtml = $newHSL
      td9.innerText = newRGB.toHex()
      tr.appendChild(td1)
      tr.appendChild(td2)
      tr.appendChild(td3)
      tr.appendChild(td4)
      tr.appendChild(td5)
      tr.appendChild(td6)
      tr.appendChild(td7)
      tr.appendChild(td8)
      tr.appendChild(td9)
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
      oldContrastTd.innerText =
        $contrastRatio(oldBgHexColor.hexToRGB, oldFgHexColor.hexToRGB)
      newBgTd.style.backgroundColor = newBgHexColor
      newFgTd.style.backgroundColor = newFgHexColor
      newContrastTd.innerText =
        $contrastRatio(newBgHexColor.hexToRGB, newFgHexColor.hexToRGB)

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
