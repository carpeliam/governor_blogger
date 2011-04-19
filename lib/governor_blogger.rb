require 'governor_background'

blogger = Governor::Plugin.new('blogger')

article.run_in_background do
  b = GData::Client::Blogger.new
  entry = Nokogiri::XML::Builder.new do
    entry(:xmlns => 'http://www.w3.org/2005/Atom') do
      title self.title, :type => 'text'
      content(:type => 'xhtml') { |content| content << Nokogiri::XML.fragment(post).to_s }
    end
  end.to_xml
  
  begin
    # user, pass, and blog_id need to come from config
    b.clientlogin(user, pass)
    post = Governor::Formatters.format_article self
    page = "http://www.blogger.com/feeds/#{blog_id}/posts/default"
  
    response = b.post(page, entry)
    post_id = response.headers['location'].match(%r{posts/default/(\d+)})[1]
    
    article.update_attribute :blogger_id, post_id
  rescue GData::Client::BadRequestError => bre
    # handle the error
  end
end
