class Comment < ActiveRecord::Base
  belongs_to :message
  belongs_to :task
  has_many :attachments, :dependent => :destroy
  has_many :comment_taggings
  has_many :tags, :through => :comment_taggings
  has_one :project, :through => :message
  
  def self.get_count(proj)
    comments = []
    messages = Message.find_all_by_project_id(proj.id)
    if !messages.empty?
      messages.each do |m|
        these_comments = find_all_by_message_id(m.id)
        comments << these_comments if !these_comments.nil? && !these_comments.empty?           
      end
    end
    tasks = Task.find_all_by_project_id(proj.id)
    if !tasks.empty?
      tasks.each do |t|
        these_comments = find_all_by_task_id(t.id)
        comments << these_comments if !these_comments.nil? && !these_comments.empty?           
      end
    end
    comments.count
  end  

  def self.discover_new_from_basecamp_message(message)
    bc_list = Basecamp::Comment.find(:all, :params => { :post_id => message.basecamp_id})
    bc_list.each do |bcc|
      if !find_by_basecamp_id(bcc.id)
        cmt = message.comments.build
        cmt.copy_fields_from_basecamp(bcc)
        if !cmt.save!
          return false
        end
      end 
    end
    message.update_attribute(:num_comments,message.comments.count) 
    true
  end  

  def self.discover_new_from_basecamp_task task
    bc_list = Basecamp::Comment.find(:all, :params => { :todo_item_id => task.basecamp_id} )
    bc_list.each do |bcc|
      if !find_by_basecamp_id(bcc.id)
        cmt = task.comments.build
        cmt.copy_fields_from_basecamp(bcc)
        if !cmt.save!
          return false
        end
      end 
    end
    task.update_attribute(:num_comments,task.comments.count) 
    return true
  end
  
  def self.import_all_from_basecamp_message message
    Comment.destroy_all(:message_id => message.id)
    bc_list = Basecamp::Comment.find(:all, :params => { :post_id => message.basecamp_id} )
    bc_list.each do |bcm|
      cmt = Basecamp::Comment.find(bcm.id)
      comment = message.comments.build
      comment.copy_fields_from_basecamp(cmt)
      if !comment.save!
        return false
      end
    end
    message.update_attribute(:num_comments,message.comments.count)
    return true
  end

  def self.import_all_from_basecamp_task task
    Comment.destroy_all(:task_id => task.id)
    bc_list = Basecamp::Comment.find(:all, :params => { :todo_item_id => task.basecamp_id} )
    bc_list.each do |bcm|
      cmt = Basecamp::Comment.find(bcm.id)
      comment = task.comments.build
      comment.copy_fields_from_basecamp(cmt)
      if !comment.save!
        return false
      end
    end
    task.update_attribute(:num_comments,task.comments.count) 
    return true
  end

  def copy_fields_from_basecamp basecamp_comment, summary=false
    self.posted_on = basecamp_comment.created_at
    if !summary
      self.content = basecamp_comment.body
      self.author = basecamp_comment.author_name
      self.basecamp_id = basecamp_comment.id
      if !basecamp_comment.attachments.empty?
        self.attachments.destroy_all
        return self.copy_attachments_from_basecamp(basecamp_comment.attachments)
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
    true
  end  

end
