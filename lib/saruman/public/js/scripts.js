/*global $,NProgress*/

/**
 * my custom scripts beibeh
 * requires jQuery
 */
($(function(){

	/**
	 * NProgress is this awesome Progress bar that
	 * makes it look like the site is busy!
	 *
	 * Here we:
	 * 1. Start it as soon as we can
	 * 2. Set it to increase regularly
	 * 3. Finish it off as soon as everything loads
	 */
	if (typeof(NProgress) !== "undefined") {

		NProgress.configure({
			showSpinner: false
		});
		NProgress.start();

		var NProgressInterval = setInterval(function() {
			NProgress.inc();
		}, 500);

		$(window).load(function() {
			NProgress.done();
			clearInterval(NProgressInterval);
		});
	}

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

	/**
	 * AJAX requester for deleting stuff.
	 * We need:
	 * - Thing that will be deleted (class `ajax-delete-parent`);
	 * - Inside it a `form`;
	 * - Inside it a button (class `ajax-delete`);
	 *
	 * This way, whenever we click on that "Delete" button:
	 *
	 * 1. Make an AJAX request to the server to
	 *    actually delete it from the database
	 * 2. Show a cute spinner gif for progress
	 * 3. When it's done, remove the parent thing
	 *    from the DOM
	 */
	$('button.ajax-delete').click(function(e) {
		/* We don't want to refresh the page, do we? */
		e.preventDefault();

		/* Will delete this if successful on AJAX request */
		var delete_item = $(this).parents('.ajax-delete-parent');

		/* URL for AJAX request: like '/delete_/DELETE_ID' */
		var delete_url  = $(this).parents('form').attr('action');

		/* Remove button to prevent double request
		 * and create the cute loader image */
		$(this).parents('form').append(newSpinner());
		$(this).remove();

		/* Yay, my very first AJAX request! */
		$.ajax({
			url:  delete_url,
			type: 'DELETE',

			/* removing Delete_ from the DOM if success */
			success: function(responseData, textStatus, jqXHR) {
				delete_item.fadeOut(500, function() {
					delete_item.remove();
				});
			},
			error: function(responseData, textStatus, jqXHR) {
				/* This error-handling function sucks! */
				alert("Couldn't remove stuff! " + responseData + ', ' + textStatus);
			}
		});
	});


	/* SETTINGS PAGE */

	/**
	 * AJAX requester for changing `input radio` settings.
	 *
	 * We need:
	 * - Parent `form`
	 * - Child `label` with class `ajax-radio`
	 */
	$('.ajax-radio').click(function() {

		/* URL for AJAX request: like '/delete_/DELETE_ID' */
		var setting_url   = $(this).parents('form').attr('action');
		var setting_value = $(this).children('input').attr('value');
		var parent_form   = $(this).parents('form');

		/* Remove button to prevent double request
		 * and create the cute loader image */
		var spinner = $(newSpinner()).appendTo(parent_form);

		/* Yay, my very first AJAX request! */
		$.ajax({
			url:  setting_url,
			type: 'POST',
			data: {
				name: $(this).children('input').attr('name'),
				value: setting_value
			},

			/* removing Delete_ from the DOM if success */
			success: function(responseData, textStatus, jqXHR) {
				/* aww yeah! */
			},
			error: function(responseData, textStatus, jqXHR) {
				/* This error-handling function sucks! */
				parent_form.append(
					$("<div>Couldn't apply the setting - please reload the page</div>")
						.attr('class', 'alert alert-danger')
						.attr('role', 'alert')
				);
			},
			complete: function() {
				/* taking out the spinner image */
				spinner.remove();
			}
		});
	});


	/**
	 * The awesome new category form.
	 * We have a button "New Category" that shows
	 * a form when clicked.
	 *
	 * When that form is filled, we hide it and
	 * show the button again.
	 */
	$('#new-category-form').hide();

	$('#new-category').click(function(e) {
		/* otherwise it would trigger the form validation */
		e.preventDefault();

		$(this).hide();
		$('#new-category-form').show();
	});

	/* ...and when this form is submitted, we send an AJAX
	 * request for a new category.
	 *
	 * If successful it refreshes both <select> fields on
	 * the page.
	 */
	$('#new-category-form').submit(function(e) {
		/* Don't refresh the page! */
		e.preventDefault();

		/* Will replace the button text with a nice
		 * progress spinner */
		var form   = $(this);
		var button = $('#new-category-button');

		var buttonText = button.html();
		var spinner    = $(newSpinner());

		button.html(spinner);

		$.ajax({
			url:  form.attr('action'),
			type: 'POST',
			data: {
				name:   $('#new-category-name').val(),
				parent: $('#new-category-parent').val()
			},

			/* Will add the latest Category to the top of the
			 * dropdown menu and mark it as selected
			 */
			success: function(responseData, textStatus, jqXHR) {
				var dropdown1 = $('#input-link-category-one');
				var dropdown2 = $('#input-link-category-two');

				var parsedResponse = $.parseJSON(responseData);
				var value = parsedResponse['id'];
				var name  = parsedResponse['name'];

				dropdown1
					.prepend('<option value="' + value + '">' + name + '</option>')
					.val(value);
				dropdown2
					.prepend('<option value="' + value + '">' + name + '</option>')
					.val(value);
			},
			error: function(responseData, textStatus, jqXHR) {
				/* This error-handling function sucks! */
				// form.append(
				// 	$("<div>Couldn't apply the setting - please reload the page</div>")
				// 		.attr('class', 'alert alert-danger')
				// 		.attr('role', 'alert')
				// );
				alert('no!');
			},
			complete: function() {
				/* taking out the spinner image */
				button.html(buttonText);
				spinner.remove();

				form.hide();
				$('#new-category').show();
			}
		});
	});

	/**
	 * Keyboard key bindings
	 * (thanks to Mousetrap)
	 */

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

	/* helper that activates a link and
	 * replaces it's text by a spinner */
	function gotoLink(linkId) {
		var link = $(linkId);
		link.html(newSpinner());

		/* redirect the page */
		window.location.href = link.attr('href');
	}

	Mousetrap.bind('l', function() { gotoLink('#keybind-links');      });
	Mousetrap.bind('t', function() { gotoLink('#keybind-tags');       });
	Mousetrap.bind('c', function() { gotoLink('#keybind-categories'); });

	Mousetrap.bind('s', function() { gotoLink('#keybind-settings'); });
	Mousetrap.bind('d', function() { gotoLink('#keybind-home');     });
	Mousetrap.bind('h', function() { gotoLink('#keybind-help');     });
}));

