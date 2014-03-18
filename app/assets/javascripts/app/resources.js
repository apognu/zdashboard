$(function()
{
  $("#user_zarafaSendAsPrivilege").select2({
    multiple: true,
    tokenSeparators: [','],
    minimumInputLength: 3,
    ajax: {
      url:'/users/list/',
      type: 'POST',
      dataType: 'json',
      data: function(term, page) {
        return {
          q: term,
          authenticity_token: $('#user_authenticity_token').val()
        };
      },
      results: function(data, page) {
        return { results: data };
      }
    }
  });

  var xhr = null;

  $("#search_resources input[name='search']").on('keyup', function() {
    var $input = $(this);
    if ($(this).val().length >= 3) {
      if (xhr != null)
        xhr.abort();
      $input.addClass('loading');
      xhr = $.ajax({
        url: '/resources',
        type: 'POST',
        async:true,
        data: $("#search_resources").serialize(),
        success: function(res){
          $("#resources_list tbody").empty().html(res);
          xhr = null;
          $input.removeClass('loading');
        },
        error: function(res) {
          console.log("ERROR");
        }
      });
    }
  });

  $("#resource_zarafaResourceType").on('change', function() {
    if ($(this).val() == "room") {
      $('#resource_zarafaResourceCapacity').attr('readonly', true);
      $('#resource_zarafaResourceCapacity').val(1);
    } else {
      $('#resource_zarafaResourceCapacity').attr('readonly', false);
    }
  });

  $(document).on('click', 'a.delete_resource', function(event) {
    return confirm("Are you sure you want to delete resource '"+$(this).closest('tr').find('td:first').text()+"'");
  });
});
