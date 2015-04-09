$(document).ready(function() {
  /* add expand/collapse nav UI to facet fields with pivot facets */

  // $('#facet-date_pivot_field ul ul li span.facet-values').addClass('pivot-values-open');
  var openIcon =  "glyphicon-triangle-right";
  var closeIcon = "glyphicon-triangle-bottom";

  // annotate levels of the hierarchy
  $('#facet-date_pivot_field > div > ul > li').attr('data-level', '1');
  $('#facet-date_pivot_field > div > ul > li > ul > li').attr('data-level', '2');
  $('#facet-date_pivot_field > div > ul > li > ul > li > ul > li').attr('data-level', '3');



  /* collapse subheadings by default */
  // $("li[data-level='3']").slideToggle();

  $('#facet-date_pivot_field > div > ul > li > span.facet-values span.facet-label').before('<span class="pivot-values pivot-values-close glyphicon><span class="'+openIcon+'"></span></span>');
  $('#facet-date_pivot_field > div > ul > li > ul > li > span.facet-values span.facet-label').before('<span class="pivot-values pivot-values-close glyphicon><span class="'+openIcon+'"></span></span>');
  $('#facet-date_pivot_field > div > ul > li > ul > li > ul > li > span.facet-values span.facet-label').before('<span class="pivot-values pivot-values-invisible glyphicon><span class="glyphicon-asterisk"></span></span>');
  $('#facet-date_pivot_field > div > ul > li > span.facet-values > span.pivot-values').attr('data-content', 'F');
  $('#facet-date_pivot_field > div > ul > li > span.facet-values > span.pivot-values').click(function() {
      $(this).attr('data-content', $(this).attr('data-content') == 'T' ? 'F' : 'T');
      var target = $(this).parent().parent().children('ul.pivot-facet');

      if ($(this).attr('data-content') == 'T') {
          $(this).removeClass(closeIcon);
          $(this).addClass(openIcon);
          $(target).slideToggle();
      } else {
          $(this).removeClass(openIcon);
          $(this).addClass(closeIcon);
          $(target).slideToggle();
      }
  });

  /* repeat for children (decades) */
  $('#facet-date_pivot_field > div > ul > li > ul > li > span.facet-values > span.pivot-values').click(function() {
    $(this).attr('data-content', $(this).attr('data-content') == 'T' ? 'F' : 'T');
    var target = $(this).parent().parent().children('ul.pivot-facet');

    if ($(this).attr('data-content') == 'T') {
        $(this).removeClass(closeIcon);
        $(this).addClass(openIcon);
        $(target).slideToggle();
    } else {
        $(this).removeClass(openIcon);
        $(this).addClass(closeIcon);
        $(target).slideToggle();
    }   
  });

  $("li[data-level='2'] > span.facet-values > span.pivot-values").click();  
  $("li[data-level='1'] > span.facet-values > span.pivot-values").click();  


});
