module GovernorBlogger
  class Blogger
    def initialize(article)
      @article = article
      @blogger = GData::Client::Blogger.new
      
      # log in
      @blogger.clientlogin(GovernorBlogger.config.username, GovernorBlogger.config.password)
    end
    
    def post
      entry = Nokogiri::XML::Builder.new do |xml|
        xml.entry(:xmlns => 'http://www.w3.org/2005/Atom') do
          xml.title @article.title, :type => 'text'
          xml.content(:type => 'xhtml') { |content| content << body }
        end
      end.to_xml
      # post to page, retrieve blogger_id
      response = @blogger.post(page, entry)
      post_id = response.headers['location'].match(%r{posts/default/(\d+)})[1]
      post_id
    end
    
    def put
      # retrieve post
      xml = @blogger.get(page).to_xml
      # transform XML
      xml.children.detect{|e| e.name == 'title' }.text = @article.title
      xml.children.detect{|e| e.name == 'content' }.text = body
      # post back to page
      @blogger.put(page, xml)
    end
    
    private
    def body
      Nokogiri::XML.fragment(Governor::Formatters.format_article @article).to_s
    end
    
    def page
      "http://www.blogger.com/feeds/#{GovernorBlogger.config.blog_id}/posts/default/#{@article.blogger_id}".chomp '/'
    end
  end
end
      