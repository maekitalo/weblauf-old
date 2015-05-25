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
})
