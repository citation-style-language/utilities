var timeoutID;
var selectedFormat = null;
var selectedFields = [];
var forceSearch = false;

function onSearchKeyUp(event, input) {
	//console.log('keyup');
	//console.log(event.keyCode);
	
	var immediate = false;
	var timeout = 300;
	
	// Clear field on escape
	if (event.keyCode == 27 && input.value != '') {
		input.value = '';
		timeout = 1;
	}
	
	else if (event.keyCode == 8 || event.keyCode == 46) {
		// Ignore delete when already empty
		if (input.value == '') {
			//return;
		}
	}
	
	// Ignore tab and arrow keys
	else if ([9, 37, 38, 39, 40].indexOf(event.keyCode) != -1) {
		return;
	}
	
	// Ignore modifier keys
	else if ([16, 17, 18, 91, 224].indexOf(event.keyCode) != -1 && !forceSearch) {
		return;
	}
	
	// Immediate search on Enter
	else if (event.keyCode == 13) {
		immediate = true;
	}
	
	if (timeoutID) {
		clearTimeout(timeoutID);
		timeoutID = null;
	}
	
	forceSearch = false;
	
	if (immediate) {
		startSearch();
	}
	else {
		timeoutID = setTimeout(function () {
			startSearch();
		}, 400);
	}
}

// Pick up some things not caught by keyUp
function onSearchKeyPress(event) {
	//console.log('keypress');
	//console.log(event.keyCode);
	
	// Ignore tab and arrow keys
	if ([9, 37, 38, 39, 40].indexOf(event.keyCode) != -1) {
		return;
	}
	
	// Ignore modifier keys
	else if ([16, 17, 18, 91, 224].indexOf(event.keyCode) != -1) {
		return;
	}
	
	// Force search for cut/paste, which show up here but not
	// in onKeyUp(), where we ignore modifier keys
	forceSearch = true;
}

function onChange(input) {
	if (input.value == '') {
		startSearch();
	}
}

function startSearch() {
	document.getElementById('loading').style.visibility = 'visible';
	setTimeout(function () {
		updateSearchResults();
		document.getElementById('loading').style.visibility = 'hidden';
	}, 25);
}

function updateSearchResults() {
	//console.log("Searching");
	var t = new Date();
	
	var val = document.getElementById('searchField').value;
	var valLower = val.toLowerCase();
	var numDisplayedStyles = 0;
	var formatCounts = {};
	var fieldCounts = {};
	
	var showDepStyles = !document.getElementById('dependentToggle').checked;
	
	// Filter the style list based on search parameters
	var uls = $("ul.styleList li.title a").each(function () {
		var container = $(this).parent().parent().parent();
		var name = $(this).attr("href").match(/([^\/]+(?:\/dev)?(?:\?dep=1)?)$/)[0];
		
		var show = true;
		
		// Hide dependent styles if unchecked
		if (!showDepStyles && $(this).hasClass("dependent")) {
			show = false;
		}
		
		// Hide styles that don't match the search text
		if (show) {
			if (name.indexOf(valLower) == -1 && $(this).text().toLowerCase().indexOf(valLower) == -1) {
				show = false;
			}
		}
		
		// Hide styles that don't match the selected categories
		if (show) {
			if (selectedFormat) {
				if (!styleData[name].cat || styleData[name].cat.format != selectedFormat) {
					show = false;
				}
			}
			
			if (show) {
				for (var i in selectedFields) {
					if (!styleData[name].cat || styleData[name].cat.fields.indexOf(selectedFields[i]) == -1) {
						show = false;
						break;
					}
				}
			}
		}
		
		if (show) {
			container.show();
			numDisplayedStyles++;
			
			// Count citation formats
			if (styleData[name].cat.format) {
				if (!formatCounts[styleData[name].cat.format]) {
					formatCounts[styleData[name].cat.format] = 1;
				}
				else {
					formatCounts[styleData[name].cat.format]++;
				}
			}
			
			// Count fields
			if (styleData[name].cat.fields) {
				for (var i in styleData[name].cat.fields) {
					var field = styleData[name].cat.fields[i];
					if (!fieldCounts[field]) {
						fieldCounts[field] = 1;
					}
					else {
						fieldCounts[field]++;
					}
				}
			}
		}
		else {
			container.hide();
		}
	});
	
	//
	// And now adjust the search parameters based on visible results
	//
	
	// Remove all category elements
	$("#formats").empty();
	$("#fields").empty();
	
	// Sort formats and add to category box
	var arr = [];
	for (var i in formatCounts) {
		arr.push([i, formatCounts[i]]);
	}
	arr.sort(function (a, b) { return a[0].localeCompare(b[0]) });
	for (var i in arr) {
		var selClass = selectedFormat == arr[i][0] ? ' class="selected"' : '';
		$("#formats").append('<li' + selClass + '>' + arr[i][0] + '</li>');
	}
	
	// Sort fields and add to category box
	var arr = [];
	for (var i in fieldCounts) {
		arr.push([i, fieldCounts[i]]);
	}
	arr.sort(function (a, b) { return a[0].localeCompare(b[0]) });
	for (var i in arr) {
		var selClass = selectedFields.indexOf(arr[i][0]) != -1 ? ' class="selected"' : '';
		$("#fields").append('<li' + selClass + '>' + arr[i][0] + '</li>');
	}
	
	// Fix disappearing categories in WebKit
	for (var i in document.styleSheets[0].cssRules) {
		var rules = document.styleSheets[0].cssRules[i];
		if (rules.selectorText == "#searchFields ul") {
			//rules.style.border = '0';
			rules.style.display = 'block';
			break;
		}
	}
	
	// Add/remove categories on click
	$(".categoryBox li").click(function () {
		var name = $(this).text();
		var selected = $(this).hasClass("selected");
		
		var div = $(this).closest(".categoryBox");
		
		if (div.attr("id") == "formatsBox") {
			selectedFormat = selected ? null : name;
		}
		else if (div.attr("id") == "fieldsBox") {
			if (selected) {
				var pos = selectedFields.indexOf(name);
				selectedFields.splice(pos, 1);
			}
			else {
				selectedFields.push(name);
			}
		}
		else {
			throw ("Category box not found");
		}
		
		if (selected) {
			$(this).removeClass("selected");
		}
		else {
			$(this).addClass("selected");
		}
		
		startSearch();
	});
	
	// Update number of search results
	switch (numDisplayedStyles) {
		case 0:
			var str =  "No styles found";
			break;
		
		case 1:
			var str =  "1 style found:";
			break;
		
		default:
			var num = numDisplayedStyles + '';
			num = num.replace(/\B(?=(?:\d{3})+(?!\d))/g, ",");
			var str = num + " styles found:";
	}
	$("#styleCount").text(str);
	
	//console.log((new Date() - t) + "ms");
}

// Add preview tooltips
$(function () {
	updateSearchResults();
	
	/*$("ul.styleList li.title a").each(function() {
		$(this).tooltip({
			bodyHandler: function() {
				return "Previews forthcoming";
			},
			showURL: false
		});
	});*/
	
	$("ul.styleList li.title a").each(function() {
		$(this).qtip({
			content: {
				text: "Loading preview...",
				ajax: {
					url: "/styles-files/previews/" + styleData[$(this).attr("href").match(/([^\/]+(?:\/dev)?(?:\?dep=1)?)$/)[0]]['prev'] + '.html',
					type: 'GET',
					data: {}
				}
			},
			position: {
				target: 'mouse',
				adjust: {
					x: 15
				},
				viewport: $(window),
				show: {
					delay: 120
				}
			},
			show: {
				effect: false
			}
		});
	});
});