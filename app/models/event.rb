class Event < ActiveRecord::Base

  belongs_to :project
#  has_many :comments, :dependent => :destroy
    
  def self.get_count(proj)
    proj.events.count
  end  
  
  def self.get_bc_count(proj, from_bc = false)
    num = 0
    if proj.basecamp_id   
      if from_bc
        events = get_all_bc_events_in_project(proj)
        num = events.count
        proj.available_events = num
        proj.save!
      else
        num = proj.available_events
      end
    end
    num
  end
  
  def self.get_all_bc_events_in_project(proj)
    #Basecamp::Message.find(:all, :params => { :project_id => proj.basecamp_id }, :from => :archive)
    recs = []
    page_no = 1
    r = get_bc_records page_no, proj
    page_no += 1
    keep_getting = true
    while (keep_getting) do
      if r == nil || r.count == 0
        keep_getting = false
      else
        recs += r
        r = get_bc_records page_no, proj
        page_no += 1
      end    
    end 
#    Basecamp::Message.archive(proj.basecamp_id)
    recs
  end

  def self.get_bc_records(page_no, proj)
    Basecamp.records "calendar-entry", "/projects/#{proj.basecamp_id}/calendar_entries/calendar_events", :find => :all, :page => page_no
  end
    
  def self.import_all_from_basecamp_project(project)
    Event.destroy_all(:project_id => project.id)
    bc_list = get_all_bc_events_in_project(project)
    bc_list.each do |ev|
      event = project.events.build
      event.copy_fields_from_basecamp(ev)
      if !event.save!
        return false
      end
      #sleep 1
     end
    true
  end
    
  def self.destroy_project_events(project)
     Event.destroy_all(:project_id => project.id)
  end
  
  def self.discover_new_from_basecamp(project)
   # bc_list = Basecamp::Message.find(:all, :params => { :project_id => project.basecamp_id}, :from => :archive)
   bc_list = get_all_bc_events_in_project(project)
   bc_list.each do |ev|
      if !find_by_basecamp_id(ev.id)
        event = project.events.build
        event.copy_fields_from_basecamp(ev)
        if !event.save!
          return false
        end
        sleep 1
        #Comment.discover_new_from_basecamp_message(bcm.id)
       
      end 
    end
    true
  end
      
  def copy_fields_from_basecamp(basecamp_event)
    self.title = basecamp_event.title
    self.start_at = basecamp_event.due_at
    self.created_on = basecamp_event.created_on
    self.basecamp_id = basecamp_event.id
    self.creator = basecamp_event.creator_name
   true
  end  


end
