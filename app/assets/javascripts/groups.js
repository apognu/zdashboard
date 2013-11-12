$(function()
{
  $('#group_members').select2({
    multiple: true,
    tokenSeparators: [','],
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
});
