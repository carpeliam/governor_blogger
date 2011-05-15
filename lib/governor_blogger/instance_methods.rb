module GovernorBlogger
  module InstanceMethods
    def post_to_blogger
      b = GData::Client::Blogger.new
      body = Nokogiri::XML.fragment(Governor::Formatters.format_article self).to_s
      page = "http://www.blogger.com/feeds/#{GovernorBlogger.config.blog_id}/posts/default/#{blogger_id}".chomp '/'
      # log in
      b.clientlogin(GovernorBlogger.config.username, GovernorBlogger.config.password)
      
      if blogger_id.blank?
        # construct post
        entry = Nokogiri::XML::Builder.new do |xml|
          xml.entry(:xmlns => 'http://www.w3.org/2005/Atom') do
            xml.title self.title, :type => 'text'
            xml.content(:type => 'xhtml') { |content| content << body }
          end
        end.to_xml
        # post to page, retrieve blogger_id
        response = b.post(page, entry)
        post_id = response.headers['location'].match(%r{posts/default/(\d+)})[1]
        # update entry with blogger_id
        self.update_attribute :blogger_id, post_id
      else
        # retrieve post
        xml = b.get(page).to_xml
        # transform XML
        xml.children.detect{|e| e.name == 'title' }.text = self.title
        xml.children.detect{|e| e.name == 'content' }.text = body
        # post back to page
        b.put(page, xml)
      end
    end
  
    def post_to_blogger_in_background
      GovernorBackground.run('blogger_post', self)
    end
  end
end