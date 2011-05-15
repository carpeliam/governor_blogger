module GovernorBlogger
  module InstanceMethods
    def post_to_blogger_in_background
      GovernorBackground.run('blogger_post', self)
    end
  end
end