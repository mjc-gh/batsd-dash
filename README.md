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

    # set batsd server setting BatsdDash::ConnectionPool.settings = { host:
'localhost', port: 8127, pool_size: 4}

    # run the app run BatsdDash::App

Rack is very powerful. You can password protect your batsd-dash instance by
using `Rack::Auth::Basic` or `Rack::Auth::Digest::MD5`.

## Usage

### Data API

The application provides a simple JSON-based API for accessing data from the
batds data server. There are 3 main routes provide, one for each datatype. These
routes are `/counters`, `/timers` and `/gauge`. For example, the following
request would access data for counter based metric:

    /counters?metric=a.b

It's possible to access data for more than one metric within a single request.
For example, the following request route will return data for both the `a.b`
metric and the `c.d` metric:

    /counters?metrics[]=a.b&metrics[]=c.d

The data API also accepts a `start` and `stop` unix timestamp parameter for
accessing different ranges of data.

Note that, the data API will only respond with JSON if the `Accept` header to
set to `application/json`!

### Viewing Graphs

Graphs are rendered using Flot, a JavaScript library which uses the canvas
element to create graphs. Since rendering is all done on the client, we make use
of hash based navigation in order to reduce the amount of requests and while
maintaining 'linkability'.

For example, to view a graph for the `a.b` metric, you would make the following
request from your browser:

    /counters#metrics=a.b

The graph view will provide you with a date time picker to make selecting
different start and stop time ranges easier. Graphs are updated when you press
the 'View' button.

Much like the data API, it's possible to view more than one metric at the same
time. To do this, visit the following route from your browser:

    /counters#metrics=a.b,c.d

_TODO_ when no data or only a single point is available, the graph is a little
strange looking. This is something we will improve upon. Additionally, we also
plan to add some sort of tree-based widget for selecting different metrics to
view. 

Feel free to submit pull requests with these features!

### Zerofill

_TODO_ add details about zerofill. 

_TODO_ Setup client to accept pass along no-zerofill options.

## Development

### Asset Management

We use Sass for CSS within this project. If you make any changes to the Sass
files, ensure you recompile the CSS. This is done by running:
    
    compass compile --force --output-style compact --environment production --sass-dir lib/batsd-dash/sass --css-dir lib/public/css

Additionally, it is highly recommended you use thin for development since this
app uses EventMachine.
