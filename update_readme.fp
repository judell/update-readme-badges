pipeline "update_readme" {
  title       = "Update README"

  step "pipeline" "update_mods" {
    pipeline = pipeline.update_file
    args = {
      target_index = "production_HUB_FLOWPIPE_MODS"
      badge_type = "mods"
    }
  }

  step "pipeline" "update_pipelines" {
    depends_on = [ step.pipeline.update_mods]
    pipeline = pipeline.update_file
    args = {
      target_index = "production_HUB_FLOWPIPE_MODS_PIPELINES"
      badge_type = "pipelines"
    }
  }

}
