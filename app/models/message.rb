class Message < ActiveRecord::Base
  
  belongs_to :project
  has_many :comments, :dependent => :destroy
  has_many :attachments, :dependent => :destroy
  has_many :comment_tags, :through => :comments, :source => :tags
  has_many :message_taggings
  has_many :tags, :through => :message_taggings

  
  def self.get_count(proj)
    messages = find_all_by_project_id(proj.id)
    if proj.basecamp_id and messages.empty?  # not been imported yet
      messages = Basecamp::Message.find(:all, :params => { :project_id => proj.basecamp_id }, :from => :archive)
    elsif proj.basecamp_id
      return 0
    end
    messages.count
  end  
  
  def self.import_all_from_basecamp_project project
    Message.destroy_all(:project_id => project.id)
    bc_list = Basecamp::Message.find(:all, :params => { :project_id => project.basecamp_id}, :from => :archive)
    bc_list.each do |bcm|
      msg = Basecamp::Message.find(bcm.id)
      message = project.messages.build
      message.copy_fields_from_basecamp(msg)
      if !message.save!
        return false
      end
    end
    true
  end
    
  def self.discover_new_from_basecamp(project)
    bc_list = Basecamp::Message.find(:all, :params => { :project_id => project.basecamp_id}, :from => :archive)
    bc_list.each do |bcm|
      if !find_by_basecamp_id(bcm.id)
        msg = project.messages.build
        m = Basecamp::Message.find(bcm.id)
        msg.copy_fields_from_basecamp(m)
        if !msg.save!
          return false
        end
      end 
    end
    true
  end
      
  def copy_fields_from_basecamp(basecamp_message, summary=false)
    self.title = basecamp_message.title
    self.posted_on = basecamp_message.posted_on
    self.commented_on = basecamp_message.commented_at
    self.basecamp_id = basecamp_message.id
    if !summary
      self.content = basecamp_message.body
      self.author = basecamp_message.author_name
      if !basecamp_message.attachments.empty?
        self.attachments.destroy_all
        return copy_attachments_from_basecamp(basecamp_message.attachments)
      end
    end
    true
  end  

  def copy_attachments_from_basecamp(basecamp_attachments)
    basecamp_attachments.each do |a|      
      attachment = self.attachments.build
      attachment.copy_fields_from_basecamp(a)
      if !attachment.save!
        return false
      end
    end
    self.num_attachments = self.attachments.count
    return true
  end  
  
  def add_tag_numbers(tag_numbers)
    ts = tags + comment_tags 
    ts.each do |t|
      if tag_numbers[:tag_id => t.id].nil?
        tag_numbers[:tag_id => t.id] = 1
      else
        tag_numbers[:tag_id => t.id] += 1
      end
    end
  end
  
end
