pipeline "update_flowpipe_badges" {
  title = "Update README.md badges"

  step "pipeline" "update_flowpipe_mods" {
    pipeline = pipeline.update_badge
    args = {
      repository_owner = "judell"
      repository_name  = "test"
      file_path        = "README.md"
      target_index     = "production_HUB_FLOWPIPE_MODS"
      badge_type       = "mods"
    }
  }

  step "pipeline" "update_flowpipe_pipelines" {
    depends_on = [step.pipeline.update_flowpipe_mods]
    pipeline   = pipeline.update_badge
    args = {
      repository_owner = "judell"
      repository_name  = "test"
      file_path        = "README.md"
      target_index     = "production_HUB_FLOWPIPE_MODS_PIPELINES"
      badge_type       = "pipelines"
    }
  }

}

pipeline "update_steampipe_badges" {

  step "pipeline" "update_steampipe_plugins" {
    pipeline   = pipeline.update_badge
    args = {
      repository_owner = "judell"
      repository_name  = "test"
      file_path        = "README.md"
      target_index     = "production_HUB_STEAMPIPE_PLUGINS"
      badge_type       = "apis_supported"
    }
  }

  step "pipeline" "update_steampipe_tables" {
    depends_on = [step.pipeline.update_steampipe_plugins] 
    pipeline   = pipeline.update_badge
    args = {
      repository_owner = "judell"
      repository_name  = "test"
      file_path        = "README.md"
      target_index     = "production_HUB_STEAMPIPE_PLUGIN_TABLES"
      badge_type       = "tables"
    }
  }

  step "pipeline" "update_steampipe_mods" {
    depends_on = [step.pipeline.update_steampipe_tables] 
    pipeline   = pipeline.update_badge
    args = {
      repository_owner = "judell"
      repository_name  = "test"
      file_path        = "README.md"
      target_index     = "production_HUB_STEAMPIPE_MODS"
      badge_type       = "mods"
    }
  }

  step "pipeline" "update_steampipe_controls" {
    depends_on = [step.pipeline.update_steampipe_mods] 
    pipeline   = pipeline.update_badge
    args = {
      repository_owner = "judell"
      repository_name  = "test"
      file_path        = "README.md"
      target_index     = "production_HUB_STEAMPIPE_MOD_CONTROLS"
      badge_type       = "controls"
    }
  }

  step "pipeline" "update_steampipe_benchmarks" {
    depends_on = [step.pipeline.update_steampipe_controls] 
    pipeline   = pipeline.update_badge
    args = {
      repository_owner = "judell"
      repository_name  = "test"
      file_path        = "README.md"
      target_index     = "production_HUB_STEAMPIPE_MOD_BENCHMARKS"
      badge_type       = "benchmarks"
    }
  }

  step "pipeline" "update_steampipe_dashboards" {
    depends_on = [step.pipeline.update_steampipe_benchmarks] 
    pipeline   = pipeline.update_badge
    args = {
      repository_owner = "judell"
      repository_name  = "test"
      file_path        = "README.md"
      target_index     = "production_HUB_STEAMPIPE_MOD_DASHBOARDS"
      badge_type       = "dashboards"
    }
  }

}
