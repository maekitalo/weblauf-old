$(function() {
    $('input[name="rid"]').click(function() {
      $.getJSON('/setwertung.json',
        {
          "rid": this.value
        })
    });

    $('#wertungen').DataTable({
      "order": [1, 'asc']
    });
})
