/*global $*/

/**
 * Scripts for the "Edit Link" dialog.
 */
($(function(){

	var clearEditLinkDialog = function() {

		$('#edit-link input').each(function(a, element) {
			$(element).val('');
		});

		$('#edit-link textarea').val('');
		$('#edit-link select').val(0);
	};

	/**
	 * When you click to "Edit Link", Bootstrap will automatically
	 * show the dialog (modal).
	 * But we need to fill it with this link's current attributes.
	 */
	$('button.link-edit').click(function() {

		// Just in case we tried to edit a link before
		// and bailed out
		clearEditLinkDialog();

		var link = $(
			$(this).parents('li.link')
		);

		// First, we need to obtain the current data for the link
		//
		// I could make an AJAX request to the server, but I'd
		// rather crawl everything from the current page.
		//
		// Unfortunately, if I change the layout then everything
		// FUCKS UP

		var link_url   = link.find('span.link-title > a').attr('href');
		var link_title = link.find('span.link-title').text();

		/* Creating an array of tag names */
		var link_tags = link.find('.link-tags a');
		if ((link_tags) && (link_tags.length > 0)) {
			var tmp = [];
			link_tags.each(function(a, element) {
				tmp.push($(element).attr('title'));
			});
			link_tags = tmp;
		}
		else
			link_tags = [];

		var link_comments = link.find('span.link-description').text();

		/* Creating an array of category names */
		var link_category = link.find('.link-categories a');
		if ((link_category) && (link_category.length > 0)) {
			var tmp = link_category[0];

			// It will be an <a> with href like `/category/id`
			// When split it will become ["", "category", "id"]
			link_category = $(tmp).attr('href').split('/')[2];
		}
		else
			link_category = "";

		// Now we fill the "Edit Link" form with the data
		// we just got. Brace yourselves!
		$('#edit-link #input-link-url').val(link_url);
		$('#edit-link #input-link-title').val(link_title);

		// Now here's an EXCEPTION
		// Since we're using an awesome plugin to visually
		// handle the tags, we must accommodate to it.
		// It actually has a hidden input like this:
		$('#edit-link #input-link-tags input').val(link_tags.join());

		$('#edit-link #input-link-comment').val(link_comments);
		$('#edit-link #input-link-category-one').val(link_category);
	});

}));


