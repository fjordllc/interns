# frozen_string_literal: true

class API::Products::NotRespondedController < API::BaseController
  before_action :require_staff_login
  def index
    @products = Product.not_responded_products.list.page(params[:page])
    @latest_product_submitted_just_5days = @products.order(published_at: :desc).find { |product| product.submitted_just_specific_days(5) }
    @latest_product_submitted_just_6days = @products.order(published_at: :desc).find { |product| product.submitted_just_specific_days(6) }
    @latest_product_submitted_over_7days = @products.order(published_at: :desc).find { |product| product.submitted_over_specific_days(7) }
  end
end