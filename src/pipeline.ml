open Current.Syntax

let () = Prometheus_unix.Logging.init ()

let notify_status ~channel x =
  let s =
    let+ state = Current.catch x in
    Fmt.str "@mtelvers testing: %a" (Current_term.Output.pp Current.Unit.pp) state
  in
  Current.all [ Current_slack.post channel ~key:"ocurrent-observer-status" s; x ]

let pipeline_per_host host =
  let hourly = Current_cache.Schedule.v ~valid_for:(Duration.of_hour 1) () in
  let halfhourly = Current_cache.Schedule.v ~valid_for:(Duration.of_min 30) () in
  let dig = Current_health_check.dig ~schedule:hourly ~fqdn:host in
  Current_health_check.expand dig |> Current.list_iter (module Current_health_check.Address) @@ fun address ->
  let curl = Current_health_check.curl ~schedule:halfhourly ~address in
  let ping = Current_health_check.ping ~schedule:halfhourly ~address in
  Current.all [ curl; ping ]

let pipeline ~channel ~hosts () =
  notify_status ~channel (Current.all (List.map pipeline_per_host hosts))
