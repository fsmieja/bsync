class CommentTagging < ActiveRecord::Base
  belongs_to :comment
  belongs_to :tag
end
