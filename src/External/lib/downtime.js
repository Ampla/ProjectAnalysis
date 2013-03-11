$(document).ready(function() {

    $(".summary").click(
        function() {
            var anchor = $(this);
            var details = anchor.next(".details");
            if (details.css("display") == "none") {
                details.show();
            }
            else {
                details.hide();
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
