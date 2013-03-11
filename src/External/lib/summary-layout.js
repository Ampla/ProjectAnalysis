$(document).ready(function() {
    $("#menu-hide").click(function(e) {
        e.preventDefault();
        $(this.parentNode).toggle();
        $('.layout-across').toggle();
        $('.layout-down').toggle();
    });
    $("#show-layouts").click(function(e) {
        e.preventDefault();

        $(".layout-across").each(function() {
            $(this).append("<a href='#'><img class='arrow' src='images\\arrows\\down.png'/></a>");
        });

        $(".layout-down").each(function() {
            $(this).append("<a href='#'><img class='arrow' src='images\\arrows\\right.png'/></a>");
        });

        $(".layout-down a").click(function() {

            e.preventDefault();

            var link = $(this).parent();
            var tab = link.next('table');

            var tds = tab.children('tbody').children("tr").children('td');

            tab.before('<table><tbody><tr></tr></tbody></table>');

            var newTable = tab.prev('table');
            newTable.hide();
            var newRow = newTable.find(' tbody > tr');

            $.each(tds, function() {
                newRow.append($(this).clone(true));
            });

            tab.fadeOut('slow');
            newTable.fadeIn('slow');
            tab.remove();
            link.remove();
        });

        $(".layout-across a").click(function() {

            e.preventDefault();

            var link = $(this).parent();
            var tab = link.next('table');

            var tds = tab.children('tbody').children("tr").children('td');

            tab.before('<table><tbody></tbody></table>');

            var newTable = tab.prev('table');
            newTable.hide();
            var newRow = newTable.find(' tbody ');

            $.each(tds, function() {
                newRow.append('<tr></tr>').append($(this).clone(true));
            });

            tab.fadeOut('slow');
            newTable.fadeIn('slow');
            tab.remove();
            link.remove();
        });

    });
});
