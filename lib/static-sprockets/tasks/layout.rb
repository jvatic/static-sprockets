require 'static-sprockets/compiler'

namespace :layout do
  task :compile do
    StaticSprockets::Compiler.compile_layout
  end

  task :gzip do
    StaticSprockets::Compiler.gzip_layout
  end
end
