type schedule = { cron : string } [@@deriving yaml]

type types = { types : string list option } [@@deriving yaml]

type workflow_dispatch = Yaml.value [@@deriving yaml]

type repository_dispatch = types [@@deriving yaml]

type push_or_pr = {
  types : string list option;
  branches : string list option;
  tags : string list option;
}
[@@deriving yaml]

val push_or_pr : push_or_pr
(** Default parameters for [push_or_pr] value *)

val with_types : string list -> push_or_pr -> push_or_pr

val with_branches : string list -> push_or_pr -> push_or_pr

val with_tags : string list -> push_or_pr -> push_or_pr

type t = {
  schedule : schedule option;
  workflow_dispatch : workflow_dispatch option;
  repository_dispatch : repository_dispatch option;
  check_run : types option;
  check_suite : types option;
  create : types option;
  delete : types option;
  deployment : types option;
  deployment_status : types option;
  fork : types option;
  gollum : types option;
  issue_comment : types option;
  issues : types option;
  label : types option;
  milestone : types option;
  page_build : types option;
  project : types option;
  project_card : types option;
  project_column : types option;
  public : types option;
  pull_request : push_or_pr option;
  pull_request_review : types option;
  pull_request_review_comment : types option;
  pull_request_target : types option;
  push : push_or_pr option;
  registry_package : types option;
  release : types option;
  status : types option;
  watch : types option;
  workflow_run : types option;
}
[@@deriving yaml]

val with_schedule : schedule -> t -> t

val with_workflow_dispatch : workflow_dispatch -> t -> t

val with_repository_dispatch : repository_dispatch -> t -> t

val with_check_run : types -> t -> t

val with_check_suite : types -> t -> t

val with_create : types -> t -> t

val with_delete : types -> t -> t

val with_deployment : types -> t -> t

val with_deployment_status : types -> t -> t

val with_fork : types -> t -> t

val with_gollum : types -> t -> t

val with_issue_comment : types -> t -> t

val with_issues : types -> t -> t

val with_label : types -> t -> t

val with_milestone : types -> t -> t

val with_page_build : types -> t -> t

val with_project : types -> t -> t

val with_project_card : types -> t -> t

val with_project_column : types -> t -> t

val with_public : types -> t -> t

val with_pull_request : push_or_pr -> t -> t

val with_pull_request_review : types -> t -> t

val with_pull_request_review_comment : types -> t -> t

val with_pull_request_target : types -> t -> t

val with_push : push_or_pr -> t -> t

val with_registry_package : types -> t -> t

val with_release : types -> t -> t

val with_status : types -> t -> t

val with_watch : types -> t -> t

val with_workflow_run : types -> t -> t

val event : t
