require 'rails'
module GhostInThePost
  ATTRIBUTE_NAMES = [
    :phantomjs_path,
    :includes,
    :remove_js_tags,
    :timeout,
    :wait_event,
  ]
  DEFAULT_TIMEOUT = 1000
  DEFAULT_WAIT_EVENT = "ghost_in_the_post:done"
  private_constant :ATTRIBUTE_NAMES
  cattr_reader(*ATTRIBUTE_NAMES)

  @@phantomjs_path = nil #setting this to nil helps testing
  @@timeout = DEFAULT_TIMEOUT
  @@wait_event = DEFAULT_WAIT_EVENT
  @@includes = []
  @@remove_js_tags = true

  def self.config=(new_config={})
    self.complain_about_unknown_keys(new_config.keys)
    @@phantomjs_path = new_config[:phantomjs_path]
    @@includes = Array(new_config[:includes])
    @@remove_js_tags = new_config[:remove_js_tags].nil? ? true : new_config[:remove_js_tags]
    @@timeout = new_config[:timeout] || DEFAULT_TIMEOUT
    @@wait_event = new_config[:wait_event] || DEFAULT_WAIT_EVENT
    raise ArgumentError, "GhostInThePost.config.phantomjs_path is not set" if self.phantomjs_path.nil?
  end

  def self.phantomjs_path
    @@phantomjs_path or raise ArgumentError, "GhostInThePost.config.phantomjs_path is not set"
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

require "ghost_in_the_post/phantom_transform"
require "ghost_in_the_post/mail_ghost"

require "ghost_in_the_post/ghost_on_command"
require "ghost_in_the_post/ghost_on_delivery"

require "ghost_in_the_post/mailer"
require "ghost_in_the_post/automatic"
