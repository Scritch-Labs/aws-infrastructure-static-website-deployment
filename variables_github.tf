//  Github token
variable "github_token" {
  description = "Github token"
  sensitive = true
}

//  Github repo name
variable "github_repo_name" {
  description = "Github repo name"
}

// Main github branch variable
variable "main_branch" {
  description = "The main branch of the repository"
  default     = "main"
}

// Repo owner
variable "repo_owner" {
  description = "The owner of the repository"
}