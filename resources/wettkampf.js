$(function() {
    $('input[name="wid"]').click(function() {
      action('setwettkampf',
        {
          "wid": this.value
        })
    });

    $('#wettkaempfe').DataTable({
      "order": [1, 'asc'],
      "columns": [
        { "orderable": false },
        null, // id
        null, // name
        null, // art
        null, // Startnummer von
        null, // Startnummer bis
        null  // Startzeit
      ]
    });
})
