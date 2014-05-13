require 'sprockets'
require 'sprockets-sass'
require 'sprockets-helpers'
require 'sass'

module StaticSprockets
  class App
    class AssetServer < Middleware

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
      end

      def action(env)
        new_env = env.clone
        new_env["PATH_INFO"] = env["REQUEST_PATH"].sub(%r{\A/assets}, '')
        status, headers, body = @sprockets_environment.call(new_env)
        headers.delete(Rack::Mount::RouteSet::X_CASCADE)
        [status, headers, body]
      end

    end
  end
end
