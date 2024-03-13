pipeline "update_flowpipe_badges" {
  title = "Update Flowpipe README.md badges"

  step "pipeline" "create_flowpipe_branch" {
    pipeline = github.pipeline.create_branch
    args     = local.flowpipe_branch_args
  }

  step "transform" "extract_branch_name" {
     value = replace(step.pipeline.create_flowpipe_branch.output.branch.response_body.ref, "refs/heads/", "")
  }

  output "branch_name" {
     value = step.transform.extract_branch_name.value
  }

  step "pipeline" "update_flowpipe_mods" {
    pipeline   = pipeline.update_badge
    args = merge(local.flowpipe_update_args, {
      branch_name  = step.transform.extract_branch_name.value
      target_index = "production_HUB_FLOWPIPE_MODS"
      data_source = "algolia"
      badge_type   = "mods"
    })

  }

  step "pipeline" "update_flowpipe_pipelines" {
    depends_on = [step.pipeline.update_flowpipe_mods]
    pipeline   = pipeline.update_badge
    args = merge(local.flowpipe_update_args, {
      branch_name  = step.transform.extract_branch_name.value
      target_index = "production_HUB_FLOWPIPE_MODS_PIPELINES"
      data_source  = "algolia"
      badge_type   = "pipelines"
    })
  }

  step "pipeline" "update_flowpipe_slack" {
    depends_on = [step.pipeline.update_flowpipe_pipelines]
    pipeline   = pipeline.update_badge
    args = merge(local.flowpipe_update_args, {
      branch_name  = step.transform.extract_branch_name.value
      data_source  = "slack"
    })
  }

  step "transform" "any_changed" {
    value = anytrue([
      step.pipeline.update_flowpipe_mods.output.any_changed,
      step.pipeline.update_flowpipe_pipelines.output.any_changed,
      step.pipeline.update_flowpipe_slack.output.any_changed,
    ])
  }

  step "pipeline" "create_flowpipe_pr" {
    depends_on = [step.pipeline.update_flowpipe_pipelines]
    if         = step.transform.any_changed.value
    pipeline   = github.pipeline.create_pull_request
    args = merge(local.flowpipe_pr_args, {
      head_branch = step.transform.extract_branch_name.value
    })
  }

  step "pipeline" "delete_branch" {
    if       = !step.transform.any_changed.value
    pipeline = github.pipeline.delete_branch
    args = merge(local.flowpipe_branch_args, {
      branch_name = step.transform.extract_branch_name.value
    })
  }

}

