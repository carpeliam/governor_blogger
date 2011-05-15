require 'spec_helper'

module Governor
  describe GovernorBlogger do
    it "registers the plugin with Governor" do
      Governor::PluginManager.plugins.size == 1
    end
    
    it "registers a job with GovernorBackground" do
      GovernorBackground.retrieve('blogger_post').should_not be_blank
    end
    
    it "can post to blogger" do
      article = get_article
      article.blogger_id.should == 12345
    end

    it "can update blogger" do
      article = get_article
      blogger = mock('blogger')
      GovernorBlogger::Blogger.expects(:new).with(article).returns blogger
      blogger.expects(:put)
      article.update_attribute :title, "Some new title"
    end

    def get_article
      article = Factory.build(:article, :author => Factory(:user))
      blogger = mock('blogger')
      GovernorBlogger::Blogger.expects(:new).with(article).returns blogger
      blogger.expects(:post).returns 12345
      article.save
      article
    end
  end
end