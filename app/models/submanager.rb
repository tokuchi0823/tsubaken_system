class Submanager < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # アソシエーション
  belongs_to :manager
  
  has_many :submanager_events

  has_many :submanager_event_titles
  
  has_many :matter_submanagers, dependent: :destroy
  has_many :matters, through: :matter_submanagers
end
