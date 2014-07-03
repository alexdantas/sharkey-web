/*global $,Mousetrap,setTimeout*/

/**
 * Keyboard key bindings
 * (thanks to Mousetrap)
 */
($(function(){

	// *****************************************************
	// CODE DUPLICATION
	// (see `scripts.js`)
	/**
	 * Returns a new cute spinner GIF for
	 * showing indeterminate progress.
	 */
	function newSpinner() {
		return $('<img/>').attr("src", "/images/loader.gif");
	}
	/* Here we preload the image so it won't take long
	 * when creating it for the first time */
	newSpinner().appendTo('body').hide();
	// *****************************************************





	/* Making that tab on "Add Link" respond to JS calls */
	$('#single-multiple-link-tab').click(function(e) {
		e.preventDefault();
		$(this).tab('show');
	});

	/* NOW we bind the keys to actions! */
	Mousetrap.bind('a', function() {
		$('#input-link').modal('show');
		$('#single-multiple-link-tab a:first').tab('show');
	});
	Mousetrap.bind('m', function() {
		$('#input-link').modal('show');
		$('#single-multiple-link-tab a:last').tab('show');
	});

	/* Redirects to `href` and, if `elementID` exists on
	 * the page, replace it's internal HTML with a spinner.
	 */
	function gotoLink(href, elementID) {
		var link = $(elementID);
		if (link)
			link.html(newSpinner());

		window.location.href = href;
	}

	Mousetrap.bind('l', function() {
		gotoLink('/links', '#keybind-links');
	});
	Mousetrap.bind('t', function() {
		gotoLink('/tags', '#keybind-tags');
	});
	Mousetrap.bind('c', function() {
		gotoLink('/categories', '#keybind-categories');
	});
	Mousetrap.bind('s', function() {
		gotoLink('/settings', '#keybind-settings');
	});
	Mousetrap.bind('d', function() {
		gotoLink('/', '#keybind-home');
	});
	Mousetrap.bind('h', function() {
		gotoLink('/help', '#keybind-help');
	});

	Mousetrap.bind('k', function() {
		$('#keybindings').modal('show');
    });





	Mousetrap.bind('up up down down left right left right b a', function() {
		$('body').addClass('konami-code');

		/* again, again! */
		setTimeout(function() {
			$('body').removeClass('konami-code');
		}, 4100);
	});

}));

