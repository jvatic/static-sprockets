require 'rack-putty'

module StaticSprockets
  class App
    class Middleware < Rack::Putty::Middleware
    end

    require 'static-sprockets/app/asset_server'
    require 'static-sprockets/app/render_view'

    include Rack::Putty::Router

    module StackBase
      def self.call(env)
        [404, { 'Content-Type' => 'text/plain' }, ['Not Found']]
      end
    end

    stack_base StackBase

    class AccessControl < Middleware
      def action(env)
        env['response.headers'] ||= {}
        if @options[:allow_credentials]
          env['response.headers']['Access-Control-Allow-Credentials'] = 'true'
        end
        env['response.headers'].merge!(
          'Access-Control-Allow-Origin' => 'self',
          'Access-Control-Allow-Methods' => 'DELETE, GET, HEAD, PATCH, POST, PUT',
          'Access-Control-Allow-Headers' => 'Cache-Control, Pragma',
          'Access-Control-Max-Age' => '10000'
        )
        env
      end
    end

    class ContentSecurityPolicy < Middleware
      def action(env)
        env['response.headers'] ||= {}
        env['response.headers']["Content-Security-Policy"] = content_security_policy
        env
      end

      def content_security_policy
        [
          "font-src data: 'self'",
          "frame-src 'self'",
          "script-src 'self'",
          "default-src 'self'",
          "object-src 'none'",
          "img-src *",
          "connect-src *"
        ].join('; ')
      end
    end

    class Favicon < Middleware
      def action(env)
        env['REQUEST_PATH'].sub!(%r{/favicon}, "/assets/favicon")
        env['params'][:splat] = 'favicon.ico'
        env
      end
    end

    class MainLayout < Middleware
      def action(env)
        p ["MainLayout"]
        env['response.view'] = StaticSprockets.config[:layout]
        env
      end
    end

    get '/assets/*' do |b|
      b.use AssetServer
    end

    get '/favicon.ico' do |b|
      b.use Favicon
      b.use AssetServer
    end

    get '*' do |b|
      b.use ContentSecurityPolicy
      b.use MainLayout
      b.use RenderView
    end
  end
end
