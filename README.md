batsd-dash
==================

Configurable dashboard for [batsd-server](https://github.com/noahhl/batsd). 


### Install

To install batsd-dash, simply install the gem

    gem install batsd-dash


### Configuration

Here is a sample rackup file (`config.ru`):
    
    require 'batsd-dash'

    # set batsd server setting
    BatsdDash::ConnectionPool.settings = { host: 'localhost', port: 8127, pool_size: 4}

    # run the app
    run BatsdDash::App

Rack is very powerful. You can password protect your batsd-dash instance by using `Rack::Auth::Basic` or `Rack::Auth::Digest::MD5`.

### Development

We use Sass for CSS within this project. If you make any changes to the Sass files, ensure you recompile the CSS. This is done by running:
    
    compass compile --force --output-style compact --environment production --sass-dir lib/batsd-dash/sass --css-dir lib/public/css

Additionally, it is highly recommended you use thin for development since this app uses EventMachine.
