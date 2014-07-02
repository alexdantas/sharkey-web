/**
 * Scripts specific to the Tags page.
 *
 * Note that we assume jQuery, ajaxManager and other stuff.
 */
/*global $,ajaxManager*/
($(function() {

    // When the page loads, focus on the Tag Browser
    $('#tags .fancytree-container').focus();


	/**
	 * Initializing the tree view for all the Tags
	 */
	$('#tags').fancytree({
		extensions: ["glyph", "childcounter"],
		glyph: {
			map: {
				doc:             "glyphicon glyphicon-link",
				docOpen:         "glyphicon glyphicon-link",
				checkbox:        "glyphicon glyphicon-unchecked",
				checkboxSelected:"glyphicon glyphicon-check",
				checkboxUnknown: "glyphicon glyphicon-edit",
				expanderClosed:  "glyphicon glyphicon-expand",
				expanderLazy:    "glyphicon glyphicon-expand",
				expanderOpen:    "glyphicon glyphicon-collapse-down",
				folder:          "glyphicon glyphicon-tag",
				folderOpen:      "glyphicon glyphicon-tag"
			}
		},
		keyboard: true,

		/* when an item is clicked (either Tag or Link) */
		click: function(event, data) {

			// Clicked item on the list
			//var node = data.node;

			/* Whenever you click on a link, let's make an
			 * AJAX request to add it's visit count
			 */
			var element = event.toElement;

			if ((element) && ($(element).attr('class') === 'link-link')) {

				var link_id = $(element).attr('data-link-id');

				$.ajax({
					url: '/visit/' + link_id,
					type: 'POST',

					// Yeah, won't do anything if we succeed

					success: function(responseData, textStatus, jqXHR) {
						console.log($.parseJSON(responseData).visitCount);
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
			}
		},
		/* when user presses ENTER or SPACE inside an item */
		link: function(event, data) {
			/* redirect to the internal link
			 * (either Category or Link) */
			var href = $(
				$.parseHTML(data.node.title)
			).attr('href');

			window.location.href = href;
		}
	});
	/**
	 * Helper to ease applying things to every
	 * node inside the tree view.
	 *
	 * @param apply Function to apply to each node.
	 */
	var foreachNode = function(apply) {
		$('#tags')
			.fancytree('getTree')
			.visit(function(node) {
				apply(node);
			});
	};
	/* Things using FancyTree's API */
	$('#tags-expand').click(function() {
		foreachNode(function(node) {
			node.setExpanded(true);
		});
	});

	$('#tags-collapse').click(function() {
		foreachNode(function(node) {
			node.setExpanded(false);
		});
	});

	/*
	 * Now we define some functions that will handle the
	 * editing progress of the Tags.
	 */

	// Flag to tell if we're editing the Tags
	var tagIsEditing   = false;

	// All the buttons for the editing process
	var tagEditButtons = $(
		'#tags-select-all, #tags-select-none, #tags-select-toggle, #tags-delete, #tags-delete-links'
	);
	// Initially we're not editing
	tagEditButtons.hide();

	/* Start editing, baby! */
	$('#tags-edit').click(function() {
		tagIsEditing = !tagIsEditing;

		if (tagIsEditing) {
			// Change the button's appearance
			$(this).html(
				"<a href='#'><span class='glyphicon glyphicon-ban-circle' /> Cancel</a>"
			);

			/* Reinitializing the tree view, this time
			 * enabling checkboxes and multi-selection
			 * mode */
			$('#tags').fancytree({
				checkbox: true,
				selectMode: 2,

				// When double-clicking, toggle!
				dblclick: function(event, data) {
					data.node.toggleSelected();
				}
			});
			tagEditButtons.show();

			// Here we only let the user select TAGS,
			// not LINKS!
			// Tags are considered folders, because they
			foreachNode(function(node) {
				if (! node.isFolder())
					node.unselectable = true;
			});

		}
		else {
			// Change the button's appearance AGAIN
			$(this).html(
				"<a href='#'><span class='glyphicon glyphicon-pencil' /> Edit</a>"
			);
			$('#tags').fancytree({
				checkbox:false
			});
			tagEditButtons.hide();
		}
	});

	// And now, what happens when you click
	// on each of those fancy buttons

	$('#tags-select-all').click(function() {
		foreachNode(function(node) {
			node.setSelected(true);
		});
	});
	$('#tags-select-none').click(function() {
		foreachNode(function(node) {
			node.setSelected(false);
		});
	});
	$('#tags-select-toggle').click(function() {
		foreachNode(function(node) {
			node.toggleSelected();
		});
	});

	// Now, when you click to delete tags, we musc
	// communicate with the server
	$('#tags-delete').click(function() {

		// Will also destroy links that has these tags
		var destroyLinks = $('#tags-delete-links input').is(':checked');

		// We will send several DELETE requests
		// to the server, each with a selected
		// tag's ID
		var maxSize = $('#tags')
				.fancytree('getTree')
				.getSelectedNodes()
				.length;

		// And we place a beautiful progress bar,
		// to make the user not think we crashed
		var progressbarParent = $(
			"<div class='progress progress-striped active'></div>"
		);
		var progressbarText = $("<span>0%</span>");
		var progressbar = $(
				"<div class='progress-bar' " +
				"role='progressbar' " +
				"aria-valuenow='0' " +
				"aria-valuemin='0' " +
				"aria-valuemax='" + maxSize + "'></div>"
		);

		// Replace the buttons by the progress bar
		$('#tags-buttons').html('');
		progressbarParent.appendTo($('#tags-buttons'));
		progressbar.appendTo(progressbarParent);
		progressbarText.appendTo(progressbar);

		var deletedCount = 0;

		foreachNode(function(node) {

			if (!node.selected)
				return;

			// Each node has a `title` element,
			// with an href like '/tag/(ID)'
			var href = $(
				$.parseHTML(node.title)
			).attr('href');

			// Now, time for the AJAX request...!
			ajaxManager.add({
				url:  href,
				type: 'DELETE',
				data: {
					destroy_links: destroyLinks
				},
				/* Showing a red background on deleted tags */
				success: function(responseData, textStatus, jqXHR) {

					// Updating the progress bar
					deletedCount += 1;
					progressbar
						.attr('style', 'width:' + (deletedCount/maxSize)*100 + '%')
						.attr('aria-valuenow', deletedCount);
					progressbarText
						.text(Math.round( ((deletedCount/maxSize)*100) * 100)/100+ '%');

					// This animation requires jQueryUI
					$(node.span).animate({
						backgroundColor: '#FFDFDF'
					}, 1000);

					// Removing the element on the raw list
					// generated by sinatra
					$('#tags')
						.find("li span a[href='" + href + "']")
						.each(function() {
							$(this).parent('li').remove();
						});
				},
				error: function(responseData, textStatus, jqXHR) {
					/* This error-handling function sucks! */
					alert("Couldn't remove tag! " + responseData + ', ' + textStatus);
				}
			});
		});
		// When everything's done...
		ajaxManager.complete = function() {

			// Now the progress bar is shown as completed
			// and the user is advised to refresh the page
			progressbarParent.removeClass('active');
			progressbarParent.removeClass('progress-striped');
			progressbar.addClass('progress-bar-success');
			progressbarText.text("Done! Refresh page to see the changes");
		};

		// Now, do perform those requests for me!
		ajaxManager.run();
	});

}));

