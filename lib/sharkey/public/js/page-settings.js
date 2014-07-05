/*global $*/

/**
 * Scripts specific for the Settings page
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


	/**
	 * AJAX requester for changing `input radio` settings.
	 *
	 * We need:
	 * - Parent `form`
	 * - Child `label` with class `ajax-radio`
	 */
	$('.ajax-radio').click(function() {

		// The button we just pressed - will add `.active` class
		// on success
		var this_button = $(this);

		var parent_form = this_button.parents('form');

		// The button neighbor to the just pressed - will remove
		// `.active` class on success
		var that_button = parent_form.find('label:not(.active)');

		/* URL for AJAX request: like '/delete_/DELETE_ID' */
		var setting_url   = this_button.parents('form').attr('action');
		var setting_value = this_button.children('input').attr('value');

		/* Remove button to prevent double request
		 * and create the cute loader image */
		var spinner = $(newSpinner()).appendTo(parent_form);

		$.ajax({
			url:  setting_url,
			type: 'POST',
			data: {
				name: this_button.children('input').attr('name'),
				value: setting_value
			},
			success: function(responseData, textStatus, jqXHR) {

				// When this request succeds, Bootstrap JS already changed
				// the buttons' .active classes.
				// So the button we just pressed is this...
				parent_form
					.find('label.active')
					.attr('class', 'btn btn-primary ajax-radio active');

				// and the other one is that...
				parent_form
					.find('label:not(.active)')
					.attr('class', 'btn btn-default ajax-radio');
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
				spinner.remove();
			}
		});
	});

	// It may take a while.
	// Let's warn the user...!
	$('#button-import').click(function() {
		$(this).html('Hold on, this might take a while...  ');
		$(this).append(newSpinner());
	});
}));

