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
  registry_packagee : types option;
  release : types option;
  status : types option;
  watch : types option;
  workflow_run : types option;
}
[@@deriving yaml]

let push_or_pr : push_or_pr = { types = None; branches = None; tags = None }

let event : t =
  {
    schedule = None;
    workflow_dispatch = None;
    repository_dispatch = None;
    check_run = None;
    check_suite = None;
    create = None;
    delete = None;
    deployment = None;
    deployment_status = None;
    fork = None;
    gollum = None;
    issue_comment = None;
    issues = None;
    label = None;
    milestone = None;
    page_build = None;
    project = None;
    project_card = None;
    project_column = None;
    public = None;
    pull_request = None;
    pull_request_review = None;
    pull_request_review_comment = None;
    pull_request_target = None;
    push = None;
    registry_packagee = None;
    release = None;
    status = None;
    watch = None;
    workflow_run = None;
  }
