class Category < ActiveRecord::Base
  has_many :categorizations, dependent: :destroy
  has_many :quotes, :through => :categorizations

  validates :content, presence: true
  validates :content, uniqueness: { case_sensitive: false }

end