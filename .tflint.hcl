plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

rule "terraform_unused_declarations" {
  enabled = false
}

rule "terraform_module_pinned_source" {
  enabled = true
  style = "flexible"
  default_branches = ["main"]
}
