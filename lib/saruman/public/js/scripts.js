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
	 * Whenever we click on a "Delete" button:
	 *
	 * 1. Make an AJAX request to the server to
	 *    actually delete it from the database
	 * 2. Show a cute spinner gif for progress
	 * 3. When it's done, remove the clicked link
	 *    from the DOM
	 */
	$('button.link-delete').click(function(e) {
		/* We don't want to refresh the page, do we? */
		e.preventDefault();

		/* Will delete this if successful on AJAX request */
		var link_item = $(this).parents('li.link');

		/* URL for AJAX request: like '/link/LINK_ID' */
		var link_url  = $(this).parents('form').attr('action');

		/* Remove button to prevent double request
		 * and create the cute loader image */
		$(this).parents('form').append(newSpinner());
		$(this).remove();

		/* Yay, my very first AJAX request! */
		$.ajax({
			url:  link_url,
			type: 'DELETE',

			/* removing Link from the DOM if success */
			success: function(responseData, textStatus, jqXHR) {
				link_item.fadeOut(500, function() {
					link_item.remove();
				});
			},
			error: function(responseData, textStatus, jqXHR) {
				/* This error-handling function sucks! */
				alert("Couldn't remove Link! " + responseData + ', ' + textStatus);
			}
		});
	});

}));

