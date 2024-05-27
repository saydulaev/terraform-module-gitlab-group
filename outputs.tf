output "group" {
  description = "Group"
  value       = one(gitlab_group.this[*])
}

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

output "access_token_id" {
  description = "Group access tokens"
  value       = one(gitlab_group_access_token.token[*].id)
}

output "access_tokens_id" {
  description = "Group access tokens"
  value       = values(gitlab_group_access_token.tokens)[*].id
}

output "access_token_token" {
  description = "Group access tokens"
  value       = one(gitlab_group_access_token.token[*].token)
}

output "access_tokens_token" {
  description = "Group access tokens"
  value       = { for token in gitlab_group_access_token.tokens : format("%s-%s", token.group, token.name) => token.token }
}

output "custom_attribute_id" {
  description = "Group custom attribute id"
  value       = one(gitlab_group_custom_attribute.attribute[*].id)
}

output "custom_attributes" {
  description = "Group custom attributes id"
  value = length(try(var.custom_attributes, [])) > 0 ? [
    for attr in var.custom_attributes : merge({
      group = attr.group
      id    = gitlab_group_custom_attribute.attributes[attr.key].id
  })] : []
}

output "epic_board_id" {
  description = "Group epic board id"
  value       = one(gitlab_group_epic_board.epic_board[*].id)
}

output "epic_boards_id" {
  description = "Group epic boards id"
  value       = values(gitlab_group_epic_board.epic_boards)[*].id
}

output "variable_id" {
  description = "Group variable id"
  value       = one(gitlab_group_variable.variable[*].id)
}

output "variables_id" {
  description = "Group variables id"
  value       = values(gitlab_group_variable.variables)[*].id
}

output "hook" {
  description = "Group hook"
  value       = one(gitlab_group_hook.hook[*])
}

output "hooks" {
  description = "Group hooks"
  value       = values(gitlab_group_hook.hooks)[*]
}

output "issue_board_id" {
  description = "Group issue board id"
  value       = one(gitlab_group_issue_board.issue_board[*].id)
}

output "issue_boards_id" {
  description = "Group issue boards id"
  value       = values(gitlab_group_issue_board.issue_boards)[*].id
}

output "ldap_link_id" {
  description = "Group LDAP integration"
  value       = one(gitlab_group_ldap_link.this[*].id)
}

output "membership_id" {
  description = "User group membership id"
  value       = values(gitlab_group_membership.this)[*].id
}

output "protected_environment" {
  description = "Group protected environment"
  value       = one(gitlab_group_protected_environment.protected_environment[*].id)
}

output "protected_environments" {
  description = "Group protected environments"
  value       = values(gitlab_group_protected_environment.protected_environments)[*].id
}

output "saml_link_id" {
  description = "Group SAML intergation"
  value       = one(gitlab_group_saml_link.this[*].id)
}

output "share_groups_id" {
  description = "Group share with another group"
  value       = values(gitlab_group_share_group.this)[*].id
}

output "deploy_token" {
  description = "Group deploy token"
  value       = one(gitlab_deploy_token.deploy_tokens[*])
}

output "deploy_tokens" {
  description = "Group deploy tokens"
  value       = values(gitlab_deploy_token.deploy_tokens)[*]
}

output "compliance_framework_id" {
  description = "Group compliance framework id"
  value = one(gitlab_compliance_framework.framework[*].framework_id)
}

output "compliance_framework" {
  description = "Group compliance framework"
  value = one(gitlab_compliance_framework.framework[*])
}

output "compliance_framework_resource_id" {
  description = "Group compliance framework resource id"
  value = one(gitlab_compliance_framework.framework[*].id)
}

output "compliance_frameworks_id" {
  description = "Group compliance frameworks ids"
  value = values(gitlab_compliance_framework.frameworks)[*].framework_id
}

output "compliance_frameworks" {
  description = "Group compliance frameworks"
  value = values(gitlab_compliance_framework.frameworks)[*]
}

output "compliance_frameworks_resource_id" {
  description = "Group compliance frameworks resource id"
  value = values(gitlab_compliance_framework.frameworks)[*].id
}