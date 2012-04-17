# Offsite V3 - Rails App for Rails 3.x


## Mac Packaging: port or brew

We can use MacPorts (port) or Homebrew (brew).

In general, port is older and installs more complete setups; brew is newer and installs more specific packages.

To use port, we needed these:

    port install libyaml
    port install postgres91 postgres91-server


## Postgres

To install the pg gem for the first time on Mac OSX Snow Leopard, we needed this:

    sudo env ARCHFLAGS="-arch x86_64" gem install pg -- --with-pgsql-include=/opt/local/include/postgresql91 --with-pgsql-lib=/opt/local/lib/postgresql91

The /opt/local for postgres was created by our port install.


## Gem and Bundler setup

To bundle, we're trying this bash alias:
                   '
    alias bi="sudo env RUBYOPT='-rpsych' bundle install --binstubs --path vendor/bundle"

To install on Mac OSX Snow Leopard:

    bundle config build.pg --with-pg-config=/opt/local/lib/postgresql91/bin/pg_config


## Changes

2012-04-12 Created new Rails 3.2.3 project. Removed FasterCSV because it's built in to Ruby now.
