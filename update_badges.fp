pipeline "update_flowpipe_badges" {
  title = "Update README.md badges"

  step "pipeline" "create_flowpipe_branch" {
    pipeline = pipeline.create_branch
    args = {
      branch_name = replace(timestamp(),":","")
      repository_owner = "judell"
      repository_name = "flowpipe-readme"
    }
  }

  step "pipeline" "update_flowpipe_mods" {
    pipeline = pipeline.update_badge
    args = {
      branch_name      = step.pipeline.create_flowpipe_branch.output.branch_name
      repository_owner = "judell"
      repository_name  = "flowpipe-readme"
      file_path        = "README.md"
      target_index     = "production_HUB_FLOWPIPE_MODS"
      badge_type       = "mods"
    }
  }

  step "pipeline" "update_flowpipe_pipelines" {
    depends_on = [step.pipeline.update_flowpipe_mods]
    pipeline   = pipeline.update_badge
    args = {
      branch_name      = step.pipeline.create_flowpipe_branch.output.branch_name
      repository_owner = "judell"
      repository_name  = "flowpipe-readme"
      file_path        = "README.md"
      target_index     = "production_HUB_FLOWPIPE_MODS_PIPELINES"
      badge_type       = "pipelines"
    }
  }

  step "pipeline" "create_flowpipe_pr" {
    depends_on = [step.pipeline.update_flowpipe_pipelines]
    pipeline   = github.pipeline.create_pull_request
    args = {
      repository_owner = "judell"
      repository_name  = "flowpipe-readme"
      pull_request_title  = "Update Flowpipe badges"
      pull_request_body  = "Update Flowpipe badges"
      base_branch     = "main"
      head_branch     = step.pipeline.create_flowpipe_branch.output.branch_name
    }
  }

}

pipeline "update_steampipe_badges" {

  step "pipeline" "create_steampipe_branch" {
    pipeline = pipeline.create_branch
    args = {
      repository_owner = "judell"
      repository_name = "steampipe-readme"
      branch_name = replace(timestamp(),":","")
    }
  }

  step "pipeline" "update_steampipe_plugins" {
    pipeline   = pipeline.update_badge
    args = {
      branch_name      = step.pipeline.create_steampipe_branch.output.branch_name
      repository_owner = "judell"
      repository_name  = "steampipe-readme"
      file_path        = "README.md"
      target_index     = "production_HUB_STEAMPIPE_PLUGINS"
      badge_type       = "apis_supported"
    }
  }

  step "pipeline" "update_steampipe_tables" {
    depends_on = [step.pipeline.update_steampipe_plugins] 
    pipeline   = pipeline.update_badge
    args = {
      branch_name      = step.pipeline.create_steampipe_branch.output.branch_name
      repository_owner = "judell"
      repository_name  = "steampipe-readme"
      file_path        = "README.md"
      target_index     = "production_HUB_STEAMPIPE_PLUGIN_TABLES"
      badge_type       = "tables"
    }
  }

  step "pipeline" "update_steampipe_mods" {
    depends_on = [step.pipeline.update_steampipe_tables] 
    pipeline   = pipeline.update_badge
    args = {
      branch_name      = step.pipeline.create_steampipe_branch.output.branch_name
      repository_owner = "judell"
      repository_name  = "steampipe-readme"
      file_path        = "README.md"
      target_index     = "production_HUB_STEAMPIPE_MODS"
      badge_type       = "mods"
    }
  }

  step "pipeline" "update_steampipe_controls" {
    depends_on = [step.pipeline.update_steampipe_mods] 
    pipeline   = pipeline.update_badge
    args = {
      branch_name      = step.pipeline.create_steampipe_branch.output.branch_name
      repository_owner = "judell"
      repository_name  = "steampipe-readme"
      file_path        = "README.md"
      target_index     = "production_HUB_STEAMPIPE_MOD_CONTROLS"
      badge_type       = "controls"
    }
  }

  step "pipeline" "update_steampipe_benchmarks" {
    depends_on = [step.pipeline.update_steampipe_controls] 
    pipeline   = pipeline.update_badge
    args = {
      branch_name      = step.pipeline.create_steampipe_branch.output.branch_name
      repository_owner = "judell"
      repository_name  = "steampipe-readme"
      file_path        = "README.md"
      target_index     = "production_HUB_STEAMPIPE_MOD_BENCHMARKS"
      badge_type       = "benchmarks"
    }
  }

  step "pipeline" "update_steampipe_dashboards" {
    depends_on = [step.pipeline.update_steampipe_benchmarks] 
    pipeline   = pipeline.update_badge
    args = {
      branch_name      = step.pipeline.create_steampipe_branch.output.branch_name
      repository_owner = "judell"
      repository_name  = "steampipe-readme"
      file_path        = "README.md"
      target_index     = "production_HUB_STEAMPIPE_MOD_DASHBOARDS"
      badge_type       = "dashboards"
    }
  }

  step "pipeline" "create_steampipe_pr" {
    depends_on = [step.pipeline.update_steampipe_dashboards]
    pipeline   = github.pipeline.create_pull_request
    args = {
      repository_owner = "judell"
      repository_name  = "steampipe-readme"
      pull_request_title  = "Update Steampipe badges"
      pull_request_body  = "Update Steampipe badges"
      base_branch     = "main"
      head_branch     = step.pipeline.create_steampipe_branch.output.branch_name
    }
  }

}

