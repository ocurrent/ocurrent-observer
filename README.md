# Observer

This repository contains an [OCurrent][] pipeline that resolves the
name, validates the certificates, tries to download from the website,
and then posts the results to a Slack channel.

# Building locally

```shell
opam switch create . 4.14.1 --deps-only -y
dune build
```

# Running on a Raspberry PI

I am using an older Raspberry PI which needs an arm/v7 binary which can be built like this.

```shell
docker buildx build -t mtelvers/ocurrent-observer:latest --platform linux/arm/v7 .
```

On the PI itself, install the dependencies, extract the image and run it.

```shell
apt install libev-dev dnsutils graphviz
docker run --rm --entrypoint cat mtelvers/ocurrent-observer /usr/local/bin/ocurrent-observer > ocurrent-observer
chmod +x ocurrent-observer
sudo ./ocurrent-observer --port 80 --slack ./slack.secret www.ocaml.org,opam.ocaml.org,images.ci.ocaml.org,deploy.ci.ocaml.org,opam-repo.ci.ocaml.org
```

[OCurrent]: https://github.com/ocurrent/ocurrent
[pipeline.ml]: ./src/pipeline.ml
