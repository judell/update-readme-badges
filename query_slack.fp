pipeline "query_slack" {
  title = "Query Slack"

  step "query" "get_user_count" {
    connection_string = "postgres://steampipe@localhost:9193/steampipe"
    sql               = <<EOQ
      select count(*) from slack_user
    EOQ
  }

  output "user_count" {
    value = step.query.get_user_count.rows[0].count
  }

}