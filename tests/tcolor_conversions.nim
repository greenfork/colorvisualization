import unittest
import colorvisualization
from strformat import fmt
from math import round

func `$`(c: RGB): string =
  fmt"{c.r.float:>3.1f}, {c.g.float:>3.1f}, {c.b.float:>3.1f}"
func `$`(c: HSL): string =
  fmt"{c.h.float:>5.1f}°, {c.s.float:>3.1f}, {c.l.float:>3.1f}"
func `$`(c: XYZ): string =
  fmt"{c.x:>5.1f}, {c.y:>5.1f}, {c.z:>5.1f}"
func `$`(c: Lab): string =
  fmt"{c.l.float:>5.1f}, {c.a:>5.1f}, {c.b:>5.1f}"

suite "test conversions to different color spaces":
  test "RGB to HSL":
    check $toHSL(RGB(r: 0.0, g: 0.5, b: 0.0)) == $HSL(h: 120, s: 1.0, l: 0.25)
    check $toHSL(RGB(r: 0.5, g: 1.0, b: 1.0)) == $HSL(h: 180, s: 1.0, l: 0.75)
    check $toHSL(RGB(r: 0.116, g: 0.675, b: 0.255)) == $HSL(h: 134.9, s: 0.707, l: 0.396)
    check $toHSL(RGB(r: 0.941, g: 0.785, b: 0.053)) == $HSL(h: 49.5, s: 0.893, l: 0.497)

  test "HSL to RGB":
    check $toRGB(HSL(h: 120, s: 1.0, l: 0.25)) == $RGB(r: 0.0, g: 0.5, b: 0.0)
    check $toRGB(HSL(h: 180, s: 1.0, l: 0.75)) == $RGB(r: 0.5, g: 1.0, b: 1.0)
    check $toRGB(HSL(h: 134.9, s: 0.707, l: 0.396)) == $RGB(r: 0.116, g: 0.676, b: 0.255)
    check $toRGB(HSL(h: 49.5, s: 0.893, l: 0.497)) == $RGB(r: 0.941, g: 0.785, b: 0.053)

  test "RGB to XYZ":
    check $toXYZ(RGB(r: 0.0, g: 0.5, b: 0.0)) == $XYZ(x: 7.654, y: 15.308, z: 2.551)
    check $toXYZ(RGB(r: 0.5, g: 1.0, b: 1.0)) == $XYZ(x: 62.637, y: 83.291, z: 107.383)
    check $toXYZ(RGB(r: 0.116, g: 0.675, b: 0.255)) == $XYZ(x: 16.254, y: 30.204, z: 9.978)
    check $toXYZ(RGB(r: 0.941, g: 0.785, b: 0.053)) == $XYZ(x: 56.691, y: 59.937, z: 8.98)

  test "XYZ to RGB":
    check $toRGB(XYZ(x: 7.654, y: 15.308, z: 2.551)) == $RGB(r: 0.0, g: 0.5, b: 0.0)
    check $toRGB(XYZ(x: 62.637, y: 83.291, z: 107.383)) == $RGB(r: 0.5, g: 1.0, b: 1.0)
    check $toRGB(XYZ(x: 16.254, y: 30.204, z: 9.978)) == $RGB(r: 0.116, g: 0.675, b: 0.255)
    check $toRGB(XYZ(x: 56.691, y: 59.937, z: 8.98)) == $RGB(r: 0.941, g: 0.785, b: 0.053)

  test "XYZ to Lab":
    check $toLab(XYZ(x: 7.654, y: 15.308, z: 2.551)) == $Lab(l: 46.053, a: -51.554, b: 49.76)
    check $toLab(XYZ(x: 62.637, y: 83.291, z: 107.383)) == $Lab(l: 93.142, a: -35.327, b: -10.902)
    check $toLab(XYZ(x: 16.254, y: 30.204, z: 9.978)) == $Lab(l: 61.83, a: -57.943, b: 44.02)
    check $toLab(XYZ(x: 56.691, y: 59.937, z: 8.98)) == $Lab(l: 81.804, a: -0.685, b: 81.571)

  test "Lab to XYZ":
    check $toXYZ(Lab(l: 46.053, a: -51.554, b: 49.76)) == $XYZ(x: 7.654, y: 15.308, z: 2.551)
    check $toXYZ(Lab(l: 93.142, a: -35.327, b: -10.902)) == $XYZ(x: 62.637, y: 83.292, z: 107.384)
    check $toXYZ(Lab(l: 61.83, a: -57.943, b: 44.02)) == $XYZ(x: 16.254, y: 30.204, z: 9.978)
    check $toXYZ(Lab(l: 81.804, a: -0.685, b: 81.571)) == $XYZ(x: 56.691, y: 59.937, z: 8.98)

  test "delta E":
    let color = RGB(r: 0.0, g: 1.0, b: 0.0)
    check deltaE(color, RGB(r: 158.308 / 256, g: 172.905 / 256, b: 44.3 / 256)).round == 72
    check deltaE(color, RGB(r: 168.464 / 256, g: 180.085 / 256, b: 51.277 / 256)).round == 72
    check deltaE(color, RGB(r: 50.184 / 256, g: 160.045 / 256, b: 93.612 / 256)).round == 76
    check deltaE(color, RGB(r: 134.26 / 256, g: 155.458 / 256, b: 44.293 / 256)).round == 75
