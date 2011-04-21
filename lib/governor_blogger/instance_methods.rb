module GovernorBlogger
  module InstanceMethods
    def post_to_blogger
      # TODO stick these in a config
      user = 'username'
      pass = 'password'
      blog_id = 'blog_id'
    
      b = GData::Client::Blogger.new
      post = Governor::Formatters.format_article self
      entry = Nokogiri::XML::Builder.new do |xml|
        xml.entry(:xmlns => 'http://www.w3.org/2005/Atom') do
          xml.title self.title, :type => 'text'
          xml.content(:type => 'xhtml') { |content| content << Nokogiri::XML.fragment(post).to_s }
        end
      end.to_xml

      begin
        # user, pass, and blog_id need to come from config
        b.clientlogin(user, pass)
        page = "http://www.blogger.com/feeds/#{blog_id}/posts/default"

        response = b.post(page, entry)
        post_id = response.headers['location'].match(%r{posts/default/(\d+)})[1]

        self.update_attribute :blogger_id, post_id
      rescue GData::Client::BadRequestError => bre
        # FIXME do something intelligent
        puts bre.message
      end
    end
  
    def post_to_blogger_in_background
      run_in_background :post_to_blogger
    end
  end
end