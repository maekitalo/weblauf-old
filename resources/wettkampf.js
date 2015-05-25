$(function() {
    $('input[name="wid"]').click(function() {
      $.getJSON('/setwettkampf.json',
        {
          "wid": this.value
        })
    });

    $('#wettkaempfe').DataTable({
      "order": [1, 'asc']
    });
})
