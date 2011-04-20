require 'governor_blogger/rails'

blogger = Governor::Plugin.new('blogger')

blogger.register_model_callback do |base|
  module InstanceMethods
    def post_to_blogger
      puts "posting to blogger"
      run_in_background do
        # TODO stick these in a config
        user = 'username'
        pass = 'password'
        blog_id = 'blog_id'
        
        puts "posting to blogger in bg"
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
    end
  end
  base.send :include, InstanceMethods
  base.after_save :post_to_blogger
end

Governor::PluginManager.register blogger
