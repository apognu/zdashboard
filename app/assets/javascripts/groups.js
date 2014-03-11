$(function()
{
  $('#group_members').select2({
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
          authenticity_token: $('#group_authenticity_token').val()
        };
      },
      results: function(data, page) {
        return { results: data };
      }
    }
  });
  if ($('#group_members').val() != null) {
    $('#group_members').select2('data', $.parseJSON($('#group_members').val()));
  }

  $('a[data-membertoggle]').click(function(event)
  {
    event.preventDefault();

    var input = $($('input[data-memberfield]')[0]);
    var newInput = input.parent('li').clone();
    newInput.find('input').val('');

    input.closest('ul').append(newInput);
  });

  $(document).on('click', 'a.memberremove', function(event)
  {
    event.preventDefault();

    if ($(this).closest('ul').find('li').length > 1)
    {
      $(this).closest('li').remove();
    }
  });

  $(document).on('click', 'a.delete_group', function(event) {
    return confirm("Are you sure you want to delete group '"+$(this).closest('tr').find('td:first').text()+"'");
  });

  var xhr = null;

  $("#search_groups input[name='search']").on('keyup', function() {
    var $input = $(this);
    if ($(this).val().length >= 3) {
      if (xhr != null)
        xhr.abort();
        $input.addClass('loading');
        xhr = $.ajax({
        url: '/groups',
        type: 'POST',
        async:true,
        data: $("#search_groups").serialize(),
        success: function(res){
          $("#groups_list tbody").empty().html(res);
          xhr = null;
          $input.removeClass('loading');
        },
        error: function(res) {
          console.log("ERROR");
        }
      });
    }
  });
});
