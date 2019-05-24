class Forest::CustomerStatsController < ForestLiana::ApplicationController
  require 'jsonapi-serializers'

  before_action :set_params, only: [:index]

  class CustomerStatSerializer
    include JSONAPI::Serializer

    attribute :email
    attribute :amount
    attribute :orders

  end

  def index
    customers_count = Customer.where('email LIKE ?', "%#{@search}%").joins(:orders).group(:id).length
    customers = Customer.where('email LIKE ?', "%#{@search}%").joins(:orders).group(:id).order('id ASC').limit(@limit).offset(@offset - 1)
    # binding.pry
    customer_stats = customers.map { |customer| build_customer_stats(customer) }
    customer_stats_json = JSONAPI::Serializer.serialize(customer_stats, is_collection: true, meta: {count: customers_count})
    render json: customer_stats_json
  end

  private

  def set_params
    @limit = params[:page][:size].to_i
    @offset = params[:page][:number].to_i
    @search = sanitize_sql_like(params[:search]? params[:search] : "")
  end

  def sanitize_sql_like(string, escape_character = "\\")
    pattern = Regexp.union(escape_character, "%", "_")
    string.gsub(pattern) { |x| [escape_character, x].join }
  end

  def build_customer_stats(customer)
    order = Order.where(customer_id: customer[:id]).joins(:product)
    total_amount = order.sum(:price)
    order_count = order.count(:ref)
    Forest::CustomerStat.new(
      id: customer[:id],
      email: customer[:email],
      amount: total_amount,
      orders: order_count,
    )
  end

end
