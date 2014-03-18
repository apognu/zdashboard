$(function()
{
  var xhr = null;

  $("#search_contacts input[name='search']").on('keyup', function() {
    var $input = $(this);
    if ($(this).val().length >= 3) {
      if (xhr != null)
        xhr.abort();
      $input.addClass('loading');
      xhr = $.ajax({
        url: '/contacts',
        type: 'POST',
        async:true,
        data: $("#search_contacts").serialize(),
        success: function(res){
          $("#contacts_list tbody").empty().html(res);
          xhr = null;
          $input.removeClass('loading');
        },
        error: function(res) {
          console.log("ERROR");
        }
      });
    }
  });

  $(document).on('click', 'a.delete_contact', function(event) {
    return confirm("Are you sure you want to delete contact '"+$(this).closest('tr').find('td:first').text()+"'");
  });

  $('#contact_groups').select2({
    multiple: true,
    tokenSeparators: [','],
    minimumInputLength: 3,
    ajax: {
      url:'/groups/list/',
      type: 'POST',
      dataType: 'json',
      data: function(term, page) {
        return {
          q: term,
          authenticity_token: $('#contact_authenticity_token').val()
        };
      },
      results: function(data, page) {
        return { results: data };
      }
    }
  });
  if ($('#contact_groups').val() != null && $('#contact_groups').val() != "") {
    $('#contact_groups').select2('data', $.parseJSON($('#contact_groups').val()));
  }

});
