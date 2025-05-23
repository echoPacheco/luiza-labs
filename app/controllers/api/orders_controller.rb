module Api
  class OrdersController < ApplicationController
    def upload
      file = params[:file]
      return render json: { error: 'No file' }, status: :bad_request unless file

      OrderFileProcessorService.new(file).call
      render json: { message: 'Arquivo processado com sucesso' }
    end

    def index
      orders = Order.includes(:products, :user)
      orders = orders.where(order_id: params[:order_id]) if params[:order_id]
      if params[:start_date] && params[:end_date]
        orders = orders.where(date: params[:start_date]..params[:end_date])
      end

      result = orders.group_by(&:user).map do |user, user_orders|
        {
          user_id: user.user_id,
          name: user.name,
          orders: user_orders.map do |order|
            {
              order_id: order.order_id,
              total: format('%.2f', order.total),
              date: order.date.to_s,
              products: order.products.map do |p|
                {
                  product_id: p.product_id,
                  value: format('%.2f', p.value)
                }
              end
            }
          end
        }
      end

      render json: result
    end
  end
end
