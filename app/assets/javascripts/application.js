// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require jquery.autogrow-textarea
//= require formize
//= require active-list.jquery
//= require bootstrap
//= require_tree .

(function($) {


    $(document).ready(function () {

       $("textarea").each(function(index) {
            var element = $(this);
            /* Adds autogrow function */
            element.autogrow();
        });



	$("*[data-refresh-with][data-refresh-every]").each(function(index) {
	    var element = $(this);
	    window.setInterval(function () {
		$.ajax(element.data("refresh-with"), {
		    dataType: 'html',
		    success: function (data, status, xhr) {
			element.html(data);
		    }
		});
	    }, parseInt(element.data("refresh-every")));
	    return true;
	});

	$(document).on("click", "[data-tabbox] a[data-toggle='tab']", function (event) {
	    var element = $(this), tabbox, tab_pane;
	    tabbox = element.closest("[data-tabbox]");
	    tab_pane = tabbox.find(".tab-pane.active").first();
	    $.ajax(tabbox.data("tabbox"), {
		data: {tab: tab_pane.attr("id")}
	    });
	});

    });

})(jQuery);