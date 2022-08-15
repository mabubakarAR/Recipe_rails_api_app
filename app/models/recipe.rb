class Recipe < ApplicationRecord
  include ConstantValidatable

  # jitera-anchor-dont-touch: relations

  has_many :ingredients, dependent: :destroy
  belongs_to :category
  belongs_to :user
  has_many :reviews

  # jitera-anchor-dont-touch: enum
  enum difficulty: %w[easy normal challenging], _suffix: true

  # jitera-anchor-dont-touch: file
  # jitera-anchor-dont-touch: validation

  validates :title, length: { maximum: 255, minimum: 0, message: I18n.t('.out_of_range_error') }, presence: true
  validates :descriptions, length: { maximum: 65_535, minimum: 0, message: I18n.t('.out_of_range_error') },presence: true
  validates :time, length: { maximum: 255, minimum: 0, message: I18n.t('.out_of_range_error') }, presence: true
  validates :difficulty, presence: true
  
  accepts_nested_attributes_for :ingredients

  scope :filter_by_title, -> (title) { where("lower(title) LIKE ?", "%#{title}%")}
  scope :easy, -> { where(difficulty: :easy) }
  scope :normal, -> { where(difficulty: :normal) }
  scope :challenging, -> { where(difficulty: :challenging) }  
  scope :filter_by_difficulty, -> (difficulty) do
    send(difficulty)
  end
  scope :filter_by_time, -> (start_time, end_time) { where("(REGEXP_SUBSTR(time,'[0-9]+') >= (?)) AND (REGEXP_SUBSTR(time,'[0-9]+')) <= (?)", start_time, end_time) }

  def self.associations
    [:ingredients]
  end

  # jitera-anchor-dont-touch: reset_password
  class << self
    def search(title, difficulty, start_time, end_time)
      query = self
      query = query.filter_by_title(title) unless title.blank?
      query = query.filter_by_difficulty(difficulty) unless difficulty.blank?
      query.filter_by_time(start_time, end_time) if start_time and end_time
  
      # GET data with time filter with any formate given from user
      # query = filter_time(query,start_time,end_time) unless start_time.blank? and end_time.blank?
      query
    end
  end

  private

  # GET data with time filter with any formate given from user
  def self.filter_time(query, start_time, end_time)
    recipes = self.all 
    recipes.each do |a|
      time = in_mins(a.time)
      values_filtred_by_time << a if (time > in_mins(start_time)) and (time < in_mins(end_time))
    end
    values_filtred_by_time
  end

  def self.in_mins(time_str)
    time_str.gsub(/[^0-9]/, '').to_i
  end

end
