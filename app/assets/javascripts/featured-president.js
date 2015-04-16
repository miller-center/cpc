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

jQuery.fn.getPresidentData = function() {
  var target = $(this[0]);
  var holdings = target.data('holdings');
  var partners = target.data('partners');
  var blurb = target.data('blurb');
  var name = jQuery("a img", target).attr("alt");
  var code = name+'<br/>'+blurb+'<br/>Items indexed: '+holdings+'<br/>Contributing Partners: '+partners;
  return code;
}

jQuery.fn.addStyles = function(w,h) {
  var o = $(this[0]);
  o.css("z-index", "999");
  o.css("position", "absolute");
  o.css('height', h);
  o.css('width', w);
}

$(window).load(function() {
  var elementList = ['fp-01','fp-02','fp-03','fp-04'];
  jQuery.each(elementList, function(i, val) {
    var target = $('#'+val);
    if (target.length) {
      console.log('#'+val);
      var rect   = target[0].getBoundingClientRect();
      if (rect != undefined) {
        target.css("z-index", "-999"); // put original behind new div
        var newDiv = $('#'+val+"t"); // see _home_promo.html.haml for div id convention
        var x = (rect.width)  ? rect.width : "50%";
        var y = (rect.height) ? rect.height : "50%";
        $(newDiv).addStyles(x,y);
        var text = $(target).getPresidentData();
        console.log(text);
        var link = target.children('a').clone();
        newDiv.prepend(link);
        newDiv.children('.featured-president-data').html(text);
      }
    }
  });


});