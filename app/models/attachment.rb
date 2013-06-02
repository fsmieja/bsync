class Attachment < ActiveRecord::Base
  
  belongs_to :comments
  belongs_to :messages
  


  def copy_fields_from_basecamp(basecamp_attachment)  
    self.basecamp_id = basecamp_attachment.content["id"]
    self.basecamp_url = basecamp_attachment.content["download_url"]
    self.author = basecamp_attachment.content["author"]
    self.name = basecamp_attachment.content["name"]
    self.attachment_type = basecamp_attachment.content["type"]
    self.filename = basecamp_attachment.filename
  end
end
