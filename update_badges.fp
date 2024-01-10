pipeline "update_badges" {
  title       = "Update README.md badges"

  step "pipeline" "update_mods" {
    pipeline = pipeline.update_badge
    args = {
      repository_owner = "judell"
      repository_name = "test"
      file_path = "README.md"
      target_index = "production_HUB_FLOWPIPE_MODS"
      badge_type = "mods"
    }
  }

  step "pipeline" "update_pipelines" {
    depends_on = [ step.pipeline.update_mods ]
    pipeline = pipeline.update_badge
    args = {
      repository_owner = "judell"
      repository_name = "test"
      file_path = "README.md"
      target_index = "production_HUB_FLOWPIPE_MODS_PIPELINES"
      badge_type = "pipelines"
    }
  }

}
