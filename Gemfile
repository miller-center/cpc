source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.13'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'

# Use Haml for markup
gem 'haml'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
group :production do
  gem 'therubyracer', platforms: :ruby
  gem 'dalli' # replacement for memcache
end

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'blacklight', ">= 5.7.1"

# use latest bootstrap-sass for glyphicons 1.9
gem 'bootstrap-sass', :git => 'https://github.com/twbs/bootstrap-sass.git', :tag => 'v3.3.3'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
group :development do 
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
	gem 'rb-readline'
end

gem "jettywrapper", "~> 1.7"
gem "devise"
gem "devise-guests", "~> 0.3"
gem "blacklight-marc", "~> 5.0"
gem "blacklight_advanced_search"
gem 'blacklight-sitemap', '~> 2.0.0'

# Install gems from each plugin
Dir.glob(File.join(File.dirname(__FILE__), 'data', '**', "Gemfile")) do |gemfile|
    eval(IO.read(gemfile), binding)
end

# Added at 2018-05-11 16:21:28 -0400 by imls:
gem "progressbar", "~> 1.9.0"
