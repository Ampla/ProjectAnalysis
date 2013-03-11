$(document).ready(function() {

    $(".details").hide();
    $(".collapse").addClass('open');
    $(".summary").addClass('close');
    $(".collapsed").addClass('collapse').addClass('close').removeClass('collapsed').next().hide();

    $(".summary").click(
        function() {
            var anchor = $(this);
            var details = anchor.next(".details");
            if (details.css("display") == "none") {
                //details.show();
                details.slideDown('fast');
                anchor.addClass('open');
                anchor.removeClass('close');
            }
            else {
                //details.hide();
                details.slideUp('fast');
                anchor.addClass('close');
                anchor.removeClass('open');
            }
            return false;
        }
    );

    $(".collapse").click(
        function() {
            var anchor = $(this);
            var details = anchor.next();
            if (details.css("display") == "none") {
                details.slideDown('fast');
                //details.show();
                anchor.addClass('open');
                anchor.removeClass('close');
            }
            else {
                anchor.toggleClass('close', 'open');
                anchor.addClass('close');
                anchor.removeClass('open');
                details.slideUp('fast');
                //details.hide();
            }
            return false;
        }
    );


    $(".show-all").click(
        function(e) {
            e.preventDefault();
            var anchor = $(this);
            var table = anchor.next("table");
            var hidden = table.find(".details:hidden");
            var shown = table.find(".details:visible");

            if (anchor.text() == 'Show All') {
                // some still hidden so show them
                hidden.show();
                anchor.text("Hide all");
            } else {
                // none hidden so toggle
                shown.toggle();
                anchor.text("Show All");
            }

            return false;
        }
    );

});
