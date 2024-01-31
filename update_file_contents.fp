pipeline "update_file_contents" {
  param "cred" {
    type    = string
    default = "default"
  }

  param "repository_owner" {
    type = string
  }

  param "repository_name" {
    type = string
  }

  param "file_path" {
    type = string
  }

  param "branch_name" {
    type    = string
    default = "main"
  }

  param "commit_message" {
    type = string
  }

  param "original_content" {
    type = string
  }

  param "target_regex" {
    type = string
  }

  param "replacement_string" {
    type = string
  }

  param "sha" {
    type = string // SHA of the file to update
  }

  step "transform" "replace_content" {
    value = replace(
      param.original_content,
      regex(param.target_regex, param.original_content)[0],
      param.replacement_string
    )
  }

  step "transform" "changed" {
    value = param.original_content != step.transform.replace_content.value
  }

  output "original_content" {
    value = substr(param.original_content, 0, 200)
  }

  output "changed_content" {
    value = substr(step.transform.replace_content.value, 0, 200)
  }

  output "changed" {
    value = step.transform.changed.value
  }

  step "http" "update_github_file" {
    if     = step.transform.changed.value
    method = "put"
    url    = "https://api.github.com/repos/${param.repository_owner}/${param.repository_name}/contents/${param.file_path}"
    request_headers = {
      Authorization = "Bearer ${credential.github[param.cred].token}"
      Content-Type  = "application/json"
    }
    request_body = jsonencode({
      message = param.commit_message
      content = base64encode(step.transform.replace_content.value)
      sha     = param.sha
      branch  = param.branch_name
    })
  }

}
