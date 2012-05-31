batsd-dash
==================

Configurable dashboard for [batsd-server](https://github.com/noahhl/batds). 


### Install

    git clone git://github.com/mikeycgto/batsd-dash && cd batsd-dash && gem build batsd-dash && gem install

### Configuration

Here is a sample rackup file (`config.ru`):

    require 'batsd-dash'

    # connection info for batsd data server 
    BatsdDash.set :batsd_server, 'localhost:8127'
