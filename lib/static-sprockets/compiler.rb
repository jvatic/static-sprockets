require 'static-sprockets'

module StaticSprockets
  module Compiler
    extend self

    attr_accessor :sprockets_environment, :assets_dir, :layout_dir, :layout_path, :layout_env

    def configure_sprockets(options = {})
      return if @sprockets_configured

      # Setup Sprockets Environment
      require 'rack-putty'
      require 'static-sprockets/app'

      self.sprockets_environment = StaticSprockets::App::AssetServer.sprockets_environment

      if options[:compress]
        # Setup asset compression
        require 'uglifier'
        require 'sprockets-rainpress'
        sprockets_environment.js_compressor = Uglifier.new
        sprockets_environment.css_compressor = Sprockets::Rainpress
      end

      self.assets_dir ||= File.join(StaticSprockets.config[:output_dir], "assets")

      @sprockets_configured = true
    end

    def configure_layout
      return if @layout_configured

      configure_sprockets

      self.layout_dir ||= StaticSprockets.config[:output_dir]
      self.layout_path ||= File.join(layout_dir, StaticSprockets.config[:layout_output_name])
      system  "mkdir -p #{layout_dir}"

      self.layout_env ||= {
        'response.view' => 'application'
      }

      @layout_configured = true
    end

    def compile_assets(options = {})
      configure_sprockets(options)

      manifest = Sprockets::Manifest.new(
        sprockets_environment,
        assets_dir,
        File.join(assets_dir, "manifest.json")
      )

      manifest.compile(StaticSprockets.config[:output_asset_names].to_a)
    end

    def compress_assets
      compile_assets(:compress => true)
    end

    def gzip_assets
      compile_assets

      Dir["#{assets_dir}/**/*.*"].reject { |f| f =~ /\.gz\z/ }.each do |f|
        system "gzip -c #{f} > #{f}.gz" unless File.exist?("#{f}.gz")
      end
    end

    def compile_layout(options = {})
      puts "Compiling layout..."

      configure_layout

      layout_path = self.layout_path

      require 'static-sprockets/app/render_view'
      _, _, body = StaticSprockets::App::RenderView.new(lambda {}).call(layout_env)

      system "rm #{layout_path}" if File.exists?(layout_path)
      File.open(layout_path, "w") do |file|
        file.write(body.first)
      end

      if options[:gzip]
        system "gzip -c #{layout_path} > #{layout_path}.gz"
      end

      puts "Layout compiled to #{layout_path}"
    end

    def gzip_layout
      compile_layout(:gzip => true)
    end
  end
end

