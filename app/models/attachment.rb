class Attachment < ActiveRecord::Base
  
  belongs_to :comments
  belongs_to :messages
  


  def copy_fields_from_basecamp(basecamp_attachment)
    att_hash = basecamp_attachment.filename
    #self.basecamp_id = att_hash["id"]
    self.basecamp_url = att_hash["download_url"]
    self.author = att_hash["author_name"]
    self.name = att_hash["name"]
    self.attachment_type = att_hash["type"]
    self.filename = att_hash["name"]
  end
end
