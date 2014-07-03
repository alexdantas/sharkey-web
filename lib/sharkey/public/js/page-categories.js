/*global $,ajaxManager*/

/**
 * Scripts specific to the Categories page
 *
 * Requires FancyTree
 */
($(function(){


    // When the page loads, focus on the Category Browser
    $('#categories .fancytree-container').focus();


	/**
	 * Initializing the tree view for all the Categories
	 */
	$('#categories').fancytree({
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
				folder:          "glyphicon glyphicon-book",
				folderOpen:      "glyphicon glyphicon-book"
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
		$('#categories')
			.fancytree('getTree')
			.visit(function(node) {
				apply(node);
			});
	};
	/* Things using FancyTree's API */
	$('#categories-expand').click(function() {
		foreachNode(function(node) {
			node.setExpanded(true);
		});
	});

	$('#categories-collapse').click(function() {
		foreachNode(function(node) {
			node.setExpanded(false);
		});
	});

	/*
	 * Now we define some functions that will handle the
	 * editing progress of the Categories.
	 */

	// Flag to tell if we're editing the Categories
	var categoryIsEditing   = false;

	// All the buttons for the editing process
	var categoryEditButtons = $(
		'#categories-select-all, #categories-select-none, #categories-select-toggle, #categories-delete, #categories-delete-links'
	);
	// Initially we're not editing
	categoryEditButtons.hide();

	/* Start editing, baby! */
	$('#categories-edit').click(function() {
		categoryIsEditing = !categoryIsEditing;

		if (categoryIsEditing) {
			// Change the button's appearance
			$(this).html(
				"<button class='btn btn-default'><span class='glyphicon glyphicon-ban-circle' /> Cancel</button>"
			);

			/* Reinitializing the tree view, this time
			 * enabling checkboxes and multi-selection
			 * mode */
			$('#categories').fancytree({
				checkbox: true,
				selectMode: 2,

				// When double-clicking, toggle!
				dblclick: function(event, data) {
					data.node.toggleSelected();
				}
			});
			categoryEditButtons.show();

			// Here we only let the user select CATEGORIES,
			// not LINKS!
			// Categories are considered folders, because they
			foreachNode(function(node) {
				if (! node.isFolder())
					node.unselectable = true;
			});

		}
		else {
			// Change the button's appearance AGAIN
			$(this).html(
				"<button class='btn btn-default'><span class='glyphicon glyphicon-pencil' /> Edit</button>"
			);
			$('#categories').fancytree({
				checkbox:false
			});
			categoryEditButtons.hide();
		}
	});

	// And now, what happens when you click
	// on each of those fancy buttons

	$('#categories-select-all').click(function() {
		foreachNode(function(node) {
			node.setSelected(true);
		});
	});
	$('#categories-select-none').click(function() {
		foreachNode(function(node) {
			node.setSelected(false);
		});
	});
	$('#categories-select-toggle').click(function() {
		foreachNode(function(node) {
			node.toggleSelected();
		});
	});

	// Now, when you click to delete categories, we musc
	// communicate with the server
	$('#categories-delete').click(function() {

		// Will also destroy links that has these categories
		var destroyLinks = $('#categories-delete-links input').is(':checked');

		// We will send several DELETE requests
		// to the server, each with a selected
		// category's ID
		var maxSize = $('#categories')
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
		$('#categories-buttons').html('');
		progressbarParent.appendTo($('#categories-buttons'));
		progressbar.appendTo(progressbarParent);
		progressbarText.appendTo(progressbar);

		var deletedCount = 0;

		foreachNode(function(node) {

			if (!node.selected)
				return;

			// Each node has a `title` element,
			// with an href like '/category/(ID)'
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
				/* Showing a red background on deleted categories */
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
					$('#categories')
						.find("li span a[href='" + href + "']")
						.each(function() {
							$(this).parent('li').remove();
						});
				},
				error: function(responseData, textStatus, jqXHR) {
					/* This error-handling function sucks! */
					alert("Couldn't remove category! " + responseData + ', ' + textStatus);
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




	// // When the page loads, focus on the categories browser
    // $('#categories .fancytree-container').focus();

	// /**
	//  * FancyTree makes easy to show a tree view, just like
	//  * a file browser on a file system.
	//  *
	//  * We use it on the Categories page.
	//  */
	// $('#categories').fancytree({
	// 	extensions: ["glyph", "childcounter"],
	// 	glyph: {
	// 		map: {
	// 			doc:            "glyphicon glyphicon-link",
	// 			folder:         "glyphicon glyphicon-book",
	// 			expanderClosed: "glyphicon glyphicon-expand",
	// 			expanderLazy:   "glyphicon glyphicon-expand",
	// 			expanderOpen:   "glyphicon glyphicon-collapse-down"
	// 		}
	// 	},
	// 	keyboard: true,

	// 	/* when an item is clicked (either Category or Link) */
	// 	activate: function(event, data) {
	// 		/* Nothing for now... */
	// 		//var node = data.node;
	// 		//console.log(data);
	// 	},
	// 	/* when user presses ENTER or SPACE inside an item */
	// 	link: function(event, data) {
	// 		/* redirect to the internal link
	// 		 * (either Category or Link) */
	// 		var href = $(
	// 			$.parseHTML(data.node.title)
	// 		).attr('href');

	// 		window.location.href = href;
	// 	}
	// });
	// /* Things using FancyTree's API */
	// $('#categories-expand').click(function() {
	// 	// For each node, expand it!
	// 	$('#categories')
	// 		.fancytree('getTree')
	// 		.visit(function(node) {
	// 			node.setExpanded(true);
	// 		});
	// });
	// $('#categories-collapse').click(function() {
	// 	// TODO: Remove this code repetition!
	// 	$('#categories')
	// 		.fancytree('getTree')
	// 		.visit(function(node) {
	// 			node.setExpanded(false);
	// 		});
	// });
}));

