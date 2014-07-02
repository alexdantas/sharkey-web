/*global $*/

/**
 * Scripts specific to the Links page.
 *
 * Requires jQuery.
 */
($(function(){

	/* Whenever you click on a link, let's make an AJAX request
	 * to add it's visit count
	 */
	$('.link-title > a').click(function(e) {

		// Kinda ugly way of traversing the DOM
		// It WILL mess up if I ever change the HTML
		// structure... Maybe I should find a better way
		var link_element = $(e.target).parents('li');
		var link_id = link_element.attr('data-link-id');

		$.ajax({
			url: '/visit/' + link_id,
			type: 'POST',

			success: function(responseData, textStatus, jqXHR) {

				// Updating the link's visited text with
				// the new count.
				var new_count  = $.parseJSON(responseData).visitCount;
				if (new_count) {

					link_element.find('.link-visited-date').html(
						'Last visited a moment ago'
					);
					link_element.find('.link-visited-count').html(
						'<span class="glyphicon glyphicon-open"></span> ' + new_count
					);
				}
			},
			error: function(responseData, textStatus, jqXHR) {
				console.log(
					"Error! Couldn't set Link as visited!\n" +
					"responseData: " + responseData + "\n" +
					"textStatus:   " + textStatus + "\n" +
					"jqXHR:        " + jqXHR
				);
			}
		});
	});

}));



