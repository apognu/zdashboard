$(function()
{
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
