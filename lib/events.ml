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

let with_types v p = { p with types = Some v }

let with_branches v p = { p with branches = Some v }

let with_tags v p = { p with tags = Some v }

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
    registry_package = None;
    release = None;
    status = None;
    watch = None;
    workflow_run = None;
  }

let with_schedule v t = { t with schedule = Some v }

let with_workflow_dispatch v t = { t with workflow_dispatch = Some v }

let with_repository_dispatch v t = { t with repository_dispatch = Some v }

let with_check_run v t = { t with check_run = Some v }

let with_check_suite v t = { t with check_suite = Some v }

let with_create v t = { t with create = Some v }

let with_delete v t = { t with delete = Some v }

let with_deployment v t = { t with deployment = Some v }

let with_deployment_status v t = { t with deployment_status = Some v }

let with_fork v t = { t with fork = Some v }

let with_gollum v t = { t with gollum = Some v }

let with_issue_comment v t = { t with issue_comment = Some v }

let with_issues v t = { t with issues = Some v }

let with_label v t = { t with label = Some v }

let with_milestone v t = { t with milestone = Some v }

let with_page_build v t = { t with page_build = Some v }

let with_project v t = { t with project = Some v }

let with_project_card v t = { t with project_card = Some v }

let with_project_column v t = { t with project_column = Some v }

let with_public v t = { t with public = Some v }

let with_pull_request v t = { t with pull_request = Some v }

let with_pull_request_review v t = { t with pull_request_review = Some v }

let with_pull_request_review_comment v t =
  { t with pull_request_review_comment = Some v }

let with_pull_request_target v t = { t with pull_request_target = Some v }

let with_push v t = { t with push = Some v }

let with_registry_package v t = { t with registry_package = Some v }

let with_release v t = { t with release = Some v }

let with_status v t = { t with status = Some v }

let with_watch v t = { t with watch = Some v }

let with_workflow_run v t = { t with workflow_run = Some v }
