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

}));

