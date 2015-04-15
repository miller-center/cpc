$(document).ready(function() {
  /* add holdings data to expanded window for featured presidents */
 
  $('div.featured-president').each(function() {
    var $target = $(this);
    var $holdings = $target.data('holdings');
    var $partners = $target.data('partners');
    var $blurb = $target.data('blurb');
    var $name = jQuery("a img", $target).attr("alt");
    var $code = $name+'<br/>'+$blurb+'<br/>Items indexed: '+$holdings+'<br/>Contributing Partners: '+$partners;
    $( this ).children('.featured-president-data').html($code);
  });


});
