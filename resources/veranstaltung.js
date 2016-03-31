$(function() {
    function reload()
    {
        window.location.reload();
    }

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
      stateSave: true,
      order: [ 1, 'desc' ],
      columns: [
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
                "Speichern": function() {
                  action('veranstaltung/save', {
                      vid: $('#vid').val(),
                      name: $('#name').val(),
                      ort: $('#ort').val(),
                      datum: $('#datum').val(),
                      logo: $('#logo').val()
                  },
                  function () {
                      information("Veranstaltung gespeichert");
                      dialog.dialog("close");
                      reload();
                  })
                },
                "Abbrechen": function() {
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
        var dialog = $('#dialog-confirm').dialog({
            resizable: false,
            height: 240,
            width: 400,
            modal: true,
            buttons: {
              "Veranstaltung löschen": function() {
                action('veranstaltung/del', {
                },
                function () {
                    information("Veranstaltung gelöscht");
                    dialog.dialog( "close" );
                    reload();
                })
              },
              "Abbrechen": function() {
                $( this ).dialog( "close" );
              }
            }
        });
    });

})
