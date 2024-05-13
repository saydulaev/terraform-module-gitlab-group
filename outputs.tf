output "id" {
  description = "Group ID"
  value       = one(gitlab_group.this[*].id)
  sensitive   = false
}

output "full_name" {
  description = "The full name of the group."
  value       = one(gitlab_group.this[*].full_name)
}

output "full_path" {
  description = "The full path of the group."
  value       = one(gitlab_group.this[*].full_path)
}

output "avatar_url" {
  description = "The URL of the avatar image."
  value       = one(gitlab_group.this[*].avatar_url)
}

output "runners_token" {
  description = "The group level registration token to use during runner setup."
  value       = one(gitlab_group.this[*].runners_token)
}

output "web_url" {
  description = "Web URL of the group."
  value       = one(gitlab_group.this[*].web_url)
}

output "access_tokens_id" {
  description = "Group access tokens"
  value       = values(gitlab_group_access_token.this)[*].id
}

output "access_tokens_token" {
  description = "Group access tokens"
  value       = { for token in gitlab_group_access_token.this : format("%s-%s", token.group, token.name) => token.token }
}

output "custom_attributes" {
  description = "Group custom attributes id"
  value = length(try(var.custom_attributes, [])) > 0 ? [
    for attr in var.custom_attributes : merge({
      group = attr.group
      id    = gitlab_group_custom_attribute.this[attr.key].id
  })] : []
}

output "epic_boards_id" {
  description = "Group epic boards"
  value       = values(gitlab_group_epic_board.this)[*].id
}

output "variables_id" {
  description = "Group variables id"
  value       = length(var.variables) > 0 ? values(gitlab_group_variable.this)[*].id : []
}

output "hooks" {
  description = "Group hooks"
  value       = values(gitlab_group_hook.this)[*]
}

output "issue_boards_id" {
  description = "Group issue boards id"
  value       = values(gitlab_group_issue_board.this)[*].id
}

output "ldap_link_id" {
  description = "Group LDAP integration"
  value       = var.ldap_link != null ? gitlab_group_ldap_link.this[0].id : ""
}

output "membership_id" {
  description = "User group membership id"
  value       = values(gitlab_group_membership.this)[*].id
}

output "protected_environments" {
  description = "Group protected environment"
  value       = values(gitlab_group_protected_environment.this)[*].id
}

output "saml_link_id" {
  description = "Group SAML intergation"
  value       = var.saml_link != null ? one(gitlab_group_saml_link.this).id : ""
}

output "share_groups_id" {
  description = "Group share with another group"
  value       = values(gitlab_group_share_group.this)[*].id
}

output "deploy_tokens" {
  description = "Group deploy tokens"
  value = length(var.deploy_tokens) > 0 ? [
    for token in gitlab_deploy_token.this :
    { deploy_token_id = token.deploy_token_id, id = token.id, token = token.token }
  ] : []
}

output "compliance_framework_id" {
  value = values(gitlab_compliance_framework.this)[*].framework_id
}

output "compliance_framework_resource_id" {
  value = values(gitlab_compliance_framework.this)[*].id
}