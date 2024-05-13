variable "tier" {
  type        = string
  description = "Gitlab tier"
  default     = "free"
  validation {
    condition     = contains(["free", "premium", "ultimate"], lower(var.tier))
    error_message = "The tier value must be one of `free`, `premium`, `ultimate`"
  }
}

variable "group" {
  description = "Gitlab group configuration"
  type = object({
    name                               = string           // The name of the group.
    path                               = string           // The path of the group.
    auto_devops_enabled                = optional(bool)   // Default to Auto DevOps pipeline for all projects within this group.
    avatar                             = optional(string) // A local path to the avatar image to upload.
    avatar_hash                        = optional(string) // The hash of the avatar image.
    default_branch_protection          = optional(number)
    description                        = optional(string)
    emails_enabled                     = optional(bool)             // Enable email notifications.
    extra_shared_runners_minutes_limit = optional(number)           // Additional CI/CD minutes for this group.
    ip_restriction_ranges              = optional(list(string), []) // A list of IP addresses or subnet masks to restrict group access.
    lfs_enabled                        = optional(bool)             // Enable/disable Large File Storage (LFS) for the projects in this group.
    membership_lock                    = optional(bool)             // Users cannot be added to projects in this group.
    mentions_disabled                  = optional(bool)             // Disable the capability of a group from getting mentioned.
    parent_id                          = optional(number)           //  Id of the parent group (creates a nested group).
    prevent_forking_outside_group      = optional(bool, false)      // When enabled, users can not fork projects from this group to external namespaces.
    project_creation_level             = optional(string)           // Determine if developers can create projects in the group. 
    push_rules = optional(list(object({
      author_email_regex            = optional(string) // All commit author emails must match this regex, e.g. @my-company.com$
      branch_name_regex             = optional(string) // All branch names must match this regex, e.g. (feature|hotfix)\/*
      commit_committer_check        = optional(bool)   // Only commits pushed using verified emails are allowed. Note This attribute is only supported in GitLab versions >= 16.4.
      commit_message_negative_regex = optional(string) // No commit message is allowed to match this regex, for example ssh\:\/\/.
      commit_message_regex          = optional(string) // All commit messages must match this regex, e.g. Fixed \d+\..*.
      deny_delete_tag               = optional(bool)   // Deny deleting a tag.
      file_name_regex               = optional(string) // Filenames matching the regular expression provided in this attribute are not allowed, for example, (jar|exe)$.
      max_file_size                 = optional(number) // Maximum file size (MB) allowed.
      member_check                  = optional(bool)   // Allows only GitLab users to author commits.
      prevent_secrets               = optional(bool)   // GitLab will reject any files that are likely to contain secrets.
      reject_unsigned_commits       = optional(bool)   // Only commits signed through GPG are allowed. Note This attribute is only supported in GitLab versions >= 16.4.
    })))
    request_access_enabled            = optional(bool)       // Allow users to request member access.
    require_two_factor_authentication = optional(bool)       // Require all users in this group to setup Two-factor authentication.
    share_with_group_lock             = optional(bool)       // Prevent sharing a project with another group within this group.
    shared_runners_minutes_limit      = optional(number, 0)  // Maximum number of monthly CI/CD minutes for this group.
    shared_runners_setting            = optional(string)     // Enable or disable shared runners for a group’s subgroups and projects.
    subgroup_creation_level           = optional(string)     // Allowed to create subgroups.
    two_factor_grace_period           = optional(number, 48) // Defaults to 48. Time before Two-factor authentication is enforced (in hours).
    visibility_level                  = optional(string)     // The group's visibility.
    wiki_access_level                 = optional(string)     // The group's wiki access level. Only available on Premium and Ultimate plans.
  })
  validation {
    condition = var.group != null && var.group.default_branch_protection != null ? contains(
    [0, 1, 2, 3, 4], var.group.default_branch_protection) : true
    error_message = "Valid values are: 0, 1, 2, 3, 4"
  }
  validation {
    condition = var.group != null && var.group.project_creation_level != null ? contains(
    ["noone", "maintainer", "developer"], lower(var.group.project_creation_level)) : true
    error_message = "Valid values are: noone, maintainer, developer"
  }
  validation {
    condition = var.group != null && var.group.shared_runners_setting != null ? contains(
      [
        "enabled", "disabled_and_overridable",
        "disabled_and_unoverridable",
        "disabled_with_override"
    ], lower(var.group.shared_runners_setting)) : true
    error_message = <<EOT
      Valid values are: 
      enabled, disabled_and_overridable, 
      disabled_and_unoverridable, disabled_with_override.
      EOT
  }
  validation {
    condition = var.group != null && var.group.subgroup_creation_level != null ? contains(
    ["owner", "maintainer"], lower(var.group.subgroup_creation_level)) : true
    error_message = "Valid values are: owner, maintainer."
  }
  validation {
    condition = var.group != null && var.group.visibility_level != null ? contains(
    ["private", "internal", "public"], lower(var.group.visibility_level)) : true
    error_message = "Valid values are: private, internal, public."
  }
  validation {
    condition = var.group != null && var.group.wiki_access_level != null && can(regex("[A-Za-z]{7,}?", var.group.wiki_access_level)) ? (
      var.group.wiki_access_level == "disabled" ||
      var.group.wiki_access_level == "private" ||
    var.group.wiki_access_level == "enabled") : true
    error_message = "Valid values are: disabled, private, enabled."
  }
  default = null
}

