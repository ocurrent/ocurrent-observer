ARG arch
FROM --platform=linux/${arch} ocaml/opam:debian-12-ocaml-4.14@sha256:45b04e2a4c933c57549382045dfac12cb7e872cace0456f92f4b022066e48111 as build

RUN sudo apt-get update && sudo apt-get install libffi-dev libev-dev m4 pkg-config libsqlite3-dev libgmp-dev libssl-dev capnproto graphviz -y --no-install-recommends
RUN cd ~/opam-repository && git fetch -q origin master && opam update
COPY --chown=opam \
	ocurrent/current_docker.opam \
	ocurrent/current_github.opam \
	ocurrent/current_git.opam \
	ocurrent/current.opam \
	ocurrent/current_rpc.opam \
	ocurrent/current_slack.opam \
	ocurrent/current_web.opam \
	ocurrent/current_health_check.opam \
	/src/ocurrent/
WORKDIR /src
RUN opam pin add -yn current_docker.dev "./ocurrent" && \
    opam pin add -yn current_github.dev "./ocurrent" && \
    opam pin add -yn current_git.dev "./ocurrent" && \
    opam pin add -yn current.dev "./ocurrent" && \
    opam pin add -yn current_rpc.dev "./ocurrent" && \
    opam pin add -yn current_slack.dev "./ocurrent" && \
    opam pin add -yn current_web.dev "./ocurrent" && \
    opam pin add -yn current_health_check.dev "./ocurrent"
COPY --chown=opam observer.opam /src/
RUN opam pin -yn add .
RUN opam install -y --deps-only .
ADD --chown=opam . .
RUN opam config exec -- dune build ./_build/install/default/bin/ocurrent-observer

FROM debian:12
RUN apt-get update && apt-get install libffi-dev libev4 openssh-client gnupg2 dumb-init git graphviz libsqlite3-dev ca-certificates netbase rsync dnsutils curl -y --no-install-recommends
WORKDIR /var/lib/ocurrent-observer
ENTRYPOINT ["dumb-init", "/usr/local/bin/ocurrent-observer"]
COPY --from=build /src/_build/install/default/bin/ocurrent-observer /usr/local/bin/
