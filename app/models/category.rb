class Category < ActiveRecord::Base
#  include Elasticsearch::Model
#  include Elasticsearch::Model::Callbacks

  # has_and_belongs_to_many :quotes
  has_many :categorizations, dependent: :destroy
  has_many :quotes, :through => :categorizations

  validates :content, presence: true
  validates :content, uniqueness: { case_sensitive: false }
    
  def as_indexed_json(options={})
    as_json(
        only: [:content]
    )
  end
end
