$(function() {
    $('input[name="rid"]').click(function() {
      action('setwertung',
        {
          "rid": this.value
        })
    });

    $('#wertungen').DataTable({
      "order": [1, 'asc'],
      "columns": [
        { "orderable": false },
        null, // id
        null, // name
        null, // abhängig
        null, // urkunde
        null  // preis
      ]
    });
})
