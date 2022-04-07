class ItemsController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
  def index
    if params[:user_id]
      user = find_user
      items = user.items
    else
      items = Item.all
    end
    render json: items, include: :user
  end

  def show
    item = find_item
    render json: item, include: [:user]
  end

  def create
    if params[:user_id]
      user = find_user
      item = user.items.create!(item_params)
    else
      item = Item.create!(item_params)
    end
    render json: item, status: :created
  rescue ActiveRecord::RecordInvalid => invalid
    render json: {errors: invalid.record.errors.full_messages}, status: :unprocessable_entity
  end

  private
  def find_user
    User.find(params[:user_id])
  end

  def find_item
    Item.find(params[:id])
  end

  def render_not_found_response
    render json: {error: "User not found"}, status: :not_found
  end

  def item_params
    params.permit(:name, :description, :price, :user_id)
  end
end
