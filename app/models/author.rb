class Author < ActiveRecord::Base
#  include Elasticsearch::Model
#  include Elasticsearch::Model::Callbacks

  has_many :quotes, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  def as_indexed_json(options={})
    as_json(
        only: [:name]
    )
  end
  def self.search(query)
    __elasticsearch__.search(
        {
            query: {
                #filtered: {
                #    filter: {
                #        prefix: {name: query}
                #    }
                #}
                query_string: {
                    query: "*#{query}*"
                }
            }
        }
    )
  end

end 

