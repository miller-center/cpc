$(document).ready(function() {
  $('div#facet-potus_facet ul span a.facet_select').each(function() {
    $(this).text($(this).text().replace(/POTUS\d+/, ''));
  });
});