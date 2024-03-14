pipeline "update_steampipe_badges" {
  title = "Update Steampipe README.md badges"

  step "pipeline" "create_steampipe_branch" {
    pipeline = github.pipeline.create_branch
    args     = local.steampipe_branch_args
  }

  step "transform" "extract_branch_name" {
     value = replace(step.pipeline.create_steampipe_branch.output.branch.response_body.ref, "refs/heads/", "")
  }

  step "pipeline" "update_steampipe_plugins" {
    pipeline   = pipeline.update_badge
    args = merge(local.steampipe_update_args, {
      branch_name  = step.transform.extract_branch_name.value
      target_index = "production_HUB_STEAMPIPE_PLUGINS"
      data_source  = "algolia"
      badge_type   = "apis_supported"
    })
  }

  step "pipeline" "update_steampipe_slack" {
    depends_on = [step.pipeline.update_steampipe_plugins]
    pipeline   = pipeline.update_badge
    args = merge(local.steampipe_update_args, {
      branch_name  = step.transform.extract_branch_name.value
      data_source  = "slack"
    })
  }

  step "transform" "any_changed" {
    value = anytrue([
      step.pipeline.update_steampipe_plugins.output.any_changed,
      step.pipeline.update_steampipe_slack.output.any_changed
    ])
  }

  step "pipeline" "create_steampipe_pr" {
    if         = step.transform.any_changed.value
    pipeline   = github.pipeline.create_pull_request
    args = merge(local.steampipe_pr_args, {
      head_branch = step.transform.extract_branch_name.value
    })
  }

  step "pipeline" "delete_branch" {
    if       = !step.transform.any_changed.value
    pipeline = github.pipeline.delete_branch
    args = merge(local.steampipe_branch_args, {
      branch_name = step.pipeline.create_steampipe_branch.output.branch_name
    })
  }

}

