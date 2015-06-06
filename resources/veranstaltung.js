$(function() {
    $('input[name="vid"]').click(function() {
      $.getJSON('/setveranstaltung.json',
        {
          "vid": this.value
        },
        function (reply) {
          document.title = reply.name;
        })
    });

    $('#veranstaltungen').DataTable({
      "order": [ 1, 'desc' ],
      "columns": [
        { "orderable": false },
        null, // id
        null, // datum
        null, // name
        null, // ort
        null  // logo
      ]
    });

    var initdialog = function() {
            $('label').css('width', '100px');
            var dialog = $(this).dialog({
              height: 300,
              width: 400,
              modal: true,
              buttons: {
                Speichern: function() {
                  // TODO
                  dialog.dialog("close");
                  document.location.reload();
                },
                Abbrechen: function() {
                  dialog.dialog("close");
                }
              }
            });
            $('.datum').datepicker();
          };

    $('#neu').click(function() {
      $('#dialog')
        .load('veranstaltung.html?neu=1', initdialog)
    });

    $('#bearbeiten').click(function() {
      $('#dialog')
        .load('veranstaltung.html', initdialog)
    });

})
