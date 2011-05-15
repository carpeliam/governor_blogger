require 'governor_blogger/rails'
require 'governor_blogger/blogger'
require 'governor_blogger/instance_methods'

blogger = Governor::Plugin.new('blogger')

blogger.register_model_callback do |base|
  base.send :include, GovernorBlogger::InstanceMethods
  base.after_save :post_to_blogger_in_background, :unless => Proc.new { |article|
    article.changed.any?{|attribute| !%w(id title description post author_id author_type created_at updated_at).include? attribute }
  }
end

Governor::PluginManager.register blogger

GovernorBackground.register('blogger_post') do |article|
  # article.post_to_blogger
  blogger = GovernorBlogger::Blogger.new(article)
  id = if article.blogger_id.blank?
    blogger.post
  else
    blogger.put
  end
  article.reload.update_attribute :blogger_id, id
end

module GovernorBlogger
  class Configuration
    cattr_accessor :username, :password, :blog_id
  end
  @@config = Configuration.new
  mattr_reader :config
end