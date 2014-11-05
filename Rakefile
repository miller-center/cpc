# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

CpcBlacklight::Application.load_tasks

ZIP_URL = "https://github.com/projectblacklight/blacklight-jetty/archive/v4.6.0.zip"
require 'jettywrapper'
require 'blacklight-sitemap'
Rake::BlacklightSitemapTask.new do |sm|
  # below are configuration options with their default values shown.

  # FIXME: you'll definitely want to change the resource_url value
  # base url for resources
  sm.resource_url = 'http://presidentialcollections.org'
  
  # FIXME: you'll definitely want to change the public_url value
  # base url for public directory of application where sitemaps will be placed
  sm.public_url = 'http://presidentialcollections.org'

  # base filename given to generated sitemap files
  sm.base_filename = 'cpc'

  # Is the gzip commandline tool available? Then why not gzip up your sitemaps to
  # save bandwidth?
  sm.gzip = false

  # for changefreq see http://sitemaps.org/protocol.php#changefreqdef
  # valid values are: always, hourly, daily, weekly, monthly, yearly, never
  sm.changefreq = 'monthly' # nil won't display a changefreq element

  # sitemaps can contain up to 50000 locations, but also must not be more than
  # 10 MB in size. Using the max value you can control the size of your files.
  # sm.max = 50000

  # Solr field used to retrieve from a document the value for the lastmod element for a url
  sm.lastmod_field = 'timestamp'

  # Solr field used to retrieve from a document the value for the priority element for a url
  # sm.priority_field = nil

  # Solr query sort parameter
  # sm.sort = '_docid_ asc'
  
  # Solr request handler. This can be useful when your Solr configuration already has
  # a filter query appended.
  sm.qt = 'search'
end
