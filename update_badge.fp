pipeline "update_badge" {
  title = "Update a README badge, e.g. from mods-57-blue to mods-61-blue"

  param "cred" {
    type    = string
    default = "default"
  }

  param "branch_name" {
    type    = "string"
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

  param "target_index" {
    type    = string
    default = "production_HUB_FLOWPIPE_MODS_PIPELINES"
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
    pipeline = pipeline.query_algolia
    args = {
      name = param.target_index
    }
  }

  step "http" "update_file_contents" {
    method = "put"
    url    = "https://api.github.com/repos/${param.repository_owner}/${param.repository_name}/contents/${param.file_path}"
    request_headers = {
      Authorization = "Bearer ${credential.github[param.cred].token}"
      Content-Type  = "application/json"
    }
    request_body = jsonencode({
      message = param.commit_message
      content = base64encode(
        replace(
          step.pipeline.get_github_file.output.content,
          regex("(${param.badge_type}-\\d+-blue)", step.pipeline.get_github_file.output.content)[0],
          "${param.badge_type}-${step.pipeline.query_algolia.output.entries}-blue"
        )
      )
      sha    = step.pipeline.get_github_file.output.sha
      branch = param.branch_name
    })
  }

  output "algolia_entries" {
    value = step.pipeline.query_algolia
  }

  output "file_content" {
    value = step.pipeline.get_github_file.output.content
  }

  output "entries" {
    value = regex("${param.badge_type}-(\\d+)-blue", step.pipeline.get_github_file.output.content)[0]
  }

  output "target" {
    value = regex("(${param.badge_type}-\\d+-blue)", step.pipeline.get_github_file.output.content)[0]
  }


}


