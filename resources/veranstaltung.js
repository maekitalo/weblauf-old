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

var veranstaltungenTable = $('#veranstaltungen').DataTable({
    ajax: {
        url: 'veranstaltung.json',
        dataSrc: ''
    },
    order: [0, 'desc'],
    select: true,
    columns: [
        { data: 'vid' },
        { data: 'name' },
        { data: 'datum' },
        { data: 'ort' },
        { data: 'logo' }
      ]
});

veranstaltungenTable.on('select', function (e, dt, type, indexes) {
    console.log(veranstaltungenTable.rows(indexes).data()[0].vid);
    tntnet.action('setveranstaltung', {
        vid: veranstaltungenTable.rows(indexes).data()[0].vid
    });
});

var initdialog = function() {
        $('label').css('width', '100px');
        var dialog = $(this).dialog({
          height: 300,
          width: 400,
          modal: true,
          buttons: {
            "Speichern": function() {
              tntnet.action('veranstaltung/save', {
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
            tntnet.action('veranstaltung/del', {
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
