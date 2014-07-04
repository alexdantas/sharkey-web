/*global $*/

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



	/* When the user finishes entering a URL, we make an
	 * AJAX request to know that URL's title and description.
	 *
	 * We'll use that to automatically fill the <inputs>
	 * on the "Add Link" dialog.
	 *
	 * But if the user starts typing something on the title
	 * input then we abort that request.
	 */

	// This will contain the AJAX request for when we ask
	// for the link info.
	var linkMetadataRequest;

	// If the user starts typing on the title input
	// we cancel the AJAX request
	//
	$('#input-link-title').keypress(function() {
		if (typeof(linkMetadataRequest) !== 'undefined')
			linkMetadataRequest.abort();
	});

	// And here we make it so that when the user leaves
	// the URL input, we start making that request.
	//
	// When it starts it'll place a cute spinner to show
	// progress.
	//
	// @note: It will only put things on the input if
	//        there's nothing there!
	//        In other words, it won't override existing
	//        values!
	$('#add-link #input-link-url').focusout(function() {

		// Don't request title for empty URL
		var text = $(this).val();
		if (text === "")
			return;

		// Won't do anything if all the fields
		// are already filled
		var title_input = $('#add-link #input-link-title');
		var comment_input = $('#add-link .input-links-comment');
		if ((title_input.val() !== '') && (comment_input.val() !== ''))
			return;

		var spinner_place = $('#single-link span.spinner-placeholder');
		var spinner       = $(newSpinner()).appendTo(spinner_place);

		linkMetadataRequest = $.ajax({
			url: '/metadata',
			method: 'GET',
			data: {
				url: text
			},

			success: function(responseData, textStatus, jqXHR) {
				spinner.remove();

				var response = $.parseJSON(responseData);

				var title       = response.pageTitle;
				var description = response.pageDescription;

				if (title_input.val() === '')
					title_input.val(title);

				if (comment_input.val() === '')
					comment_input.val(description);
			},

			complete: function() {
				spinner.remove();
			}
		});

	});

}));


