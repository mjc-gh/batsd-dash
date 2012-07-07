batsd-dash
==========

Configurable dashboard for [batsd-server](https://github.com/noahhl/batsd).

## Setup

### Install

To install batsd-dash, simply install the gem

    gem install batsd-dash

### Configuration

Here is a sample rackup file (`config.ru`):
    
    require 'batsd-dash'

    # set batsd server setting BatsdDash::ConnectionPool.settings = { host:'localhost', port: 8127, pool_size: 8 }

    # run the app run BatsdDash::App

Rack is very powerful. You can password protect your batsd-dash instance 
by using `Rack::Auth::Basic` or `Rack::Auth::Digest::MD5`.

## Viewing Graphs

Graphs are rendered using (nv.d3)[http://nvd3.com/], a powerful graph
and visualization library.

Since rendering is all done on the client, we make use of hash based
navigation in order to reduce the amount of requests and while 
maintaining 'linkability'.

For example, to view a graph for the counter `a.b` metric, you would make 
the following request from your browser:

    /graph#counters=a.b

The graph view will provide you with a date time picker to make selecting
different start and stop time ranges easier. Graphs are updated when you 
press the 'View' button.

It's possible to view more than one metric at the same time. To do this, 
visit the following route from your browser:

    /graph#counters=a.b,c.d

You can also view different datatypes at the same time:

    /graph#counters=a.b&timers=x.y

__NOTE__: As of now, a single y-axis is used when datatypes are mixed.
Soon, we will add support for multiple axis when viewing mixed types.

## Data API

The application provides a simple JSON-based API for accessing data from
the batds data server. The data API accepts similar parameters and the
graph view but uses traditional query strings: 

    /data?counters[]=a.b&counters[]=c.d&timers[]=x.y

The data API also accepts a `start` and `stop` unix timestamp parameter 
foraccessing different ranges of data. Note that, the data API will
only respond with JSON if the `Accept` header to set to `application/json`!

## Graph and Render Options

1. Zerofill:
   __TODO__ Add details about zerofill


## Development

### Asset Management

We use Sass for CSS within this project. If you make any changes to the Sass
files, ensure you recompile the CSS. This is done by running:
    
    compass compile --force --output-style compact --environment production --sass-dir lib/batsd-dash/sass --css-dir lib/public/css

Additionally, it is highly recommended you use thin for development since this
app uses EventMachine.

## About

This is project is maintained and developed by the people behind [BreakBase](http://breakbase.com) ([@mikeycgto](https://twitter.com/mikeycgto) and [@btoconnor](https://twitter.com/btoconnor))
