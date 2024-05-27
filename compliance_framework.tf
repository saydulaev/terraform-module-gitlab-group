resource "gitlab_compliance_framework" "framework" {
  count = var.compliance_framework != null ? 1 : 0

  namespace_path                   = local.exists_groups[var.compliance_framework.namespace_path].group_id
  name                             = var.compliance_framework.name
  description                      = try(var.compliance_framework.description, null)
  color                            = var.compliance_framework.color
  default                          = try(var.compliance_framework.default, null)
  pipeline_configuration_full_path = try(var.compliance_framework.pipeline_configuration_full_path, null)
}


resource "gitlab_compliance_framework" "frameworks" {
  for_each = contains(["premium", "ultimate"], lower(var.tier)) ? {
    for cf in var.compliance_frameworks : cf.name => cf
  } : {}

  namespace_path                   = local.exists_groups[each.value.namespace_path].group_id
  name                             = each.value.name
  description                      = try(each.value.description, null)
  color                            = each.value.color
  default                          = try(each.value.default, null)
  pipeline_configuration_full_path = try(each.value.pipeline_configuration_full_path, null)
}
