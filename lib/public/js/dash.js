// Location Hash wrapper script
var LocationHash=function(a){function c(){var a=location.hash.substr(1).split("&");b={};for(var c=0,d;d=a[c];c++){var e=d.split("="),f=e[1].split(",");b[e[0]]=f.length>1?f:f[0]}}function d(){var a=[];for(var c in b){var d=b[c];a.push(c+"="+(d.join?d.join(","):d))}location.hash=a.join("&")}var b;return a(window).on("hashchange",c).trigger("hashchange"),{params:function(){return a.param(b)},get:function(a){return b[a]},set:function(a){for(var c in a){var e=a[c];e==undefined?delete b[c]:b[c]=e}d()}}}(jQuery);

// set Accept header to JSON
$.ajaxSetup({ beforeSend: function(req){ req.setRequestHeader('Accept', 'application/json'); } });

// Date.now polyfill (if needed)
if (!Date.now) Date.now = function(){ return +new Date; };

$(function(){
	var main = $('#main-graph');
	var graph_opts = {
		xaxis: {
			mode: 'time', timeformat: '%h:%M:%S',
			minTickSize: [10, 'second']
		},

		yaxis: { min: 0, minTickSize: 1 },
		lines: { show: true }, points: { show: false },

		grid: { borderColor:'#FFF', color:'#FFF' },
		legend: { backgroundColor:'#000' }
	};

	function timestamp(str){
		return Math.round(+new Date(str) / 1000);
	}
	
	function parse_error(xhr){
		var data;

		try {
			data = xhr.status == 500 ? { error: 'zomg server fail :(' } : $.parseJSON(xhr.responseText);
		} catch(e) {
			data = { error: 'unknown error' };
		} finally {
			return data;
		}
	}

	function update_graph(graph){
		var req = { dataType: 'json', data: LocationHash.params() };
		var path = location.pathname;

		graph.html('<h2>Loading...</h2>');
		$.ajax(path, req).done(function(data){
			$.plot(graph, data.metrics, graph_opts);

		}).fail(function(xhr){
			var data = parse_error(xhr);

			graph.html('<h2>Error: '+ data.error +'</h2>');
		});
	}
	

	// initialize the graph itself
	$('.graph').each(function(){ update_graph($(this)); });

	// initialize date time picker
	var inputs = $('input.date-time').datetimepicker();

	var start = LocationHash.get('start');
	var stop = LocationHash.get('stop');

	inputs.first().datetimepicker('setDate', start ? new Date(start * 1000) : new Date(Date.now() - (1000*60*60*2)));
	inputs.last().datetimepicker('setDate', stop ? new Date(stop * 1000) : new Date());

	// style View button and bind handler
	$('button').button().on('click', function(){
		// set location hash with new values
		LocationHash.set({
			start: timestamp(inputs.first().val()),
			stop: timestamp(inputs.last().val()),
		});

		update_graph(main);
	});

	$(window).on('hashchange', function(){
		update_graph(main);
	});
});

