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

}));

