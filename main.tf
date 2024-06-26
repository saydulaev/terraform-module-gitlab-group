resource "gitlab_group" "this" {
  count = var.group != null ? 1 : 0

  name                               = var.group.name
  path                               = var.group.path
  auto_devops_enabled                = var.group.auto_devops_enabled
  avatar                             = var.group.avatar
  avatar_hash                        = var.group.avatar_hash
  default_branch_protection          = var.group.default_branch_protection
  description                        = var.group.description
  emails_enabled                     = var.group.emails_enabled
  extra_shared_runners_minutes_limit = var.group.extra_shared_runners_minutes_limit
  ip_restriction_ranges              = var.group.ip_restriction_ranges
  lfs_enabled                        = var.group.lfs_enabled
  membership_lock                    = var.group.membership_lock
  mentions_disabled                  = var.group.mentions_disabled
  parent_id                          = var.group.parent_id
  prevent_forking_outside_group      = var.group.prevent_forking_outside_group
  project_creation_level             = var.group.project_creation_level
  dynamic "push_rules" {
    for_each = length(var.group.push_rules) > 0 ? toset(var.group.push_rules) : []
    iterator = rule
    content {
      author_email_regex            = try(rule.value.author_email_regex, null)
      branch_name_regex             = try(rule.value.branch_name_regex, null)
      commit_committer_check        = try(rule.value.commit_committer_check, null)
      commit_message_negative_regex = try(rule.value.commit_message_negative_regex, null)
      commit_message_regex          = try(rule.value.commit_message_regex, null)
      deny_delete_tag               = try(rule.value.deny_delete_tag, null)
      file_name_regex               = try(rule.value.file_name_regex, null)
      max_file_size                 = try(rule.value.max_file_size, null)
      member_check                  = try(rule.value.member_check, null)
      prevent_secrets               = try(rule.value.prevent_secrets, null)
      reject_unsigned_commits       = try(rule.value.reject_unsigned_commits, null)
    }
  }
  request_access_enabled            = var.group.request_access_enabled
  require_two_factor_authentication = var.group.require_two_factor_authentication
  share_with_group_lock             = var.group.share_with_group_lock
  shared_runners_minutes_limit      = var.group.shared_runners_minutes_limit
  shared_runners_setting            = var.group.shared_runners_setting
  subgroup_creation_level           = var.group.subgroup_creation_level
  two_factor_grace_period           = var.group.two_factor_grace_period
  visibility_level                  = var.group.visibility_level
  wiki_access_level                 = contains(["premium", "ultimate"], lower(var.tier)) ? var.group.wiki_access_level : null
}

resource "gitlab_group_access_token" "token" {
  count = var.access_token != null ? 1 : 0

  group        = coalesce(var.access_token.group, one(gitlab_group.this[*].id)) // try(each.value.group, gitlab_group.this.id)
  name         = var.access_token.name
  scopes       = var.access_token.scopes
  access_level = var.access_token.access_level
  expires_at   = var.access_token.expires_at
  rotation_configuration = var.access_token.rotation_configuration != null ? {
    expiration_days    = try(var.access_token.rotation_configuration.expiration_days, null)
    rotate_before_days = try(var.access_token.rotation_configuration.rotate_before_days, null)
  } : null
}

resource "gitlab_group_access_token" "tokens" {
  for_each = {
    for token in var.access_tokens : token.name => token
    if length(var.access_tokens) > 0
  }

  group        = coalesce(each.value.group, one(gitlab_group.this[*].id)) // try(each.value.group, gitlab_group.this.id)
  name         = each.value.name
  scopes       = each.value.scopes
  access_level = each.value.access_level
  expires_at   = each.value.expires_at
  rotation_configuration = each.value.rotation_configuration != null ? {
    expiration_days    = try(each.value.rotation_configuration.expiration_days, null)
    rotate_before_days = try(each.value.rotation_configuration.rotate_before_days, null)
  } : null
}

