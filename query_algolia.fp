pipeline "query_algolia" {
  title       = "Query Algolia"

  param "name" {
    type  = "string"
  }

  step "query" "get_indexes" {
    connection_string = "postgres://steampipe@localhost:9193/steampipe"
    sql = <<EOQ
      select name, entries from algolia_index where name = '${param.name}'
    EOQ
  }

  output "entries" {
    value = step.query.get_indexes.rows[0].entries
  }

}