class Note < ActiveRecord::Base
  belongs_to :user
  scope :latest, -> { order('updated_at DESC').take! }
end