resource "gitlab_group_badge" "badge" {
  count = var.badge != null ? 1 : 0

  group     = coalesce(var.badge.group, one(gitlab_group.this[*].id))
  link_url  = var.badge.link_url
  image_url = var.badge.image_url
  name      = var.badge.name
}

resource "gitlab_group_badge" "badges" {
  for_each = {
    for badge in var.badges : badge.link_url => badge
    if length(var.badges) > 0
  }

  group     = coalesce(each.value.group, one(gitlab_group.this[*].id))
  link_url  = each.value.link_url
  image_url = each.value.image_url
  name      = each.value.name
}

resource "gitlab_group_custom_attribute" "attribute" {
  count = var.custom_attribute != null ? 1 : 0

  group = coalesce(var.custom_attribute.group, one(gitlab_group.this[*].id))
  key   = var.custom_attribute.key
  value = var.custom_attribute.value
}

resource "gitlab_group_custom_attribute" "attributes" {
  for_each = {
    for attr in var.custom_attributes : attr.key => attr
    if length(var.custom_attributes) > 0
  }

  group = coalesce(each.value.group, one(gitlab_group.this[*].id))
  key   = each.value.key
  value = each.value.value
}

resource "gitlab_group_label" "label" {
  count = var.label != null ? 1 : 0

  group       = coalesce(var.label.group, one(gitlab_group.this[*].id))
  name        = var.label.name
  description = var.label.description
  color       = var.label.color
}

resource "gitlab_group_label" "labels" {
  for_each = {
    for label in var.labels : label.name => label
    if length(var.labels) > 0
  }

  group       = coalesce(each.value.group, one(gitlab_group.this[*].id))
  name        = each.value.name
  description = each.value.description
  color       = each.value.color
}

resource "gitlab_group_epic_board" "epic_board" {
  count = var.epic_board != null ? 1 : 0

  name  = var.epic_board.name
  group = coalesce(var.epic_board.group, one(gitlab_group.this[*].id))
  dynamic "lists" {
    for_each = length(var.epic_board.lists) > 0 ? toset(var.epic_board.lists) : []
    iterator = rule
    content {
      label_id = tonumber(gitlab_group_label.this[rule.value.label_id].label_id)
    }
  }
}

resource "gitlab_group_epic_board" "epic_boards" {
  for_each = {
    for board in var.epic_boards : board.name => board
    if length(var.epic_boards) > 0 && contains(["premium", "ultimate"], lower(var.tier))
  }

  name  = each.value.name
  group = coalesce(each.value.group, one(gitlab_group.this[*].id))
  dynamic "lists" {
    for_each = length(each.value.lists) > 0 ? toset(each.value.lists) : []
    iterator = rule
    content {
      label_id = tonumber(gitlab_group_label.this[rule.value.label_id].label_id)
    }
  }
}

resource "gitlab_group_hook" "hook" {
  count = var.hook != null ? 1 : 0

  group                      = coalesce(var.hook.group, one(gitlab_group.this[*].id))
  url                        = var.hook.url
  confidential_issues_events = var.hook.confidential_issues_events
  confidential_note_events   = var.hook.confidential_note_events
  custom_webhook_template    = var.hook.custom_webhook_template
  deployment_events          = var.hook.deployment_events
  enable_ssl_verification    = var.hook.enable_ssl_verification
  issues_events              = var.hook.issues_events
  job_events                 = var.hook.job_events
  merge_requests_events      = var.hook.merge_requests_events
  note_events                = var.hook.note_events
  pipeline_events            = var.hook.pipeline_events
  push_events                = var.hook.push_events
  push_events_branch_filter  = var.hook.push_events_branch_filter
  releases_events            = var.hook.releases_events
  subgroup_events            = var.hook.subgroup_events
  tag_push_events            = var.hook.tag_push_events
  token                      = var.hook.token
  wiki_page_events           = var.hook.wiki_page_events
}

