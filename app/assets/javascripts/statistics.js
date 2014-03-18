$(function() {
  var dg = new JustGage({
    id: "disk_gauge", 
    value: $('#disk_gauge').data('value'),
    min: 0,
    max: $('#disk_gauge').data('max'),
    title: "Disk space"
  });
  var lg = new JustGage({
    id: "license_gauge",
    value: ($('#license_gauge').data('max') == "unlimited") ? 1:$('#license_gauge').data('value'),
    min: 0,
    max: ($('#license_gauge').data('max') == "unlimited") ? 1:$('#license_gauge').data('max'),
    title: "License information",
    label: "license used"
  });
  dg.txtMin.attr('text', dg.txtMin.attrs.text + $('#disk_gauge').data('unit') + "o");
  dg.txtMax.attr('text', dg.txtMax.attrs.text + $('#disk_gauge').data('unit') + "o");
  dg.txtValue.attr('text', dg.txtValue.attrs.text + $('#disk_gauge').data('unit') + "o");
  dg.txtValue.attr('fill', dg.level.attrs.fill);
  if ($('#license_gauge').data('max') == "unlimited") {
    lg.level.attr('fill', "#aad60a")
    lg.txtValue.attr('text', $('#license_gauge').data('value'));
    lg.txtMax.attr('text', $('#license_gauge').data('max'));
  }
  lg.txtValue.attr('fill', lg.level.attrs.fill);
});
