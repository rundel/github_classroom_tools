github_api_add_team = function(repo, team_id, permission){
  gh::gh(
    "PUT /teams/:team_id/repos/:owner/:repo",
    team_id = team_id,
    owner = get_repo_owner(repo),
    repo = get_repo_name(repo),
    permission = permission,
    .token = github_get_token()
  )
}

#' @rdname repo_add_member
#' @export
repo_add_team = function(repo, team,
                            permission = c("push", "pull", "admin")) {

  permission = match.arg(permission)
  arg_is_chr(repo, team)

  org = unique(get_repo_owner(repo))

  d = tibble::tibble(repo, team)
  d = team_id_lookup(d, get_specific_teams(org, team))

  purrr::pwalk(
    d,
    function(repo, team, id) {
      res = purrr::safely(github_api_add_team)(
        repo = repo,
        team_id = id,
        permission = permission
      )

      status_msg(
        res,
        glue::glue("Added team {usethis::ui_value(team)} to repo {usethis::ui_value(repo)}."),
        glue::glue("Failed to add team {usethis::ui_value(team)} to repo {usethis::ui_value(repo)}.")
      )
    }
  )
}