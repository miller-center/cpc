/* add holdings data to expanded window for featured presidents */

jQuery.fn.getPresidentData = function() {
  var target = $(this[0]);
  var holdings = target.data('holdings');
  var partners = target.data('partners');
  var blurb = target.data('blurb');
  var name = jQuery("a img", target).attr("alt");
  var code = name+'<br/>'+blurb+'<br/>Items indexed: '+holdings+'<br/>Contributing Partners: '+partners;
  return code;
}

// this behavior must fire AFTER blocks have finished rendering
$(window).load(function() {
  var elementList = ['fp-01','fp-02','fp-03','fp-04', 'fp-05', 'fp-06', 'fp-07', 'fp-08', 'fp-09', 'fp-10', 'fp-11', 'fp-12'];
  jQuery.each(elementList, function(i, val) {
    var target = $('#'+val);
    if (target.length) {
      console.log('#'+val);
      var newDiv = $('#'+val+"t"); // see _home_promo.html.haml for div id convention
      if (newDiv.length > 0) {
        target.css("z-index", "-999"); // put original behind new div
        var text = $(target).getPresidentData();
        console.log(text);
        var link = target.children('a').clone();
        newDiv.prepend(link);
        newDiv.children('.featured-president-data').html(text);
        newDiv.css("z-indez", "999");
      }
    }
  });


});