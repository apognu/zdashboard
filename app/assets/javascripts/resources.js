$(function()
{
  $("#user_zarafaSendAsPrivilege").select2({
    multiple: true,
    tokenSeparators: [','],
    minimumInputLength: 1,
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
    console.log("pass => "+$(this).val());
    if ($(this).val().length > 0) {
      console.log("request");
      if (xhr != null)
        xhr.abort();
      xhr = $.ajax({
        url: '/resources',
        type: 'POST',
        async:true,
        data: $("#search_resources").serialize(),
        success: function(res){
          $("#resources_list tbody").empty().html(res);
          xhr = null;
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
});
