open Pipeline

let read_first_line path =
  let ch = open_in path in
  Fun.protect (fun () -> input_line ch)
    ~finally:(fun () -> close_in ch)

let read_channel_uri path =
  try
    let uri = read_first_line path in
    Current_slack.channel (Uri.of_string (String.trim uri))
  with ex ->
    Fmt.failwith "Failed to read slack URI from %S: %a" path Fmt.exn ex

let has_role_ocaml user role =
  match user with
  | None -> role = `Viewer || role = `Monitor         (* Unauthenticated users can only look at things. *)
  | Some user ->
    match Current_web.User.id user, role with
    | ("github:mtelvers"
      |"github:avsm"
      |"github:tmcgilchrist"
      ), _ -> true        (* These users have all roles *)
    | _ -> role = `Viewer

let main config mode auth host slack =
  let channel = read_channel_uri slack in
  let engine = Current.Engine.create ~config (pipeline ~channel ~hosts:host) in
  let authn = Option.map Current_github.Auth.make_login_uri auth in
  let has_role =
    if auth = None then Current_web.Site.allow_all
    else has_role_ocaml
  in
  let routes =
    Routes.(s "login" /? nil @--> Current_github.Auth.login auth) ::
    Current_web.routes engine in
  let site = Current_web.Site.v ?authn ~has_role ~name:"OCurrent Observer" routes in
  Lwt_main.run begin
    Lwt.choose [
      Current.Engine.thread engine;
      Current_web.run ~mode site;
    ]
  end

(* Command-line parsing *)

open Cmdliner

let hosts =
  Arg.required @@
  Arg.pos 0 Arg.(some (list string)) None @@
  Arg.info
    ~doc:"A comma-seperated list of hosts."
    ~docv:"HOSTS"
    []

let slack =
  Arg.required @@
  Arg.opt Arg.(some file) None @@
  Arg.info
    ~doc:"A file containing the URI of the endpoint for status updates."
    ~docv:"URI-FILE"
    ["slack"]

let cmd =
  let doc = "Monitor DNS and HTTPS." in
  let info = Cmd.info "observe" ~doc in
  Cmd.v info Term.(term_result (const main $
    Current.Config.cmdliner $
    Current_web.cmdliner $
    Current_github.Auth.cmdliner $
    hosts $
    slack))

let () = exit @@ Cmd.eval cmd
