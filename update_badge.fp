pipeline "update_badge" {
  title = "Update a README badge, e.g. from mods-57-blue to mods-61-blue"

  param "cred" {
    type    = string
    default = "default"
  }

  param "branch_name" {
    type    = string
    default = "main"
  }

  param "repository_owner" {
    type    = string
    default = "judell"
  }

  param "repository_name" {
    type    = string
    default = "test"
  }

  param "file_path" {
    type    = string
    default = "README.md"
  }

  param "commit_message" {
    type    = string
    default = "updated ${timestamp()}"
  }

  param "data_source" {
    type    = string
    default = "algolia"
  }

  param "target_index" {
    type    = string
  }

  param "badge_type" {
    type    = string
    default = "pipelines"
  }

  step "pipeline" "get_github_file" {
    pipeline = pipeline.get_github_file
    args = {
      repository_owner = param.repository_owner
      repository_name  = param.repository_name
      file_path        = param.file_path
      branch_name      = param.branch_name
    }
  }

  step "pipeline" "query_algolia" {
    if       = param.data_source == "algolia"
    pipeline = pipeline.query_algolia
    args = {
      name = param.target_index
    }
  }

  step "pipeline" "query_slack" {
    if       = param.data_source == "slack"
    pipeline = pipeline.query_slack
  }

  step "transform" "common_args" {
    value = {
      cred               = param.cred
      repository_owner   = param.repository_owner
      repository_name    = param.repository_name
      file_path          = param.file_path
      branch_name        = param.branch_name
      commit_message     = param.commit_message
      original_content   = step.pipeline.get_github_file.output.content
      sha                = step.pipeline.get_github_file.output.sha      
    }
  }

  step "pipeline" "update_file_contents_algolia" {
    if = param.data_source == "algolia"

    pipeline = pipeline.update_file_contents

    args = merge(step.transform.common_args.value, {
      target_regex       = "(${param.badge_type}-\\d+-blue)",
      replacement_string = "${param.badge_type}-${step.pipeline.query_algolia.output.entries}-blue"
    })

  }

  step "pipeline" "update_file_contents_slack" {
    if = param.data_source == "slack"

    pipeline = pipeline.update_file_contents

    args = merge(step.transform.common_args.value, {
      target_regex       = "(slack-\\d+-blue)",
      replacement_string = "slack-${step.pipeline.query_slack.output.user_count}-blue"
    })

  }

  output "any_changed" {
    value = anytrue(
      [
        param.data_source == "algolia" ? step.pipeline.update_file_contents_algolia.output.changed : false,
        param.data_source == "slack" ? step.pipeline.update_file_contents_slack.output.changed : false
      ]
    )
  }

}


