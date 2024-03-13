locals {
  powerpipe_branch_args = {
    branch_name      = replace(timestamp(), ":", "")
    repository_owner = local.repository_owner
    repository_name  = "powerpipe-readme"
  }

  powerpipe_update_args = {
    branch_name      = ""
    repository_owner = local.repository_owner
    repository_name  = "powerpipe-readme"
    file_path        = "README.md"
    target_index     = ""
    badge_type       = ""
  }

  powerpipe_pr_args = {
    repository_owner   = local.repository_owner
    repository_name    = "powerpipe-readme"
    pull_request_title = "Update Powerpipe badges"
    pull_request_body  = "Update Powerpipe badges"
    base_branch        = "main"
    head_branch        = ""
  }
}

pipeline "update_powerpipe_badges" {
  title = "Update Powerpipe README.md badges"

  step "pipeline" "create_powerpipe_branch" {
    pipeline = github.pipeline.create_branch
    args     = local.powerpipe_branch_args
  }

  step "transform" "extract_branch_name" {
    value = replace(step.pipeline.create_powerpipe_branch.output.branch.response_body.ref, "refs/heads/", "")
  }

  step "pipeline" "update_powerpipe_mods" {
    pipeline = pipeline.update_badge
    args = merge(local.powerpipe_update_args, {
      branch_name  = step.transform.extract_branch_name.value
      target_index = "production_HUB_POWERPIPE_MODS"
      badge_type   = "mods"
    })
  }

  step "pipeline" "update_powerpipe_slack" {
    depends_on = [step.pipeline.update_powerpipe_mods]
    pipeline   = pipeline.update_badge
    args = merge(local.powerpipe_update_args, {
      branch_name  = step.transform.extract_branch_name.value
      data_source  = "slack"
      target_index = ""
      badge_type   = "slack"
    })
  }

  step "pipeline" "update_powerpipe_maintained_by" {
    depends_on = [step.pipeline.update_powerpipe_slack]
    // Assuming "maintained by" doesn't need a dynamic badge update or uses a different data source
    // Details on how to update this badge should be added here
  }

  step "transform" "any_changed" {
    value = anytrue([
      step.pipeline.update_powerpipe_mods.output.any_changed,
      step.pipeline.update_powerpipe_slack.output.any_changed,
      // Include condition for "maintained by" badge update check if applicable
    ])
  }

  step "pipeline" "create_powerpipe_pr" {
    depends_on = [step.pipeline.update_powerpipe_maintained_by]
    if         = step.transform.any_changed.value
    pipeline   = github.pipeline.create_pull_request
    args = merge(local.powerpipe_pr_args, {
      head_branch = step.transform.extract_branch_name.value
    })
  }

  step "pipeline" "delete_branch" {
    if       = !step.transform.any_changed.value
    pipeline = github.pipeline.delete_branch
    args = merge(local.powerpipe_branch_args, {
      branch_name = step.transform.extract_branch_name.value
    })
  }

}
