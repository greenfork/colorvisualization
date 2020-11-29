import jsffi, dom

# Uncomment library import in HTML file.

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
