function formatDiskSpace(bytes) {
  bytes = parseInt(bytes);
  if (typeof bytes !== 'number') {
    return '';
  }
  if (bytes >= 1000000000) {
    return (bytes / 1000000000).toFixed(2) + 'TB';
  }
  if (bytes >= 1000000) {
    return (bytes / 1000000).toFixed(2) + 'GB';
  }
  return (bytes / 1000).toFixed(2) + 'MB';
}

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
  dg.txtMin.attr('text', dg.txtMin.attrs.text);
  dg.txtMax.attr('text', formatDiskSpace(dg.txtMax.attrs.text));
  dg.txtValue.attr('text', formatDiskSpace(dg.txtValue.attrs.text));
  dg.txtValue.attr('font-size', 20);
  dg.txtValue.attr('fill', dg.level.attrs.fill);
  if ($('#license_gauge').data('max') == "unlimited") {
    lg.level.attr('fill', "#aad60a")
    lg.txtValue.attr('text', $('#license_gauge').data('value'));
    lg.txtMax.attr('text', $('#license_gauge').data('max'));
  }
  lg.txtValue.attr('fill', lg.level.attrs.fill);
});
