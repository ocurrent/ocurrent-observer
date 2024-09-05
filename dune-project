(lang dune 3.3)
(name observer)
(generate_opam_files true)
(source (github ocurrent/ocurrent-observer))
(authors "mark.elvers@tunbury.org")
(maintainers "mark.elvers@tunbury.org")
(formatting disabled)
(package
 (name observer)
 (synopsis "Observe website and certificates")
 (depends
  ppx_deriving_yojson
  ppx_deriving
  logs
  (current (>= 0.5))
  current_git
  current_github
  current_slack
  current_web
  ocluster-api
  capnp-rpc-unix
  (tyxml (>= 4.4.0))
  (github-unix (>= 4.4.0))
  (hex (>= 1.4.0))
  (prometheus-app (>= 1.2))
  session-cohttp-lwt
  (routes (>= 2.0.0))
  (multipart_form-lwt (>= 0.4.0))
  (ansi (>= 0.5.0))
  (csv (>= 2.4))
  (crunch (and :build (>= 3.3.0)))
  fmt
  (lwt (>= 5.6.1))
  (cmdliner (>= 1.1.0))
  (ocaml (>= 4.08.0))
  (alcotest (and (>= 1.0.0) :with-test))
  (alcotest-lwt (and (>= 1.0.1) :with-test))))
