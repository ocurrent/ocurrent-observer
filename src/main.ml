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

let main config mode host slack =
  let channel = read_channel_uri slack in
  let engine = Current.Engine.create ~config (pipeline ~channel ~hosts:host) in
  let site = Current_web.Site.(v ~has_role:allow_all) ~name:"OCurrent Observer" (Current_web.routes engine) in
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
  Cmd.v info Term.(term_result (const main $ Current.Config.cmdliner $ Current_web.cmdliner $ hosts $ slack))

let () = exit @@ Cmd.eval cmd
