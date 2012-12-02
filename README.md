Batsd-dash
==========

Batds-dash Configurable dashboard for [batsd-server](https://github.com/noahhl/batsd).
The frontend uses [NVD3](http://nvd3.org/) for rendering graphs. The backend uses 
[Sinatra](github.com/sinatra/sinatra/) for actual web application.

The backend server is designed to use a simple threaded connection pool. It is
suggested that you run Batsd-dash on JRuby or Rubinius in order to take
full advantage of threads.

### Documentation

  * [Installation and
    Configuration](https://github.com/mikeycgto/batsd-dash/wiki/Installation-and-Configuration)
  * [Data API](https://github.com/mikeycgto/batsd-dash/wiki/Data-API)
  * [Custom Pages](https://github.com/mikeycgto/batsd-dash/wiki/Custom-Pages)
  * [Contributing](https://github.com/mikeycgto/batsd-dash/wiki/Contributing)

### About

This is project is maintained and developed by [@mikeycgto](https://twitter.com/mikeycgto) 
and [@btoconnor](https://twitter.com/btoconnor) mainly for use on [BreakBase](http://breakbase.com).

### License

Copyright (c) 2012 Michael J Coyne

Permission is hereby granted, free of charge, to any person obtaining a copy of this 
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
