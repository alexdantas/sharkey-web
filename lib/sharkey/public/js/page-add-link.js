/*global $*/

/**
 * Scripts for both the "Add Link" dialog and the "Edit Link".
 *
 * They're Bootstrap Modals that initially appear hidden and only
 * get shown when requested.
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



	// Prevent user from double-submitting a <form>
	// 1. Make buttons hide when user submits
	//    (either by clicking on 'Add Link' or pressing Enter)
	// 2. As soon as a <form> starts being submitted,
	//    disable further submissions.
	var submitting = false;
	$('.input-link form').submit(function() {
		// By returning false we prevent further submissions
		if (submitting)
			return false;

		// <input> validation!
		// Only submit if we have an URL on the <form>
		if ($('.input-link-url').val() !== "") {

			$('.input-link form button').addClass('disabled');
			submitting = true;
		}
		// Makes the form start submitting
		return true;
	});


	/**
	 * The awesome new category form.
	 * We have a button "New Category" that shows
	 * a form when clicked.
	 *
	 * When that form is filled, we hide it and
	 * show the button again.
	 */
	$('.new-category-form').hide();

	$('.new-category').click(function(e) {
		/* otherwise it would trigger the form validation */
		e.preventDefault();

		$(this).hide();
		$('.new-category-form').show();
	});

	/* ...and when this form is submitted, we send an AJAX
	 * request for a new category.
	 *
	 * If successful it refreshes both <select> fields on
	 * the page.
	 */
	$('.new-category-form').submit(function(e) {
		/* Don't refresh the page! */
		e.preventDefault();

		/* Will replace the button text with a nice
		 * progress spinner */
		var form   = $(this);
		var button = $('.new-category-button');

		var buttonText = button.html();
		var spinner    = $(newSpinner());

		button.html(spinner);

		$.ajax({
			url:  form.attr('action'),
			type: 'POST',
			data: {
				name:   $('.new-category-name').val(),
				parent: $('.new-category-parent').val()
			},

			/* Will add the latest Category to the top of the
			 * dropdown menu and mark it as selected
			 */
			success: function(responseData, textStatus, jqXHR) {
				var dropdown1 = $('.input-link-category-one');
				var dropdown2 = $('.input-link-category-two');

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
				$('.new-category').show();
			}
		});
	});

	/* Beautiful tag-handling stuff */
	$('.tagsinput').magicSuggest({
		/* URL to make an AJAX call to get results */
		data: '/tags',
		/* by default it uses POST, what a bummer */
		method: 'get',
		/* how much it waits before triggering the AJAX query */
		typeDelay: 0,
		noSuggestionText: 'No tags like this',
		placeholder: 'Yeah',
		/* use , to add a tag
		 * (why does it not work?
		 *  it keeps accepting tags ending with commas!) */
		useCommaKey: true,
		/* choose how many tags you want */
		maxSelection: null,
		/* show lines with alternated colors */
		useZebraStyle: true
	});


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

