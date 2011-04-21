class GovernorAddBlogger < ActiveRecord::Migration
  def self.up
    add_column :articles, :blogger_id, :string
  end

  def self.down
    remove_column :articles, :blogger_id
  end
end
