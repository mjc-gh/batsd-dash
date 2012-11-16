// Location Hash wrapper script
// https://gist.github.com/2927857
var LocationHash=function(a){function d(){var a=location.hash.substr(1).split("&");b={};for(var d=0,e;e=a[d];d++){var f=e.split("=");if(f.length){var g=f[1].split(",");b[f[0]]=g.length>1?g:g[0]}}for(var d=0,h;h=c[d];d++)h()}function e(a,c){var d=[];c=c||b;for(var e in c){var f=c[e],g="=";if(a=="h")d.push(e+g+(f.join?f.join(","):f));else{f.join?g="[]=":f=[f];for(var h=0,i;i=f[h];h++)d.push(e+g+i)}}return d.join("&")}var b,c=[];return a(window).on("hashchange",d),d(),{params:function(a){return e(a)},changed:function(a){c.push(a)},build:function(a,b){return e(b||"q",a)},get:function(a){return b[a]},set:function(a){for(var c in a){var d=a[c];d==undefined?delete b[c]:b[c]=d}location.hash=e("h")}}}(d3.select);

(function(){
  // TODO drop this after nvd3 tooltip is updated to handle relative parents
  var show_tooltip = nv.tooltip.show;
  nv.tooltip.show = function(pos, content, gravity, dist, parentContainer, classes) {
    var container = show_tooltip.apply(this, arguments);

    container.style.top = parseInt(container.style.top, 10) - parentContainer.offsetTop + 'px';
    container.style.left = parseInt(container.style.left, 10) - parentContainer.offsetLeft + 'px';
  };
}());


var BatsdDash = (function(){
  var validate = /counters|timers|gauges/;
  var timeFormats = { 600: '%x', 60: '%X', 10: '%X' };
  var loader, loadCount = 0;

  function append_error(el, err){
    el.append('em').text(err ? err.message : 'An Error Occurred!');
  }

  function render_graph(el, params){
    el.select('em').remove();

    if (!loader)
      loader = d3.select('#loading');

    if (loadCount++ === 0)
      loader.attr('class', 'fade in');

    d3.json('/data?' + params, function(resp){
      if (--loadCount === 0)
        loader.attr('class', 'fade out');

      resp ? create_graph(el, resp) : append_error(el, resp);
    });
  }

  function create_graph(el, resp){
    nv.addGraph(function(){
      // initialize a new chart object
      var chart = nv.models.lineChart()
      .x(function(d){ return d[0]; })
      .y(function(d){ return d[1]; });

      // set xAxis tick format based up range and interval
      var format = timeFormats[resp.interval] || '%X';

      // set tickFormat
      chart.xAxis.tickFormat(function(d){
        return d3.time.format(format)(new Date(d));
      });

      // force 0 into yAxis domain
      chart.forceY([0]);

      // bind data and render graph
      var svg = el.select('svg');

      if (svg.empty())
        svg = el.append('svg');

      svg.datum(resp.results).transition().duration(500).call(chart);

      return chart;
    });
  }

  return {
    render: function(el, params){
      if (!validate.test(params) && location.pathname != '/')
        return alert('Need to supply at least one counter, timer or gauge');

      render_graph(el, params);
    }
  };
}());

