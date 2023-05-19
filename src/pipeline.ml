open Current.Syntax

let () = Prometheus_unix.Logging.init ()

let notify_status ~channel x =
  let s =
    let+ state = Current.catch x in
    Fmt.str "@mtelvers testing: %a" (Current_term.Output.pp Current.Unit.pp) state
  in
  Current.all [ Current_slack.post channel ~key:"ocurrent-observer-status" s; x ]

let pipeline_per_host host =
  let halfhourly = Current_cache.Schedule.v ~valid_for:(Duration.of_min 30) () in
  let minute = Current_cache.Schedule.v ~valid_for:(Duration.of_min 10) () in
  let dig = Current_curl.resolve ~schedule:halfhourly ~fqdn:host in
  Current_curl.expand dig |> Current.list_iter (module Current_curl.Address) @@ fun address ->
  let fetch = Current_curl.fetch ~schedule:minute ~address in
  Current.all [ fetch ]

let pipeline ~channel ~hosts () =
  notify_status ~channel (Current.all (List.map pipeline_per_host hosts))
