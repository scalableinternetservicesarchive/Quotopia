require 'digest/md5'

class Quote < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :author, :touch => true
  # belongs_to :submitter, class_name: 'User', foreign_key: 'user_id' if keep tracking of user-submissions does not work
  belongs_to :user
  has_many :votes, dependent: :destroy
  has_many :users, :through => :votes
  has_many :comments, dependent: :destroy
  has_many :categorizations, dependent: :destroy
  has_many :categories, :through => :categorizations # , after_remove: proc { |q| q.touch }
  has_many :favorite_quotes, dependent: :destroy
  has_many :favorited_by, through: :favorite_quotes, source: :user  # users that favorite a quote

  accepts_nested_attributes_for :author
  accepts_nested_attributes_for :categories

  validates :content, presence: true
  validates :content_hash, uniqueness: {scope: :author, case_sensitive: false,
                    message: "quote should be unique per author"}
  validates :author, presence: true
  validates :user, presence: true

  def as_indexed_json(options={})
      as_json(
          only: [:id, :content, :author_id, :vote_count, :updated_at],
          include: {
            categories: {only: :content},
            author: {only: :name}
          }
      )
  end

  # This determines how many quotes to display per page
  paginates_per 7

  # def self.cache_key
  #   Digest::MD5.hexdigest "#{maximum(:updated_at)}.try(:to_i)-#{count}"
  # end

  trigger.after(:insert) do
    "UPDATE authors SET quote_count = quote_count + 1 WHERE NEW.author_id = id;"
  end

  trigger.after(:update) do
    "UPDATE authors SET quote_count = quote_count + 1 WHERE NEW.author_id = id;"\
    "UPDATE authors SET quote_count = quote_count - 1 WHERE OLD.author_id = id;"
  end

  trigger.after(:delete) do
    "UPDATE authors SET quote_count = quote_count - 1 WHERE OLD.author_id = id;"
  end

  def self.search(search)
    @select = "quotes.id, quotes.content, quotes.vote_count, authors.name as author_name, authors.id as author_id"
    @quote = Quote.joins(:author, :categories)
                  .select(@select)
                  .where("categories.content LIKE ?", "#{search}")

    if @quote.empty?
      @quote = Quote.joins(:author)
                    .select(@select)
                    .where("authors.name LIKE ? or content LIKE ?", "%#{search}%", "%#{search}%")
    end

    return @quote
  end

  def category_list=(categories_string)
    category_names = categories_string.split(",").collect{ |category|
      category.strip.downcase
    }.uniq
    @categories = category_names.collect{ |name| Category.find_or_create_by(content: name)}
    self.categories = @categories
  end

  def category_list
    self.categories.collect do |category|
      category.content
      end.join(", ")
  end

  def as_json(options={})
    super(:only => [:id, :content, :author_id, :updated_at],
    :include => {
        :author => {:only => [:id, :name]},
        :categories => {:only => [:content]}
    })
  end

end
