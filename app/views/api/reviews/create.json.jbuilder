if @error_object.blank?
  json.review do
    json.id @review.id
    json.rating @review.rating
    json.comment @review.comment
    json.created_at @review.created_at
    json.updated_at @review.updated_at

    json.user do
      json.id @review.user.id
      json.email @review.user.email
    end
  end
else
  json.error_object @error_object
end
  