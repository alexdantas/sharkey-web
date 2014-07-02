/**
 * Scripts specific to the TagCloud page.
 *
 * NOTE: we require jQuery TagCloud!
 */

$(function () {

	/**
	 * This function activates the tag cloud functionality.
	 * Call it from the TagCloud page.
	 *
	 * @param smaller Tiniest possible font size allowed
	 * @param bigger  Biggest possible font size allowed
	 */
	var activateTagCloud = function(smaller, bigger) {
		$.fn.tagcloud.defaults = {
			size: {
				start: smaller,
				end:   bigger,
				unit: 'pt'
			},
			color: {
				start: '#f5f5f5',
				end: '#428bca'
			}
		};
		$('#tagcloud a').tagcloud();
	};

});

