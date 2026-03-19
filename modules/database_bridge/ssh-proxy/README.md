# ssh-proxy

This directory holds scripts for building a custom Docker image that
can act as an SSH jump host based on
https://github.com/linuxserver/docker-openssh-server

We build a custom image in order to harden it, such as making sure the
logged in user cannot do anything but to proxy to the target database.

## Usage

### Build and push image to ECR

Apply this module the first time to create the ECR repository. After that, authenticate, build and push the image.
```
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 111111111111.dkr.ecr.eu-west-1.amazonaws.com
docker buildx build -t 111111111111.dkr.ecr.eu-west-1.amazonaws.com/my-app-ssh-proxy:latest --push .
```

### Setting up Domo

Domo's [PostgreSQL SSH Connector][ssh-connector] can be used to fetch data from
through this proxy.

[ssh-connector]: https://www.domo.com/appstore/connector/postgresql-ssh-connector

### Setting up Metabase

Add a [database connection](https://www.metabase.com/docs/v0.56/databases/connecting.html) to Metabase with [SSH tunneling](https://www.metabase.com/docs/v0.56/databases/ssh-tunnel).

## How it works

For how `./s6-rc.d` is structured, see [s6-overlay](https://github.com/just-containers/s6-overlay)
and [s6's documentation on service directories](https://skarnet.org/software/s6/servicedir.html).

## Environment variables

### For docker-openssh-server (upstream image)

* `PUBLIC_KEY` (required) - The public key to use for authentication.
  Domo must be configured with its private key counterpart.

### Our custom config

* `PERMIT_OPEN_HOST_VAR` (optional but recommended) - see below
* `PERMIT_OPEN_PORT_VAR` (optional but recommended) - if both are specified,
  the `PermitOpen` setting will be configured to limit the allowed local port
  forwarding destination
* Similarly, if both `PERMIT_OPEN_HOST_VARS` and `PERMIT_OPEN_PORT_VARS` are specified,
  they're parsed as comma-separated names of environment variables to construct
  the `PermitOpen` setting.
