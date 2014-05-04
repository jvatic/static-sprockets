require 'static-sprockets/version'

module StaticSprockets
  def self.config
    @config ||= {}
  end

  def self.configure(config = {})
    @config = {
      :path_prefix => ENV['PATH_PREFIX'],
      :asset_root => "/assets"
    }.merge(config)
  end

  def self.new(config = {})
    configure(config)
    require 'static-sprockets/app'
    App.new
  end

  def self.sprockets_config_blocks
    @sprockets_config_blocks ||= []
  end

  def self.sprockets_config(&block)
    sprockets_config_blocks.push(block)
  end
end
