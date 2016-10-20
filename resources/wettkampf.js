$(function() {
    $('input[name="wid"]').click(function() {
      action('setwettkampf',
        {
          "wid": this.value
        })
    });

    $('#wettkaempfe').DataTable({
      ajax: {
          url: 'wettkampf.json',
          dataSrc: ''
      },
      order: [0, 'asc'],
      select: true,
      columns: [
          { data: 'wid' },
          { data: 'name' },
          { data: 'art' },
          { data: 'staVon' },
          { data: 'staBis' },
          { data: 'startzeit' }
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
              action('wettkampf/save', {
                  vid: $('#vid').val(),
                  name: $('#name').val(),
                  ort: $('#ort').val(),
                  datum: $('#datum').val()
              },
              function () {
                  information("Wettkampf gespeichert");
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
        .load('wettkampf.html', { neu: true }, initdialog)
    });

    $('#bearbeiten').click(function() {
      $('#dialog')
        .load('wettkampf.html', initdialog)
    });

    $('#loeschen').click(function() {
        var dialog = $('#dialog-confirm').dialog({
            resizable: false,
            height: 240,
            width: 400,
            modal: true,
            buttons: {
              "Wettkampf löschen": function() {
                action('wettkampf/del', {
                },
                function () {
                    information("Wettkampf gelöscht");
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
