require 'governor_blogger/rails'
require 'governor_blogger/instance_methods'

blogger = Governor::Plugin.new('blogger')

blogger.register_model_callback do |base|
  base.send :include, GovernorBlogger::InstanceMethods
  base.after_save :post_to_blogger_in_background, :unless => Proc.new { |article|
    article.changed.any?{|attribute| !%w(id title description post author_id author_type created_at updated_at).include? attribute }
  }
end

Governor::PluginManager.register blogger

module GovernorBlogger
  class Configuration
    cattr_accessor :username, :password, :blog_id
  end
  @@config = Configuration.new
  mattr_reader :config
end