variable "access_tokens" {
  description = "Configure group access tokens"
  type = list(object({
    group        = optional(string)          // The ID or full path of the group.
    name         = optional(string)          // The name of the group access token.
    scopes       = optional(set(string), []) // The scopes of the group access token.
    access_level = optional(string, "maintainer")
    expires_at   = optional(string) // When the token will expire, YYYY-MM-DD format.
    rotation_configuration = optional(object({
      expiration_days    = number // The duration (in days) the new token should be valid for.
      rotate_before_days = number //  The duration (in days) before the expiration when the token should be rotated.
    }))
  }))
  validation {
    condition = alltrue([
      for token in var.access_tokens : alltrue([for scope in token.scopes : contains(
        [
          "api", "read_api", "read_user", "k8s_proxy",
          "read_registry", "write_registry", "read_repository", "write_repository",
          "create_runner, ai_features", "k8s_proxy", "read_observability",
          "write_observability"
        ],
        scope
      )])
    ])
    error_message = <<EOT
      Valid values are: api, read_api, read_user, k8s_proxy, 
      read_registry, write_registry, read_repository, write_repository, 
      create_runner, ai_features, k8s_proxy, read_observability, 
      write_observability
      EOT
  }
  validation {
    condition = alltrue([
      for token in var.access_tokens : contains(
        [
          "no one", "minimal", "guest", "reporter",
          "developer", "maintainer", "owner", "master"
        ],
      token.access_level)
    ])
    error_message = <<EOT
      Valid values are: no one, minimal, guest, reporter, 
      developer, maintainer, owner, master.
      EOT
  }
  default = []
}

variable "badges" {
  description = "Configure group badges."
  type = list(object({
    group     = string           // The id of the group to add the badge to.
    image_url = string           // The image url which will be presented on group overview.
    link_url  = string           // The url linked with the badge.
    name      = optional(string) // The name of the badge.
  }))
  default = []

}

variable "custom_attributes" {
  description = "Configure group custom attributes"
  type = list(object({
    group = number // The id of the group.
    key   = string // Key for the Custom Attribute.
    value = string // Value for the Custom Attribute.
  }))
  default = []
}

variable "labels" {
  description = "Group labels"
  type = list(object({
    color       = string           // The color of the label given in 6-digit hex notation with leading '#' sign (e.g. #FFAABB) or one of the CSS color names.
    group       = string           // The name or id of the group to add the label 
    name        = string           // The name of the label.
    description = optional(string) // The description of the label.
  }))
  default = []
}

variable "variables" {
  description = "Group variables"
  type = list(object({
    group             = string                      // The name or id of the group.
    key               = string                      // The name of the variable.
    value             = string                      // The value of the variable.
    description       = optional(string)            // The description of the variable.
    environment_scope = optional(string, "*")       //  The environment scope of the variable. 
    masked            = optional(bool, false)       // Hide the value of the variable
    protected         = optional(bool, false)       // Pass variable only protected branches and tags
    raw               = optional(bool, false)       // Whether the variable is treated as a raw string
    variable_type     = optional(string, "env_var") // The type of a variable. Valid values are: env_var, file
  }))
  default = []
}

variable "epic_boards" {
  description = "Group epic boards"
  type = list(object({
    group = string // The ID or URL-encoded path of the group owned by the authenticated user.
    name  = string // The name of the board.
    lists = optional(list(object({
      label_id = optional(string) // The ID of the label the list should be scoped to.
    })))                          // The list of epic board lists
  }))
  default  = null
  nullable = true
}