resource "gitlab_group_hook" "hooks" {
  for_each = {
    for hook in var.hooks : hook.url => hook
    if length(var.hooks) > 0 && contains(["premium", "ultimate"], lower(var.tier))
  }

  group                      = coalesce(each.value.group, one(gitlab_group.this[*].id))
  url                        = each.value.url
  confidential_issues_events = each.value.confidential_issues_events
  confidential_note_events   = each.value.confidential_note_events
  custom_webhook_template    = each.value.custom_webhook_template
  deployment_events          = each.value.deployment_events
  enable_ssl_verification    = each.value.enable_ssl_verification
  issues_events              = each.value.issues_events
  job_events                 = each.value.job_events
  merge_requests_events      = each.value.merge_requests_events
  note_events                = each.value.note_events
  pipeline_events            = each.value.pipeline_events
  push_events                = each.value.push_events
  push_events_branch_filter  = each.value.push_events_branch_filter
  releases_events            = each.value.releases_events
  subgroup_events            = each.value.subgroup_events
  tag_push_events            = each.value.tag_push_events
  token                      = each.value.token
  wiki_page_events           = each.value.wiki_page_events
}

resource "gitlab_group_issue_board" "issue_board" {
  count = var.issue_board != null ? 1 : 0

  name   = var.issue_board.name
  group  = coalesce(var.issue_board.group, one(gitlab_group.this[*].id))
  labels = var.issue_board.labels
  dynamic "lists" {
    for_each = length(var.issue_board.lists) > 0 ? toset(var.issue_board.lists) : []
    iterator = rule
    content {
      label_id = coalesce(gitlab_group_label.labels[rule.value.label_id].label_id, one(gitlab_group_label.label[*].id))
      position = rule.value.position
    }
  }
  milestone_id = var.issue_board.milestone_id
}

resource "gitlab_group_issue_board" "issue_boards" {
  for_each = {
    for board in var.issue_boards : board.name => board
    if length(var.issue_boards) > 0
  }

  name   = each.value.name
  group  = coalesce(each.value.group, one(gitlab_group.this[*].id))
  labels = each.value.labels
  dynamic "lists" {
    for_each = length(each.value.lists) > 0 ? toset(each.value.lists) : []
    iterator = rule
    content {
      label_id = coalesce(gitlab_group_label.labels[rule.value.label_id].label_id, one(gitlab_group_label.label[*].id)) //gitlab_group_label.this[rule.value.label_id].label_id
      position = rule.value.position
    }
  }
  milestone_id = each.value.milestone_id
}

resource "gitlab_group_ldap_link" "this" {
  count = var.ldap_link != null ? 1 : 0

  group         = coalesce(var.ldap_link.group, one(gitlab_group.this[*].id))
  ldap_provider = var.ldap_link.ldap_provider
  cn            = var.ldap_link.cn
  filter        = contains(["premium", "ultimate"], lower(var.tier)) ? var.ldap_link.filter : null
  force         = var.ldap_link.force
  group_access  = var.ldap_link.group_access
}

// Lookup membership group to get id
// data "gitlab_group" "membership_group" {
//   for_each = toset(flatten([for g in local.groups : g.membership[*].group_id if length(g.membership) > 0]))
// 
//   full_path = each.value
//   depends_on = [
//     gitlab_group.parent,
//     gitlab_group.other
//   ]
// }
// 
// Lookup membership user to get id
data "gitlab_user" "membership_user" {
  for_each = {
    for member in var.membership : member.user_id => member
    if length(var.membership) > 0
  }
  username = each.value.user_id
}

resource "gitlab_group_membership" "this" {
  for_each = {
    for member in var.membership : member.user_id => member
    if length(var.membership) > 0
  }

  access_level                  = each.value.access_level
  group_id                      = coalesce(each.value.group_id, one(gitlab_group.this[*].id))
  user_id                       = data.gitlab_user.membership_user[each.value.user_id].id
  expires_at                    = each.value.expires_at
  member_role_id                = contains(["premium", "ultimate"], lower(var.tier)) ? each.value.member_role_id : null
  skip_subresources_on_destroy  = each.value.skip_subresources_on_destroy
  unassign_issuables_on_destroy = each.value.unassign_issuables_on_destroy
}

