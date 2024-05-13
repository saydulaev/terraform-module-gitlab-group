// Lookup the share group id 
data "gitlab_group" "share_group_id" {
  for_each = {
    for group in var.share_groups : group.share_group_id => group
    if length(var.share_groups) > 0
  }

  full_path = each.value.share_group_id

  depends_on = [
    gitlab_group.this
  ]
}

// Lookup group id | share_group_id
data "gitlab_group" "group_id" {
  for_each = {
    for group in var.share_groups : group.group_id => group
    if length(var.share_groups) > 0
  }

  full_path = each.value.group_id

  depends_on = [
    gitlab_group.this
  ]
}

resource "gitlab_group_share_group" "this" {
  for_each = {
    for group in var.share_groups : group.share_group_id => group
    if length(var.share_groups) > 0
  }

  group_id       = data.gitlab_group.group_id[each.value.group_id].id
  share_group_id = data.gitlab_group.share_group_id[each.value.share_group_id].id
  group_access   = each.value.group_access
  expires_at     = each.value.expires_at
}