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
    pipeline   = pipeline.update_badge
    args = merge(local.powerpipe_update_args, {
      branch_name  = step.transform.extract_branch_name.value
      target_index = "production_HUB_POWERPIPE_MODS"
      data_source = "algolia"
      badge_type   = "mods"
    })
  }

  step "pipeline" "update_powerpipe_slack" {
    depends_on = [step.pipeline.update_powerpipe_mods]
    pipeline   = pipeline.update_badge
    args = merge(local.powerpipe_update_args, {
      branch_name  = step.transform.extract_branch_name.value
      data_source  = "slack"
    })
  }

  step "transform" "any_changed" {
    value = anytrue([
      step.pipeline.update_powerpipe_mods.output.any_changed,
      step.pipeline.update_powerpipe_slack.output.any_changed
    ])
  }

  step "pipeline" "create_powerpipe_pr" {
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
      branch_name = step.pipeline.create_powerpipe_branch.output.branch_name
    })
  }

}

