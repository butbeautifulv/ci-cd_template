package main

deny[msg] {
  input.kind == "Pod"
  c := input.spec.containers[_]
  c.securityContext.privileged == true
  msg := sprintf("container %s must not be privileged", [c.name])
}

deny[msg] {
  input.kind == "Pod"
  c := input.spec.containers[_]
  not c.resources.limits.memory
  msg := sprintf("container %s missing memory limit", [c.name])
}
