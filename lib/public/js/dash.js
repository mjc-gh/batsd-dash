// Location Hash wrapper script
// https://gist.github.com/2927857
var LocationHash=function(e){function r(){var e=location.hash.substr(1).split("&");t={};for(var r=0,i;i=e[r];r++){var s=i.split("=");if(s.length){var o=s[1].split(",");t[s[0]]=o.length>1?o:o[0]}}for(var r=0,u;u=n[r];r++)u()}function i(e){var n=[];for(var r in t){var i=t[r],s="=";if(e=="h")n.push(r+s+(i.join?i.join(","):i));else{i.join?s="[]=":i=[i];for(var o=0,u;u=i[o];o++)n.push(r+s+u)}}return n.join("&")}var t,n=[];return e(window).on("hashchange",r),r(),{params:function(e){return i(e)},changed:function(e){n.push(e)},get:function(e){return t[e]},set:function(e){for(var n in e){var r=e[n];r==undefined?delete t[n]:t[n]=r}location.hash=i("h")}}}(d3.select);

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

(function(){
	// TODO drop this after nvd3 tooltip is updated to handle relative parents
	var show_tooltip = nv.tooltip.show;
	nv.tooltip.show = function(pos, content, gravity, dist, parentContainer, classes) {
		var container = show_tooltip.apply(this, arguments);

		container.style.top = parseInt(container.style.top, 10) - parentContainer.offsetTop + 'px';
		container.style.left = parseInt(container.style.left, 10) - parentContainer.offsetLeft + 'px';
	};
}());

// graphs using nv.d3
(function(){
	var main_el = d3.select('#main-graph');
	if (main_el.empty()) return;

	var loading = d3.select('#loading');
	var view = d3.select('button');

	var graph = main_el.select('svg');
	var inputs = d3.selectAll('.date-time')[0];

	var validate = /counters|timers|gauges/;
	var timeFormats = { 600: '%x', 60: '%X', 10: '%X' };

	loading.show = function(){
		return this.transition().style({ opacity: 1.0 }).duration(500);
	};

	loading.hide = function(){
		return this.transition().style({ opacity: 0 }).duration(500);
	};

	function append_error(err){
		main_el.append('em').text(err ? 'An Error Occurred!' : err.message);
	}

	function set_time_params(){
		var map = {};

		for (var i = 0, elem; elem = inputs[i]; i++)
			map[elem.name] = +new Date(elem.value) / 1000;

		LocationHash.set(map);
	}

	function create_graph(resp){
		nv.addGraph(function(){
			// initialize a new chart object
			var chart = nv.models.lineChart()
				.x(function(d){ return d[0]; })
				.y(function(d){ return d[1]; });

			// set xAxis tick format based up range and interval
			var format = timeFormats[resp.interval] || '%X';
			chart.xAxis.tickFormat(function(d){
				return d3.time.format(format)(new Date(d));
			});

			// force 0 into yAxis domain
			chart.forceY([0]);

			// bind data and render graph
			graph.datum(resp.results).transition().duration(500).call(chart);

			return chart;
		});
	}

	function render_graph(){
		var params = LocationHash.params();

		if (!validate.test(params) && location.pathname != '/')
			return alert('Need to supply at least one counter, timer or gauge');

		main_el.select('em').remove();

		loading.show().each('end', function(){
			d3.json('/data?' + params, function(resp){
				loading.hide().each('end', function(){
					resp ? create_graph(resp) : append_error(resp);
				});
			});
		});
	}

	// view button handler
	view.on('click', function(){
		set_time_params();
		render_graph();
	});

	// listen for changes to URL
	LocationHash.changed(render_graph);

	// initial graph render
	render_graph();
}());
