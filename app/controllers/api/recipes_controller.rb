class Api::RecipesController < Api::BaseController
  # jitera-anchor-dont-touch: before_action_filter
  before_action :doorkeeper_authorize!, only: %w[index show update destroy]
  before_action :current_user_authenticate, only: %w[index show update destroy]

  # jitera-anchor-dont-touch: actions
  def destroy
    @recipe = Recipe.find_by(id: params[:id])
    @error_message = true unless @recipe&.destroy
  end

  def update
    return invalid_time_response if params[:recipes][:time].present? and !check_time_formate(params[:recipes][:time])
    @recipe = Recipe.find_by(id: params[:id])

    request = {}
    request.merge!('title' => params.dig(:recipes, :title))
    request.merge!('descriptions' => params.dig(:recipes, :descriptions))
    request.merge!('time' => params.dig(:recipes, :time))
    request.merge!('difficulty' => params.dig(:recipes, :difficulty))
    request.merge!('category_id' => params.dig(:recipes, :category_id))
    request.merge!('user_id' => params.dig(:recipes, :user_id))

    @error_object = @recipe.errors.messages unless @recipe.update(request)
  end

  def show
    @recipe = Recipe.find_by(id: params[:id])
    @error_message = true if @recipe.blank?
  end

  def create
    return invalid_time_response if !check_time_formate(params[:recipes][:time])

    @recipe = Recipe.new
    request = {}
    request.merge!('title' => params.dig(:recipes, :title))
    request.merge!('descriptions' => params.dig(:recipes, :descriptions))
    request.merge!('time' => convert_time_to_minutes(params.dig(:recipes, :time)))
    request.merge!('difficulty' => params.dig(:recipes, :difficulty))
    request.merge!('category_id' => params.dig(:recipes, :category_id))
    request.merge!('user_id' => params.dig(:recipes, :user_id))

    @recipe.assign_attributes(request)    
    @error_object = @recipe.errors.messages unless @recipe.save
  end

  # Send query params to get filtered data. These params are optional like 
  # /api/recipes?title=personal&difficulty=easy
  
  # send data in query params for filters accordingly.
  # difficulty = String e.g difficulty=easy
  # title = String e.g title=personal
  # To filter for time, start_time = string e.g 10mins, 1hour 10mins, and end_time = 15mins, 1hour 15mins

  def index
    # This will fetch all user without query parameters(filters)
    @recipes = Recipe.all

    # Getting searched or filtered Data
    title = params[:title].downcase if params[:title]
    difficulty = params[:difficulty] if params[:difficulty]
    start_time = params[:start_time] if params[:start_time]
    end_time = params[:end_time] if params[:end_time]
    @recipes = @recipes.search(title, difficulty, start_time, end_time) if title or difficulty or (start_time and end_time)
  end

  private

  def invalid_time_response
    render json: {success: false, error: "Time is not formatted accordingly. It soulde be like 15mins, 1hour, 1hour 10mins"}, status: 400
  end

  def check_time_formate(time)
    time.include?("min") or time.include?("hour")
  end

  def convert_time_to_minutes(time)
    formatted_time = time.gsub(/\d+/, ' \0 ').squish
    u = formatted_time.split.map {|z| z.include?("min") ? "minutes" : z}
    f = slices_without_repeats(u, 2)
    k = f.map {|l| l.join('')}
    k.join('+')
  end

  def slices_without_repeats(a, max_slice_size)
    slices = []
    bins = a.group_by { |e| e }.values
    until bins.empty?
      bins = bins.sort_by(&:size)
      slice_size = [max_slice_size, bins.size].min
      slice = slice_size.times.map do |i|
        bins[i].pop
      end
      slices << slice
      bins.reject!(&:empty?)
      if slice.size < max_slice_size && !bins.empty?
        raise ArgumentError, "An element repeats too much"
      end
    end
    slices
  end

end