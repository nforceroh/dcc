# DCC

This image runs the Distributed Checksum Clearinghouse (DCC) `dccifd` daemon.
It is intended as a network service for mail filters such as Rspamd, which can
ask DCC to identify bulk mail.

The image is based on
[`ghcr.io/nforceroh/alpine-base:3.24`](https://github.com/nforceroh/alpine-base)
and uses s6-overlay to supervise `dccifd`.

## What the image contains

- Alpine `dcc`, `dcc-dccifd`, and `dcc-extras` packages
- The DCC configuration directory at `/var/dcc`
- `dccifd` listening on TCP port `10045`
- A persistent s6 service that runs as the `dcc` user

## Configuration

| Variable | Image default | Description |
| --- | --- | --- |
| `SERVICE` | `dcc` | Declared value; not consumed by the bundled startup code |
| `UID` | `dcc` | Declared environment value; `dccifd` itself runs as the `dcc` system user |
| `PUID` | `100` | Base-image app-user UID setting |
| `PGID` | `101` | Base-image app-user GID setting |
| `DCCIFD_ARGS` | `-b -d -I dcc -SHELO -Smail_host -SSender -SList-ID -p *,10045,10.0.0.0/8` | Arguments passed to `dccifd`; adjust the permitted client range and options for your network |

`DCCIFD_ARGS` is expanded by the service shell when `dccifd` starts. Keep
network access restricted to trusted mail-filter clients; do not expose
`10045` to the public Internet.

## Usage

Build and run locally:

```sh
make build
make run
```

The Makefile publishes port `10045` on the host. For a deployment, attach DCC
and its client (for example Rspamd) to a private container network and point the
client at `dcc:10045`. Override the default client range with `DCCIFD_ARGS` as
needed:

```sh
docker run -d --name dcc \
  --network mail \
  -e 'DCCIFD_ARGS=-b -d -I dcc -SHELO -Smail_host -SSender -SList-ID -p *,10045,10.0.0.0/8' \
  ghcr.io/nforceroh/dcc:latest
```

The image does not declare a Docker volume. Configuration and data are initially
provided under `/var/dcc`; mount that directory if your deployment needs to
preserve runtime changes.

## Local development

```sh
make build   # build ghcr.io/nforceroh/dcc:dev
make test    # build and run the smoke-test harness
make run     # run with port 10045 published
```

CI publishes the image through the shared workflow in
[`nforceroh/.github`](https://github.com/nforceroh/.github).
