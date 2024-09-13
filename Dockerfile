FROM ocaml/opam:ubuntu-24.04-ocaml-4.14 AS build
RUN sudo apt-get update && sudo apt-get install libffi-dev libev-dev m4 pkg-config libsqlite3-dev libgmp-dev libssl-dev capnproto graphviz -y --no-install-recommends
RUN sudo ln -f /usr/bin/opam-2.2 /usr/bin/opam && opam init --reinit -ni
RUN opam option solver=builtin-0install
COPY --chown=opam observer.opam /src/
WORKDIR /src
RUN opam install -y --deps-only .
ADD --chown=opam . .
RUN opam config exec -- dune build ./_build/install/default/bin/ocurrent-observer

FROM ubuntu:noble
RUN apt-get update && apt-get install libffi-dev libev4 openssh-client gnupg2 dumb-init git graphviz libsqlite3-dev ca-certificates netbase rsync iputils-ping dnsutils curl -y --no-install-recommends
WORKDIR /var/lib/ocurrent-observer
ENTRYPOINT ["dumb-init", "/usr/local/bin/ocurrent-observer"]
COPY --from=build /src/_build/install/default/bin/ocurrent-observer /usr/local/bin/
