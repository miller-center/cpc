$(document).ready(function() {
  // For projects behind any kind of paywall
  $('dt.blacklight-alt_source_t').append('*');
  $('dt.blacklight-alt_source_t').parent().append('<dd class="blacklight-enhanced-note">* (may require payment or login)</dd>');

  // For projects that offer search interface, not individual URLs (e.g., Monroe Papers)
  $instructions = 'This link is to the partner\'s own search interface, where you will find instructions about retrieving the resource.';
  $('dt.blacklight-alt_source_portal_t').append('*');
  $('dt.blacklight-alt_source_portal_t').parent().append('<dd class="blacklight-enhanced-note">* '+$instructions+'</dd>');
});