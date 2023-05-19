(lang dune 3.3)
(name observer)
(generate_opam_files true)
(source (github mtelvers/ocurrent-observer))
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
  current_web
  current_git
  current_github
  current_docker
  current_slack
  ocluster-api
  capnp-rpc-unix
  fmt
  (lwt (>= 5.6.1))
  (cmdliner (>= 1.1.0))
  (ocaml (>= 4.08.0))
  (alcotest (and (>= 1.0.0) :with-test))
  (alcotest-lwt (and (>= 1.0.1) :with-test))))
