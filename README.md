Exdocker
========

Mix task to turn an Elixir release into a Docker image.

Usage:

    MIX_ENV=prod mix docker

This will run `mix release` to create the release, create a Dockerfile
and then use `docker build` to build the image on the docker
daemon. The image will be named after the project's application name.

Example output:

```
~/src/phoenixtest> MIX_ENV=prod mix docker
==> Building docker image for phoenixtest
==> Building release with MIX_ENV=prod.
==> Generating relx configuration...
==> Merging custom relx configuration from rel/relx.config...
==> Generating sys.config...
==> Generating boot script...
==> Conform: Loading schema...
==> Conform: No schema found, conform will not be packaged in this release!
==> Performing protocol consolidation...
==> Generating release...
===> Missing beam file ts_client_rcv <<"/home/arjan/erl/r17/lib/erlang/lib/tsung-1.5.1/ebin/ts_client_rcv.beam">>
==> Generating nodetool...
==> Packaging release...
==> The release for phoenixtest-0.0.1 is ready!
==> You can boot a console running your release with `$ rel/phoenixtest/bin/phoenixtest console`
==> Docker image created successfully as 'phoenixtest'.

~/src/phoenixtest> docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
phoenixtest         latest              eb54acffcae4        6 seconds ago       727.5 MB
```

The resulting image can be run using docker:

    docker run -t -i phoenixtest

Which will start the Erlang node and the generated release.
