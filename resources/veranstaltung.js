$(function() {
    $('input[name="vid"]').click(function() {
      $.getJSON('/setveranstaltung.json',
        {
          "vid": this.value
        },
        function (reply) {
          document.title = reply.name;
          information("Veranstaltung <i>" + reply.name + "</i> ausgewählt");
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
        .load('veranstaltung.html', { neu: true }, initdialog)
    });

    $('#bearbeiten').click(function() {
      $('#dialog')
        .load('veranstaltung.html', initdialog)
    });

    $('#loeschen').click(function() {
        $( "#dialog-confirm" ).dialog({
            resizable: false,
            height: 240,
            width: 400,
            modal: true,
            buttons: {
              "Veranstaltung löschen": function() {
                // TODO
                $( this ).dialog( "close" );
              },
              Cancel: function() {
                $( this ).dialog( "close" );
              }
            }
        });
    });

})
