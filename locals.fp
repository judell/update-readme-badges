locals {
  repository_owner          = "judell"
  flowpipe_repository_name  = "flowpipe-readme"
  steampipe_repository_name = "steampipe-readme"
}

locals {

  flowpipe_branch_args = {
    branch_name      = replace(timestamp(), ":", "")
    repository_owner = local.repository_owner
    repository_name  = local.flowpipe_repository_name
  }

  flowpipe_update_args = {
    branch_name      = ""
    repository_owner = local.repository_owner
    repository_name  = local.flowpipe_repository_name
    file_path        = "README.md"
    target_index     = ""
    badge_type       = ""
  }

  flowpipe_pr_args = {
    repository_owner   = local.repository_owner
    repository_name    = local.flowpipe_repository_name
    pull_request_title = "Update Flowpipe badges"
    pull_request_body  = "Update Flowpipe badges"
    base_branch        = "main"
    head_branch        = ""
  }

}

locals {

  steampipe_branch_args = {
    branch_name      = replace(timestamp(), ":", "")
    repository_owner = local.repository_owner
    repository_name  = local.steampipe_repository_name
  }

  steampipe_update_args = {
    branch_name      = ""
    repository_owner = local.repository_owner
    repository_name  = local.steampipe_repository_name
    file_path        = "README.md"
    target_index     = ""
    badge_type       = ""
  }

  steampipe_pr_args = {
    repository_owner   = local.repository_owner
    repository_name    = local.steampipe_repository_name
    pull_request_title = "Update Steampipe badges"
    pull_request_body  = "Update Steampipe badges"
    base_branch        = "main"
    head_branch        = ""
  }

}



