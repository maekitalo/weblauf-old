$(function () {
    $('input[name="nachname"]').width('200px').focus();
    $('input[name="vorname"]').width('200px');
    $('input[name="verein"]').width('200px');
    $('input[name="jahrgang"]').width('50px');
    $('input[name="strasse"]').width('200px');
    $('input[name="plz"]').width('50px');
    $('input[name="ort"]').width('150px');
    $('input[name="land"]').width('150px');
    $('input[name="nationalitaet"]').width('150px');
    $('input[name="email"]').width('150px');

    $('.viewlong').hide();
    $('input[name="langeanzeige"]').click(function() {
        $('.viewlong').toggle();
    });

    var nachname = $('input[name="nachname"]');
    nachname.keyup(function() {
        $('#db').load('/personen.html', { search: nachname.val() });
    });
})
