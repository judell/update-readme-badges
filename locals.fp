locals {
  repository_owner = "judell"
  base_branch_args = {
    branch_name      = replace(timestamp(), ":", "")
    repository_owner = "judell"
  }

  base_update_args = {
    branch_name      = ""
    repository_owner = "judell"
    file_path        = "README.md"
    target_index     = ""
    badge_type       = ""
  }

  base_pr_args = {
    repository_owner   = "judell"
    pull_request_title = "Update badges"
    pull_request_body  = "Update badges"
    base_branch        = "main"
    head_branch        = ""
  }
  
  repositories = {
    flowpipe  = "flowpipe-readme",
    steampipe = "steampipe-readme",
    powerpipe = "powerpipe-readme"
  }
}

locals {
  flowpipe_branch_args = merge(
    local.base_branch_args,
    { repository_name = local.repositories.flowpipe }
  )

  flowpipe_update_args = merge(
    local.base_update_args,
    { repository_name = local.repositories.flowpipe }
  )

  flowpipe_pr_args = merge(
    local.base_pr_args,
    {
      repository_name    = local.repositories.flowpipe,
      pull_request_title = "Update Flowpipe badges",
      pull_request_body  = "Update Flowpipe badges"
    }
  )

  steampipe_branch_args = merge(
    local.base_branch_args,
    { repository_name = local.repositories.steampipe }
  )

  steampipe_update_args = merge(
    local.base_update_args,
    { repository_name = local.repositories.steampipe }
  )

  steampipe_pr_args = merge(
    local.base_pr_args,
    {
      repository_name    = local.repositories.steampipe,
      pull_request_title = "Update Steampipe badges",
      pull_request_body  = "Update Steampipe badges"
    }
  )

  powerpipe_branch_args = merge(
    local.base_branch_args,
    { repository_name = local.repositories.powerpipe }
  )

  powerpipe_update_args = merge(
    local.base_update_args,
    { repository_name = local.repositories.powerpipe }
  )

  powerpipe_pr_args = merge(
    local.base_pr_args,
    {
      repository_name    = local.repositories.powerpipe,
      pull_request_title = "Update Powerpipe badges",
      pull_request_body  = "Update Powerpipe badges"
    }
  )
}
