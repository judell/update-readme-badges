pipeline "update_flowpipe_badges" {
  title = "Update Flowpipe README.md badges"

  step "pipeline" "create_flowpipe_branch" {
    pipeline = pipeline.create_branch
    args     = local.flowpipe_branch_args
  }

  output "branch_name" {
    value = step.pipeline.create_flowpipe_branch.output.branch_name
  }

  step "pipeline" "update_flowpipe_mods" {
    depends_on = [step.pipeline.create_flowpipe_branch]
    pipeline   = pipeline.update_badge
    args = merge(local.flowpipe_update_args, {
      branch_name  = step.pipeline.create_flowpipe_branch.output.branch_name
      target_index = "production_HUB_FLOWPIPE_MODS"
      badge_type   = "mods"
    })

  }

  step "pipeline" "update_flowpipe_pipelines" {
    depends_on = [step.pipeline.update_flowpipe_mods]
    pipeline   = pipeline.update_badge
    args = merge(local.flowpipe_update_args, {
      branch_name  = step.pipeline.create_flowpipe_branch.output.branch_name
      target_index = "production_HUB_FLOWPIPE_MODS_PIPELINES"
      badge_type   = "pipelines"
    })
  }

  step "transform" "any_changed" {
    value = anytrue([
      step.pipeline.update_flowpipe_mods.output.any_changed,
      step.pipeline.update_flowpipe_pipelines.output.any_changed
    ])
  }

  step "pipeline" "create_flowpipe_pr" {
    depends_on = [step.pipeline.update_flowpipe_pipelines]
    if         = step.transform.any_changed.value
    pipeline   = github.pipeline.create_pull_request
    args = merge(local.flowpipe_pr_args, {
      head_branch = step.pipeline.create_flowpipe_branch.output.branch_name
    })
  }

  step "pipeline" "delete_branch" {
    if       = !step.transform.any_changed.value
    pipeline = pipeline.delete_branch
    args = merge(local.flowpipe_branch_args, {
      branch_name = step.pipeline.create_flowpipe_branch.output.branch_name
    })
  }

}

pipeline "update_steampipe_badges" {
  title = "Update Steampipe README.md badges"

  step "pipeline" "create_steampipe_branch" {
    pipeline = pipeline.create_branch
    args     = local.steampipe_branch_args
  }

  step "pipeline" "update_steampipe_plugins" {
    depends_on = [step.pipeline.create_steampipe_branch]
    pipeline   = pipeline.update_badge
    args = merge(local.steampipe_update_args, {
      branch_name  = step.pipeline.create_steampipe_branch.output.branch_name
      target_index = "production_HUB_STEAMPIPE_PLUGINS"
      badge_type   = "apis_supported"
    })
  }

  step "pipeline" "update_steampipe_controls" {
    depends_on = [step.pipeline.update_steampipe_plugins]
    pipeline   = pipeline.update_badge
    args = merge(local.steampipe_update_args, {
      branch_name  = step.pipeline.create_steampipe_branch.output.branch_name
      target_index = "production_HUB_STEAMPIPE_MOD_CONTROLS"
      badge_type   = "controls"
    })
  }

  step "pipeline" "update_steampipe_dashboards" {
    depends_on = [step.pipeline.update_steampipe_controls]
    pipeline   = pipeline.update_badge
    args = merge(local.steampipe_update_args, {
      branch_name  = step.pipeline.create_steampipe_branch.output.branch_name
      target_index = "production_HUB_STEAMPIPE_MOD_DASHBOARDS"
      badge_type   = "dashboards"
    })
  }

  step "pipeline" "update_steampipe_slack" {
    depends_on = [step.pipeline.update_steampipe_dashboards]
    pipeline   = pipeline.update_badge
    args = merge(local.steampipe_update_args, {
      branch_name  = step.pipeline.create_steampipe_branch.output.branch_name
      data_source  = "slack"
      target_index = ""
      badge_type   = ""
    })
  }

  step "transform" "any_changed" {
    value = anytrue([
      step.pipeline.update_steampipe_plugins.output.any_changed,
      step.pipeline.update_steampipe_controls.output.any_changed,
      step.pipeline.update_steampipe_dashboards.output.any_changed,
      step.pipeline.update_steampipe_slack.output.any_changed
    ])
  }

  step "pipeline" "create_steampipe_pr" {
    depends_on = [step.pipeline.update_steampipe_slack]
    if         = step.transform.any_changed.value
    pipeline   = github.pipeline.create_pull_request
    args = merge(local.steampipe_pr_args, {
      head_branch = step.pipeline.create_steampipe_branch.output.branch_name
    })
  }

  step "pipeline" "delete_branch" {
    if       = !step.transform.any_changed.value
    pipeline = pipeline.delete_branch
    args = merge(local.steampipe_branch_args, {
      branch_name = step.pipeline.create_steampipe_branch.output.branch_name
    })
  }

}

