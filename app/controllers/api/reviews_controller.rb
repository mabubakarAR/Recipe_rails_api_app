class Api::ReviewsController < Api::BaseController
  before_action :find_recipe, only: [:create]
  
  # Desc                  Get all reviews with user
  # Route                 POST  /api/reviews
  # Access                Public
  
  def index
    @reviews = Review.all
  end

  # Desc                  Create review against given recipe
  # Route                 POST  /api/recipes/:id/reviews
  # Access                Public
  # Body                  { "reviews": { "rating": 6, "comment": "First rating", "user_id": 1}}  

  def create
    @review = @recipe.reviews.new review_params
    @error_object = @review.errors.messages unless @review.save
  end

  private

  def review_params
    params.require(:reviews).permit(:rating, :comment, :user_id)
  end

  def find_recipe
    @recipe = Recipe.find_by_id params[:id]
  rescue ActiveRecord::RecordNotFound
    render json: { is_success: false, error_code: 404, message: "Recipe not found with this ID.", data: {} }, status: :not_found
  end

end
