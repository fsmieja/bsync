class Project < ActiveRecord::Base
  
  has_many :messages, :dependent => :destroy
  has_many :events, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  has_many :message_tags, :through => :messages, :source => :tags
  has_many :message_comments, :through => :messages, :source => :comments
  has_many :task_comments, :through => :tasks, :source => :comments
  has_many :message_comment_tags, :through => :message_comments, :source => :tags
  has_many :task_comment_tags, :through => :task_comments, :source => :tags
  
  def self.import_all_from_basecamp
    destroy_all(:condition => [ "basecamp_id NOT NULL" ])
    projects = Basecamp::Project.find(:all)
    projects.each do |p|
      if !find_by_basecamp_id(p.id)
        proj = new
        proj.copy_fields_from_basecamp(p)
        if !proj.save!
          return false
        end
      end 
    end
    true
  end
  
  def self.discover_new_from_basecamp
    ps = Basecamp::Project.find(:all)
    num_new=0
    ps.each do |p|
      if !find_by_basecamp_id(p.id)
        proj = new
        num_new+=1
        proj.copy_fields_from_basecamp(p)
        if !proj.save!
          return -1
        end
      end 
    end
    num_new
  end
  
  def copy_fields_from_basecamp basecamp_project
    self.name = basecamp_project.name
    self.created_on = basecamp_project.created_on
    self.last_changed_on = basecamp_project.last_changed_on
    self.status = basecamp_project.status
    self.company_name = basecamp_project.company.name
    self.basecamp_id = basecamp_project.id
    self.announcement = basecamp_project.announcement
  end  
  
  def disconnect_project
    self.basecamp_id = nil    
  end
end
