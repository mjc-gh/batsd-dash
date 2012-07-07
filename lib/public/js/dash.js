// Location Hash wrapper script
// https://gist.github.com/2927857
var LocationHash=function(e){function n(){var e=location.hash.substr(1).split("&");t={};for(var n=0,r;r=e[n];n++){var i=r.split("="),s=i[1].split(",");t[i[0]]=s.length>1?s:s[0]}}function r(e){var n=[];for(var r in t){var i=t[r],s="=";if(e=="h")n.push(r+s+(i.join?i.join(","):i));else{i.join?s="[]=":i=[i];for(var o=0,u;u=i[o];o++)n.push(r+s+u)}}return n.join("&")}var t;return e(window).on("hashchange",n),n(),{params:function(e){return r(e)},get:function(e){return t[e]},set:function(e){for(var n in e){var i=e[n];i==undefined?delete t[n]:t[n]=i}location.hash=r("h")}}}(d3.select);


// TODO find a d3 datetimepicker (or make one)
// then drop jquery, jqueryui and datetimerpicker altogether
(function(){
	$('button').button();

	var now = Date.now();
	var defaults = [now - (1000 * 60 * 30), now];

	$('.date-time').datetimepicker().each(function(i){
		var input = $(this);
		var time = LocationHash.get(input.attr('name'));

		input.datetimepicker('setDate', new Date(time ? time * 1000 : defaults[i]));
	});
}());


// graphs using nv.d3
(function(){
	var validate = /counters|timers|gauges/;
	var inputs = d3.selectAll('.date-time')[0];

	var graph = d3.select('#main-graph svg');
	var view = d3.select('button');

	function set_time_params(){
		var map = {};
	
		for (var i = 0, elem; elem = inputs[i]; i++)
			map[elem.name] = +new Date(elem.value) / 1000;

		LocationHash.set(map);
	}

	function time_axis_formatter(resp){
		var format = { 600: '%x', 60: '%X', 10: '%X' }[resp.interval];

		return function(d){
			return d3.time.format(format)(new Date(d));
		};
	}

	function render_graph(){
		var params = LocationHash.params();

		if (!validate.test(params) && location.pathname != '/')
			return alert('Need to supply at least one counter, timer or gauge');

		d3.json('/data?'+ params, function(resp){
			nv.addGraph(function(){
				// initialize a new chart object
				var chart = nv.models.lineChart()
					.x(function(d){ return d[0]; })
					.y(function(d){ return d[1]; })
x=chart;
				// set xAxis tick format based up range and interval
				chart.xAxis.tickFormat(time_axis_formatter(resp))

				// bind data and render graph
				graph.datum(resp.results)
					.transition().duration(500)
					.call(chart);

				return chart;
			});
		});
	}

	// view button handler
	view.on('click', function(){
		set_time_params();
		render_graph();
	});

	// initial graph render
	render_graph();
}());
