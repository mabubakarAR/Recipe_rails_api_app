if @categories.present?
  json.categories @categories do |category|
    json.id category.id
    json.created_at category.created_at
    json.updated_at category.updated_at

    json.recipes category.recipes do |recipe|
      json.id recipe.id
      json.created_at recipe.created_at
      json.updated_at recipe.updated_at
      json.title recipe.title
      json.descriptions recipe.descriptions
      json.time recipe.time
      json.difficulty recipe.difficulty
      json.category_id recipe.category_id
      json.user_id recipe.user_id

      json.ingredients recipe.ingredients do |ingredient|
        json.id ingredient.id
        json.created_at ingredient.created_at
        json.updated_at ingredient.updated_at
        json.unit ingredient.unit
        json.amount ingredient.amount
        json.recipe_id ingredient.recipe_id
      end
    end

    json.description category.description
    json.category_id category.id
  end
else
  json.error_message @error_message
end
