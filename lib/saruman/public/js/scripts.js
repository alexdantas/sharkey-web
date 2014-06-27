/**
 * my custom scripts beibeh
 * requires jQuery
 */
($(function(){

	/* yeah */

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

}));