// https://docs.gitlab.com/ee/user/group/custom_project_templates.html
// resource "gitlab_group_project_file_template" "this" {
//   for_each                 = {
//     for g in local.groups :
//     g.name => g.project_file_template != null ? g.project_file_template : {}
//   }
//   group_id                 = gitlab_group.this[each.value.name].id
//   file_template_project_id = try(each.value.project_file_template.file_template_project_id, null) //gitlab_project.this[each.value.project_file_template.file_template_project_id].id
//   depends_on               = [gitlab_group.this]
// }

resource "gitlab_group_protected_environment" "protected_environment" {
  count = var.protected_environment != null ? 1 : 0

  deploy_access_levels    = var.protected_environment.deploy_access_levels
  environment             = var.protected_environment.environment
  group                   = coalesce(var.protected_environment.group, one(gitlab_group.this[*].id))
  approval_rules          = var.protected_environment.approval_rules
  required_approval_count = var.protected_environment.required_approval_count
}

resource "gitlab_group_protected_environment" "protected_environments" {
  for_each = {
    for env in var.protected_environments : env.environment => env
    if length(var.protected_environments) > 0 && contains(["premium", "ultimate"], lower(var.tier))
  }

  deploy_access_levels    = each.value.deploy_access_levels
  environment             = each.value.environment
  group                   = coalesce(each.value.group, one(gitlab_group.this[*].id))
  approval_rules          = each.value.approval_rules
  required_approval_count = each.value.required_approval_count
}

resource "gitlab_group_saml_link" "this" {
  count = var.ldap_link != null ? 1 : 0

  group           = coalesce(var.saml_link.group, one(gitlab_group.this[*].id))
  access_level    = var.saml_link.access_level
  saml_group_name = var.saml_link.saml_group_name
}

resource "gitlab_group_variable" "variable" {
  count = var.variable != null ? 1 : 0

  group             = coalesce(var.variable.group, one(gitlab_group.this[*].id))
  key               = var.variable.key
  value             = var.variable.value
  protected         = var.variable.protected
  masked            = var.variable.masked
  environment_scope = var.variable.environment_scope
  description       = var.variable.description
  raw               = var.variable.raw
  variable_type     = var.variable.variable_type
}

resource "gitlab_group_variable" "variables" {
  for_each = {
    for v in var.variables : v.key => v
    if length(var.variables) > 0
  }

  group             = coalesce(each.value.group, one(gitlab_group.this[*].id))
  key               = each.value.key
  value             = each.value.value
  protected         = each.value.protected
  masked            = each.value.masked
  environment_scope = each.value.environment_scope
  description       = each.value.description
  raw               = each.value.raw
  variable_type     = each.value.variable_type
}

resource "gitlab_deploy_token" "deploy_token" {
  count = var.deploy_token != null ? 1 : 0

  group      = coalesce(var.deploy_token.group, one(gitlab_group.this[*].id))
  name       = var.deploy_token.name
  scopes     = var.deploy_token.scopes
  expires_at = var.deploy_token.expires_at
  username   = var.deploy_token.username
}

resource "gitlab_deploy_token" "deploy_tokens" {
  for_each = {
    for token in var.deploy_tokens : token.name => token
    if length(var.deploy_tokens) > 0
  }

  group      = coalesce(each.value.group, one(gitlab_group.this[*].id))
  name       = each.value.name
  scopes     = each.value.scopes
  expires_at = each.value.expires_at
  username   = each.value.username
}

data "gitlab_groups" "exists_groups" {
}

locals {
  exists_groups = { for group in data.gitlab_groups.exists_groups.groups : group.name => group }
}
