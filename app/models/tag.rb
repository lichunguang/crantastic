# == Schema Information
# Schema version: 20090608185426
#
# Table name: tag
#
#  id          :integer         not null, primary key
#  name        :string(255)     not null
#  full_name   :string(255)
#  description :text
#  task_view   :boolean
#  created_at  :datetime
#  updated_at  :datetime
#

class Tag < ActiveRecord::Base
  default_scope :order => "LOWER(name) ASC"
  named_scope :task_views, :conditions => { :task_view => true }

  # Taggings should be destroyed together with the tag
  has_many :taggings, :dependent => :destroy
  has_many :packages, :through => :taggings

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :task_view
  validates_format_of :name, :with => /^[A-Za-z\-][a-zA-Z\-\d ]*[A-Za-z\d]$/
  validates_length_of :name, :in => 2..100

  ###
  # @param tags [String] A list of tags, separated by comma
  # @return [Array] An array of Tag instances
  def self.parse_and_find_or_create(tags)
    tags.split(",").map.collect do |tag|
      self.find_or_create_with_like_by_name(tag.strip)
    end
  end

  # Case insensitive. NOTE: Could be done more elegantly with Postgres' ~*
  # operator. The method name is inherited, consider renaming in the future.
  def self.find_or_create_with_like_by_name(name)
    find(:first, :conditions => ["LOWER(name) = LOWER(?) AND task_view = 'f'", name]) ||
      create(:name => name)
  end

  def self.find_by_param(id, task_views = false)
    self.find_by_name(id, :conditions => { :task_view => task_views }
                      ) or raise ActiveRecord::RecordNotFound
  end

  def ==(other)
    other.is_a?(Tag) && other.name == self.name
  end

  def to_s
    name
  end

  def to_param
    name
  end

  # Tag weight for use in tag clouds.  Dividing by the number of letters
  # ensures that the area of the word is proportional to the number of
  # tagged objects, rather than just the height of the text.
  def weight
    count / name.length
  end

  ###
  # Returns the number of packages tagged with this tag.
  # NOTE: this could be cached later on
  #
  # @return [Fixnum]
  def count
    Tagging.count(:package_id, :conditions => "tag_id = #{self.id}")
  end
end