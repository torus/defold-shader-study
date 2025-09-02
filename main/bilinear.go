components {
  id: "bilinear"
  component: "/main/bilinear.script"
}
embedded_components {
  id: "model"
  type: "model"
  data: "mesh: \"/builtins/assets/meshes/quad_2x2.dae\"\n"
  "name: \"{{NAME}}\"\n"
  "materials {\n"
  "  name: \"default\"\n"
  "  material: \"/main/bilinear.material\"\n"
  "}\n"
  ""
}
