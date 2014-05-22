require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
if defined?(Bundler)
    # If you precompile assets before deploying to production, use this line
    Bundler.require *Rails.groups(:assets => %w(development, test))
    # If you want your assets lazily compiled in production, use this line
    #Bundler.require(*Rails.groups)
end


module CpcBlacklight
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    
    # Apparently Rails 4 needs help compiling these assets
    config.assets.enabled = true
    config.assets.precompile += [ 'glyphicons-halflings.png',
      'glyphicons-halflings-white.png',
      'glyphicons-halflings-regular.woff',
      'glyphicons-halflings-regular.ttf',
      'glyphicons-halflings-regular.svg' ]
  end
end
