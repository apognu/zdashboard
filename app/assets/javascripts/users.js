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

  $("#search_users input[name='search']").on('keyup', function() {
    console.log("pass => "+$(this).val());
    if ($(this).val().length > 0) {
      console.log("request");
      if (xhr != null)
        xhr.abort();
      xhr = $.ajax({
        url: '/users',
        type: 'POST',
        async:true,
        data: $("#search_users").serialize(),
        success: function(res){
          $("#users_list tbody").empty().html(res);
          xhr = null;
        },
        error: function(res) {
          console.log("ERROR");
        }
      });
    }
  });

  if ($("#user_zarafaSendAsPrivilege").val() != null) {
    $("#user_zarafaSendAsPrivilege").select2('data', $.parseJSON($("#user_zarafaSendAsPrivilege").val()));
  }

  $('a[data-aliastoggle]').click(function(event)
  {
    event.preventDefault();

    var input = $($('input[data-aliasfield]')[0]);
    var newInput = input.parent('li').clone();
    newInput.find('input').val('');

    input.closest('ul').append(newInput);
  });

  $(document).on('click', 'a.aliasremove', function(event)
  {
    event.preventDefault();

    if ($(this).closest('ul').find('li').length > 1)
    {
      $(this).closest('li').remove();
    }
  });

  $('a[data-sendastoggle]').click(function(event)
  {
    event.preventDefault();

    var input = $($('input[data-sendasfield]')[0]);
    var newInput = input.parent('li').clone();
    newInput.find('input').val('');

    input.closest('ul').append(newInput);
  });

  $(document).on('click', 'a.sendasremove', function(event)
  {
    event.preventDefault();

    if ($(this).closest('ul').find('li').length > 1)
    {
      $(this).closest('li').remove();
    }
  });
});
