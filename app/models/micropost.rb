class Micropost < ApplicationRecord
  belongs_to :user
  #The stabby lambda -> takes in a block and returns a Proc,
  default_scope -> {order(created_at: :desc)}
  validates :user_id, presence: true
  validates :content, presence: true , length: {maximum: 140}
end
