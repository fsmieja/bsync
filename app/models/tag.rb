class Tag < ActiveRecord::Base
  
  has_many :comment_taggings
  has_many :comments, :through => :comment_taggings
  has_many :message_taggings
  has_many :messages, :through => :message_taggings
  
  def self.create_tags(name,many=false)
    if many
      tags = name.gsub(/[ \t\r]/,'').split(/[\n;,]/)
      tags.each do |t|
        this_tag = new({:name => t})
        return false if !this_tag.save!
      end
    else
      this_tag = new({:name => name})
      return false if !this_tag.save!
    end
    true
  end
  
  def self.find_or_create_tag(tag_name)
    if tag_name.size<2
      return nil
    end
    return Tag.find_or_create_by_name(tag_name)
  end
end
