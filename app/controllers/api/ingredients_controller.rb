require 'unitwise'
class Api::IngredientsController < Api::BaseController
  # jitera-anchor-dont-touch: before_action_filter

  # jitera-anchor-dont-touch: actions
  def destroy
    @ingredient = Ingredient.find_by(id: params[:id])

    @error_message = true unless @ingredient&.destroy
  end

  def update
    @ingredient = Ingredient.find_by(id: params[:id])

    request = {}
    request.merge!('unit' => params.dig(:ingredients, :unit))
    request.merge!('amount' => params.dig(:ingredients, :amount))
    request.merge!('recipe_id' => params.dig(:ingredients, :recipe_id))

    @error_object = @ingredient.errors.messages unless @ingredient.update(request)
  end

  def show
    @ingredient = Ingredient.find_by(id: params[:id])
    @error_message = true if @ingredient.blank?
  end

  def create
    @ingredient = Ingredient.new

    request = {}
    request.merge!('unit' => params.dig(:ingredients, :unit))
    request.merge!('amount' => params.dig(:ingredients, :amount))
    request.merge!('recipe_id' => params.dig(:ingredients, :recipe_id))

    @ingredient.assign_attributes(request)
    @error_object = @ingredient.errors.messages unless @ingredient.save
  end

  def index
    request = {}

    request.merge!('unit' => params.dig(:ingredients, :unit))
    request.merge!('amount' => params.dig(:ingredients, :amount))
    request.merge!('recipe_id' => params.dig(:ingredients, :recipe_id))

    @ingredients = Ingredient.all
  end

  # Desc                  Create weight converter API
  # Route                 POST  /api/convert_weight
  # Access                Public
  # Body                  { "recipe_id": "1", "convert_to_unit": "teaspoons" }

  def weight_converter
    original_unit = params[:original_unit]
    convert_to_unit = params[:convert_to_unit]
    recipe_id = params[:recipe_id]
    amount = params[:amount]

    @ingredient =  Ingredient.find_by_recipe_id recipe_id
    original_unit = @ingredient.unit
    amount = @ingredient.amount
    old_ingredient = do_convert(amount, original_unit)
    old_ingredient.convert_to(convert_to_unit)
    
    if @ingredient.save
      render json: {success: false, message: "Converted successfully", data: old_ingredient }
    else
      render json: {success: false, message: old_ingredient.errors.message, data: {} }
    end
    
  end

  def do_convert(amount, original_unit)
    Unitwise(amount, original_unit)
  end

end