variable "hooks" {
  description = "Group hooks"
  type = list(object({
    group                      = string           // The ID or full path of the group.
    url                        = string           // The url of the hook to invoke.
    confidential_issues_events = optional(bool)   // Invoke the hook for confidential issues events.
    confidential_note_events   = optional(bool)   // Invoke the hook for confidential notes events.
    custom_webhook_template    = optional(string) // Set a custom webhook template.
    deployment_events          = optional(bool)   // Invoke the hook for deployment events.
    enable_ssl_verification    = optional(bool)   // Enable ssl verification when invoking the hook.
    issues_events              = optional(bool)   // Invoke the hook for issues events.
    job_events                 = optional(bool)   // Invoke the hook for job events.
    merge_requests_events      = optional(bool)   // Invoke the hook for merge requests.
    note_events                = optional(bool)   // Invoke the hook for notes events.
    pipeline_events            = optional(bool)   // Invoke the hook for pipeline events.
    push_events                = optional(bool)   // Invoke the hook for push events.
    push_events_branch_filter  = optional(string) // Invoke the hook for push events on matching branches only.
    releases_events            = optional(bool)   // Invoke the hook for releases events.
    subgroup_events            = optional(bool)   // Invoke the hook for subgroup events.
    tag_push_events            = optional(bool)   // Invoke the hook for tag push events.
    token                      = optional(string) // A token to present when invoking the hook. The token is not available for imported resources.
    wiki_page_events           = optional(bool)   // Invoke the hook for wiki page events.
  }))
  default = null
}

variable "issue_boards" {
  description = "Group issue boards"
  type = list(object({
    group  = string                     // The ID or URL-encoded path of the group owned by the authenticated user.
    name   = string                     // The name of the board.
    labels = optional(list(string), []) // The list of label names which the board should be scoped to.
    lists = optional(list(object({
      label_id = string             // The ID of the label the list should be scoped to.
      position = optional(number)   // The explicit position of the list within the board, zero based.
    })), [])                        // The list of issue board lists
    milestone_id = optional(number) // The milestone the board should be scoped to.
  }))
  default = null
}

variable "ldap_link" {
  description = "Group LDAP integration"
  type = object({
    group         = string           // The ID or URL-encoded path of the group
    ldap_provider = string           // The name of the LDAP provider as stored in the GitLab database.
    cn            = optional(string) // The CN of the LDAP group to link with. Required if filter is not provided.
    filter        = optional(string) // The LDAP filter for the group. Required if cn is not provided. Requires GitLab Premium or above.
    force         = optional(bool)   // If true, then delete and replace an existing LDAP link if one exists.
    group_access  = optional(string) // Minimum access level for members of the LDAP group. Valid values are: no one, minimal, guest, reporter, developer, maintainer, owner, master
  })
  validation {
    condition = var.ldap_link != null && can(var.ldap_link.group_access) ? contains(
      [
        "no one", "minimal", "guest", "reporter",
        "developer", "maintainer", "owner", "master"
      ],
      var.ldap_link.group_access
    ) : true
    error_message = <<EOT
      Valid values are: no one, minimal, guest, reporter, 
      developer, maintainer, owner, master
      EOT
  }
  default = null
}

variable "membership" {
  description = "Users group membership"
  type = list(object({
    access_level                  = string           // Access level for the member. Valid values are: no one, minimal, guest, reporter, developer, maintainer, owner, master.
    group_id                      = string           // The id of the group.
    user_id                       = string           // The id of the user.
    expires_at                    = optional(string) // Expiration date for the group membership. Format: YYYY-MM-DD
    member_role_id                = optional(number) // The ID of a custom member role. Only available for Ultimate instances.
    skip_subresources_on_destroy  = optional(bool)   // Whether the deletion of direct memberships of the removed member in subgroups and projects should be skipped.
    unassign_issuables_on_destroy = optional(bool)   // Whether the removed member should be unassigned from any issues or merge requests inside a given group or project.
  }))
  validation {
    condition = length(var.membership) > 0 ? alltrue([
      for member in var.membership : contains(
        [
          "no one", "minimal", "guest", "reporter",
          "developer", "maintainer", "owner", "master"
        ],
        member.access_level
    )]) : true
    error_message = <<EOT
      Valid values are: no one, minimal, guest, reporter, 
      developer, maintainer, owner, master
      EOT
  }
  default = []

}

