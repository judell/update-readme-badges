pipeline "get_file" {
  title       = "Get file"

  param "cred" {
    type        = string
    default     = "default"
  }

  param "repository_owner" {
    type        = string
    default = "judell"
  }

  param "repository_name" {
    type        = string
    default = "test"
  }

  param "file_path" {
    type        = string
    default = "README.md"
  }

  step "http" "get_file_contents" {
    method = "get"
    url    = "https://api.github.com/repos/${param.repository_owner}/${param.repository_name}/contents/${param.file_path}"
    request_headers = {
      Authorization = "Bearer ${credential.github[param.cred].token}"
    }
  }  

  output "content" {
    value       = base64decode(step.http.get_file_contents.response_body.content)
  }

  output "sha" {
    value       = step.http.get_file_contents.response_body.sha
  }


}
