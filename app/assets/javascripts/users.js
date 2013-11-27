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

  $("#search_users input[name='search']").on('keyup', function() {
    var $input = $(this);
    if ($(this).val().length >= 3) {
      if (xhr != null)
        xhr.abort();
      $input.addClass('loading');
      xhr = $.ajax({
        url: '/users',
        type: 'POST',
        async:true,
        data: $("#search_users").serialize(),
        success: function(res){
          $("#users_list tbody").empty().html(res);
          xhr = null;
          $input.removeClass('loading');
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

  $("#user_out_of_office").on('change', function() {
    if ($(this).is(':checked')) {
      $('#user_out_subject').attr('readonly', false);
      $('#user_out_message').attr('readonly', false);
    } else {
      $('#user_out_subject').attr('readonly', true);
      $('#user_out_message').attr('readonly', true);
    }
  });

  $(document).on('click', 'a.delete_user', function(event) {
    return confirm("Are you sure you want to delete user '"+$(this).closest('tr').find('td:first').text()+"'");
  });
});
