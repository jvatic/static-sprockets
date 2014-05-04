require 'static-sprockets/compiler'

namespace :assets do
  task :compile do
    StaticSprockets::Compiler.compile_assets
  end

  task :gzip do
    StaticSprockets::Compiler.gzip_assets
  end

  task :precompile => :gzip
end
