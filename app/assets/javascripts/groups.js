$(function()
{
  $('a.memberremove').click(function(event)
  {
    event.preventDefault();

    $(this).closest('li').remove();
  });
});
