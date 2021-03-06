class Category < ApplicationRecord
  has_many :category_materials, dependent: :destroy
  has_many :materials, through: :category_materials
  has_many :constructions, dependent: :destroy
  has_many :estimate_details
  has_many :invoice_details
  acts_as_list
  
  attr_accessor :material_ids  # コピーするデフォルト素材のid配列を受け取る
  attr_accessor :construction_ids  # コピーするデフォルト工事のid配列を受け取る
  attr_accessor :accept
  
  enum classification: [:common, :construction, :material]
  
  validates :name, presence: true, uniqueness: true, length: { maximum: 30 }
                   
end
