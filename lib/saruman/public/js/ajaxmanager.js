/**
 * Simple and neat queue for AJAX requests.
 *
 * You push several at once and as soon as
 * they all end, it will stop forever.
 *
 * Make sure to call #run only when you've
 * finished adding all requests!
 *
 * Also, you can attach a `complete` callback,
 * that will execute as soon as all requests
 * were made!
 *
 * Thanks, jAndy! Source:
 * http://stackoverflow.com/a/4785886
 */
var ajaxManager = (function() {

	var requests = [];
	var running  = false;

	return {
		add:  function(opt) {
			if (!running)
				requests.push(opt);
		},
		remove:  function(opt) {
			if (!running)
				if( $.inArray(opt, requests) > -1 )
					requests.splice($.inArray(opt, requests), 1);
		},
		clear: function() {
			if (running)
				return;

			requests = [];
		},
		run: function() {
			var self = this;
			var completeCallback;

			if (requests.length) {
				completeCallback = requests[0].complete;

				requests[0].complete = function() {
					if (typeof(completeCallback) === 'function')
						completeCallback();

					requests.shift();
					self.run.apply(self, []);
				};

				$.ajax(requests[0]);
			}
			else {
				running = false;
				if (typeof(self.complete) === 'function')
					self.complete();
			}
		},
		stop:  function() {
			requests = [];
			clearTimeout(this.tid);
		}
	};
}());

