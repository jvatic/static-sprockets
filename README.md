static-sprockets
================

Static app generator.

## Usage

```ruby
# config.rb
require 'static-sprockets'
StaticSprockets.configure(
  :asset_roots => ["./assets"],
  :asset_types => %w( javascripts stylesheets ),
  :layout => "./layout.html.erb",
  :layout_output_name => 'application.html',
  :output_dir => "./build"
)

# You may call sprockets_config any number of times
# to access the sprockets environment directly
StaticSprockets.sprockets_config do |sprockets_env|
  # ...
end

StaticSprockets.sprockets_config do |sprockets_env|
  # ...
end
```

```ruby
# config.ru
require 'bundler'
Bundler.require

require './config'

require 'static-sprockets/app'
map '/' do
  run StaticSprockets::App.new
end
```

```ruby
# Rakefile
require 'bundler/setup'

require './config'
require 'static-sprockets/tasks/assets'
require 'static-sprockets/tasks/layout'

task :compile => ["assets:precompile", "layout:compile"] do
end
```

```ruby
# Gemfile
source 'https://rubygems.org'

gem 'puma'
gem 'rake'
gem 'mimetype-fu'

gem 'static-sprockets', :git => 'git://github.com/jvatic/static-sprockets.git', :branch => 'master'
gem 'rack-putty', :git => 'git://github.com/tent/rack-putty.git', :branch => 'master'
gem 'sprockets', '~> 2.0', :git => 'git://github.com/jvaill/sprockets.git', :branch => 'master'
```

**run dev server**
```
bundle exec rackup
```

**compile app**
```
bundle exec rake compile
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Note that the actual Javascript application is located in `lib/assets/javascripts`. [Sprockets](https://github.com/sstephenson/sprockets) is used to compile and concatenate files.
