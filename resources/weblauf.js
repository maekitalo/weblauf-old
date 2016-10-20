function goToScreen(screen) {
    $('#content').load(screen, {}, function() {
        $.getScript(screen + '.js')
    });
}

$(function() {
    $.datepicker.setDefaults({
          dateFormat: "dd.mm.yy"
    })

    $.noty.defaults.layout = 'topRight';

    $('#nav').hover(
        function() {
            $('#content').fadeOut();
        },
        function() {
            $('#content').fadeIn();
        });

    $('#nav a').click(function(ev) {
        ev.preventDefault();
        goToScreen($(this).attr('href'));
    })
})