variable "protected_environments" {
  description = "Group protected environment"
  type = list(object({
    deploy_access_levels = list(object({
      access_level           = optional(string) // Levels of access required to deploy to this protected environment. Valid values are developer, maintainer.
      group_id               = optional(number) // The ID of the group allowed to deploy to this protected environment. The group must be a sub-group under the given group.
      group_inheritance_type = optional(number) // Group inheritance allows deploy access levels to take inherited group membership into account. Valid values are 0, 1. 0
      user_id                = optional(number) // The ID of the user allowed to deploy to this protected environment.
    }))                                         // Array of access levels allowed to deploy
    environment = string                        // The deployment tier of the environment. Valid values are production, staging, testing, development, other
    group       = string                        // The ID or full path of the group which the protected environment is created against.
    approval_rules = optional(list(object({
      access_level           = optional(string)    // Levels of access allowed to approve a deployment to this protected environment. Valid values are developer, maintainer
      group_id               = optional(number)    // The ID of the group allowed to approve a deployment to this protected environment. The group must be a sub-group under the given group.
      group_inheritance_type = optional(number, 0) // Group inheritance allows access rules to take inherited group membership into account. Valid values are 0, 1. 0
      required_approvals     = optional(number)    // The number of approval required to allow deployment to this protected environment. 
      user_id                = optional(string)    // The ID of the user allowed to approve a deployment to this protected environment.
    })))                                           // Array of approval rules to deploy
    required_approval_count = optional(number)     // The number of approvals required to deploy to this environment.
  }))
  default = []
}

variable "saml_link" {
  description = "Group SAML intergation"
  type = object({
    access_level    = string // Access level for members of the SAML group. Valid values are: guest, reporter, developer, maintainer, owner
    group           = string // The ID or path of the group to add the SAML Group Link to.
    saml_group_name = string //  The name of the SAML group.
  })
  validation {
    condition = var.saml_link != null && can(var.saml_link.access_level) ? contains(
      ["guest", "reporter", "developer", "maintainer", "owner"],
      var.saml_link.access_level
    ) : true
    error_message = "Valid values are: guest, reporter, developer, maintainer, owner."
  }
  default = null

}

variable "share_groups" {
  description = "Group share with another group"
  type = list(object({
    group_access   = string           // The access level to grant the group. Valid values are: no one, minimal, guest, reporter, developer, maintainer, owner, master
    group_id       = string           // The id of the main group to be shared.
    share_group_id = string           // The id of the additional group with which the main group will be shared.
    expires_at     = optional(string) // Share expiration date. Format: YYYY-MM-DD
  }))
  validation {
    condition = length(var.share_groups) > 0 ? alltrue([
      for group in var.share_groups : contains(
        [
          "no one", "minimal", "guest", "reporter",
          "developer", "maintainer", "owner", "master"
        ],
        group.group_access
    )]) : true
    error_message = <<EOT
      Valid values are: no one, minimal, guest, reporter, 
      developer, maintainer, owner, master
      EOT
  }
  default = []
}

variable "deploy_tokens" {
  description = "Group deploy tokens"
  type = list(object({
    name       = string           // A name to describe the deploy token with.
    scopes     = list(string)     // Valid values: read_repository, read_registry, read_package_registry, write_registry, write_package_registry.
    expires_at = optional(string) // Time the token will expire it, RFC3339 format.
    group      = optional(string) // The name or id of the group to add the deploy token to.
    project    = optional(string) // The name or id of the project to add the deploy token to.
    username   = optional(string) // A username for the deploy token. Default is gitlab+deploy-token-{n}
  }))
  default = []
}

variable "compliance_frameworks" {
  description = "Manage the lifecycle of a compliance framework on top-level groups"
  type = list(object({
    color                            = string                // New color representation of the compliance framework in hex format. e.g. #FCA121.
    description                      = string                // Description for the compliance framework.
    name                             = string                // Name for the compliance framework.
    namespace_path                   = string                // Full path of the namespace to add the compliance framework to.
    default                          = optional(bool, false) // Set this compliance framework as the default framework for the group
    pipeline_configuration_full_path = optional(string)      // Full path of the compliance pipeline configuration stored in a project repository, such as .gitlab/.compliance-gitlab-ci.yml@compliance/hipaa
  }))
  default = []
}