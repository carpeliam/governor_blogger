class GovernorAddBlogger < ActiveRecord::Migration
  def self.up
    add_column :<%= mapping.plural %>, :blogger_id, :string
  end

  def self.down
    remove_column :<%= mapping.plural %>, :blogger_id
  end
end
