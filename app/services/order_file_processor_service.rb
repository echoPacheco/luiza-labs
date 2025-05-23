class OrderFileProcessorService
  def initialize(file)
    @file = file
  end

  def call
    lines = File.readlines(@file.path)

    user_ids   = []
    order_ids  = []

    parsed_data = lines.map do |line|
      user_id   = line[0..9].to_i
      order_id  = line[55..64].to_i

      user_ids << user_id
      order_ids << order_id

      {
        user_id: user_id,
        user_name: line[10..54].strip,
        order_id: order_id,
        product_id: line[65..74].to_i,
        value: line[75..86].to_f,
        date: Date.strptime(line[87..94], '%Y%m%d')
      }
    end

    existing_users  = User.where(user_id: user_ids.uniq).index_by(&:user_id)
    existing_orders = Order.where(order_id: order_ids.uniq).index_by(&:order_id)

    new_users = []
    parsed_data.each do |data|
      unless existing_users[data[:user_id]]
        new_users << {
          user_id: data[:user_id],
          name: data[:user_name],
          created_at: Time.current,
          updated_at: Time.current
        }
        existing_users[data[:user_id]] = true
      end
    end
    User.insert_all(new_users) if new_users.any?
    users_map = User.where(user_id: user_ids.uniq).index_by(&:user_id)

    orders_map = {}
    parsed_data.each do |data|
      next if existing_orders[data[:order_id]]

      orders_map[data[:order_id]] ||= {
        order_id: data[:order_id],
        user_id: users_map[data[:user_id]].id,
        total: 0,
        date: data[:date],
        created_at: Time.current,
        updated_at: Time.current
      }

      orders_map[data[:order_id]][:total] += data[:value]
    end
    Order.insert_all(orders_map.values) if orders_map.any?
    orders_final_map = Order.where(order_id: order_ids.uniq).index_by(&:order_id)

    products = parsed_data.map do |data|
      {
        order_id: orders_final_map[data[:order_id]]&.id || existing_orders[data[:order_id]]&.id,
        product_id: data[:product_id],
        value: data[:value],
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    Product.insert_all(products) if products.any?
  end
end
