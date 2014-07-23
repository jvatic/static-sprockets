require 'sprockets'
require 'sprockets-sass'
require 'sprockets-helpers'
require 'sass'
require 'mimetype_fu'

module StaticSprockets
  class App
    class AssetServer < Middleware
      DEFAULT_MIME = 'application/octet-stream'.freeze

      module SprocketsHelpers
        AssetNotFoundError = Class.new(StandardError)
        def asset_path(source, options = {})
          source = source.sub(/[#?].+?\Z/, '')
          asset = environment.find_asset(source)
          raise AssetNotFoundError.new("#{source.inspect} does not exist within #{environment.paths.inspect}!") unless asset
          if options[:full_path]
            StaticSprockets.config[:asset_root].to_s + "/#{asset.digest_path}"
          else
            "./#{asset.digest_path}"
          end
        end
      end

      def self.sprockets_environment
        @environment ||= begin
          environment = Sprockets::Environment.new do |env|
            env.logger = Logger.new(@logfile || STDOUT)
            env.context_class.class_eval do
              include SprocketsHelpers
            end

            env.cache = Sprockets::Cache::FileStore.new(StaticSprockets.config[:asset_cache_dir]) if StaticSprockets.config[:asset_cache_dir]
          end

          paths = StaticSprockets.config[:asset_types]
          StaticSprockets.config[:asset_roots].each do |asset_root|
            paths.each do |path|
              environment.append_path(File.join(asset_root, path))
            end
          end

          StaticSprockets.sprockets_config_blocks.each do |block|
            block.call(environment)
          end

          environment
        end
      end

      def initialize(app, options = {})
        super

        @sprockets_environment = self.class.sprockets_environment
        @assets_dir = File.join(StaticSprockets.config[:output_dir], "assets")
      end

      def action(env)
        asset_name = env['params'][:splat]
        compiled_path = File.join(@assets_dir, asset_name)

        if File.exists?(compiled_path)
          [200, { 'Content-Type' => asset_mime_type(asset_name) }, [File.read(compiled_path)]]
        else
          new_env = env.clone
          new_env["PATH_INFO"] = env["REQUEST_PATH"].sub(%r{\A/assets}, '')
          status, headers, body = @sprockets_environment.call(new_env)
          headers.delete(Rack::Mount::RouteSet::X_CASCADE)
          [status, headers, body]
        end
      end

      private

      def asset_mime_type(asset_name)
        mime = File.mime_type?(asset_name)
        mime == 'unknown/unknown' ? DEFAULT_MIME : mime
      end

    end
  end
end
