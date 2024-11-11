//  Create the github repository
resource "github_repository" "repo" {
  name        = var.github_repo_name
  visibility = "private"
  vulnerability_alerts = false
}