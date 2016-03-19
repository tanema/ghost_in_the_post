require 'rails'
module GhostInThePost
  ATTRIBUTE_NAMES = [
    :phantomjs_path,
    :includes,
    :remove_js_tags,
    :timeout,
    :wait_event,
    :raise_js_errors,
    :raise_asset_errors,
    :debug,
  ]
  DEFAULT_TIMEOUT = 1000
  DEFAULT_WAIT_EVENT = "ghost_in_the_post:done"
  private_constant :ATTRIBUTE_NAMES
  cattr_accessor(*ATTRIBUTE_NAMES)

  #=======Defaults=========
  @@phantomjs_path = nil #setting this to nil helps testing
  @@timeout = DEFAULT_TIMEOUT
  @@wait_event = DEFAULT_WAIT_EVENT
  @@includes = []
  @@remove_js_tags = true
  @@raise_js_errors = true
  @@raise_asset_errors = true
  @@debug = false

  def self.config=(new_config={})
    self.complain_about_unknown_keys(new_config.keys)
    new_config.each do |key, value|
      self.send("#{key}=", value)
    end
    raise ArgumentError, "phantomjs not found at path `#{@@phantomjs_path}` provided to GhostInThePost" unless File.exist?(phantomjs_path)
  end


  def self.phantomjs_path
    @@phantomjs_path or raise ArgumentError, "GhostInThePost.config.phantomjs_path is not set"
  end

  def self.includes= to_include
    @@includes = Array(to_include)
  end

  private
  
  def self.complain_about_unknown_keys(keys)
    invalid_keys = keys - ATTRIBUTE_NAMES
    if invalid_keys.size > 0
      raise ArgumentError, "Unknown configuration parameters: #{invalid_keys}", caller(1)
    end
  end

end
 
require "ghost_in_the_post/version"

require "ghost_in_the_post/js_loaders"
require "ghost_in_the_post/js_inline"
require "ghost_in_the_post/phantom_transform"
require "ghost_in_the_post/mail_ghost"

require "ghost_in_the_post/ghost_on_command"
require "ghost_in_the_post/ghost_on_delivery"

require "ghost_in_the_post/mailer"
require "ghost_in_the_post/automatic"
