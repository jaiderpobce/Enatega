class GraphQLQueries {
  static const String loginMutation = '''
    mutation Login(\$facebookId: String, \$email: String, \$password: String, \$type: String!, \$appleId: String, \$name: String, \$notificationToken: String) {
      login(facebookId: \$facebookId, email: \$email, password: \$password, type: \$type, appleId: \$appleId, name: \$name, notificationToken: \$notificationToken) {
        userId
        token
        is_active
        tokenExpiration
        name
        email
        phone
      }
    }
  ''';

  static const String createUserMutation = '''
    mutation CreateUser(\$facebookId: String, \$phone: String, \$email: String, \$password: String, \$name: String, \$notificationToken: String, \$appleId: String) {
      createUser(userInput: {
        facebookId: \$facebookId,
        phone: \$phone,
        email: \$email,
        password: \$password,
        name: \$name,
        notificationToken: \$notificationToken,
        appleId: \$appleId
      }) {
        userId
        token
        tokenExpiration
        name
        email
        phone
        notificationToken
      }
    }
  ''';

  static const String profileQuery = '''
    query GetProfile {
      profile {
        _id
        name
        phone
        email
        is_active
        notificationToken
        is_order_notification
        is_offer_notification
        addresses {
          _id
          label
          delivery_address
          details
          longitude
          latitude
          selected
        }
      }
    }
  ''';

  static const String categoriesQuery = '''
    query GetCategories {
      categories {
        _id
        title
        description
        img_menu
      }
    }
  ''';

  static const String foodsByCategoryQuery = '''
    query FoodByCategory(\$category: String!, \$onSale: Boolean, \$inStock: Boolean, \$min: Float, \$max: Float, \$search: String) {
      foodByCategory(category: \$category, onSale: \$onSale, inStock: \$inStock, min: \$min, max: \$max, search: \$search) {
        _id
        title
        description
        img_url
        stock
        category {
          _id
        }
        variations {
          _id
          title
          price
          discounted
          addons {
            _id
            title
            description
            quantity_minimum
            quantity_maximum
            options {
              _id
              title
              description
              price
            }
          }
        }
      }
    }
  ''';

  static const String myOrdersQuery = '''
    query GetOrders(\$offset: Int) {
      orders(offset: \$offset) {
        _id
        order_id
        delivery_charges
        payment_status
        payment_method
        bank_name
        payment_reference
        payment_proof_url
        delivery_address_text
        latitude
        longitude
        order_amount
        paid_amount
        order_status
        createdAt
        delivery_address {
          delivery_address
          details
          label
        }
        items {
          _id
          quantity
          food {
            _id
            title
            img_url
          }
          variation {
            _id
            title
            price
          }
        }
      }
    }
  ''';

  static const String placeOrderMutation = '''
    mutation PlaceOrder(\$amount: Float!, \$paymentMethod: String, \$bankName: String, \$paymentReference: String, \$paymentProofUrl: String, \$deliveryAddress: String, \$latitude: Float, \$longitude: Float) {
      placeOrder(amount: \$amount, paymentMethod: \$paymentMethod, bankName: \$bankName, paymentReference: \$paymentReference, paymentProofUrl: \$paymentProofUrl, deliveryAddress: \$deliveryAddress, latitude: \$latitude, longitude: \$longitude) {
        _id
        order_id
        order_amount
        paid_amount
        order_status
        payment_method
        bank_name
        payment_reference
        payment_proof_url
        delivery_address_text
        latitude
        longitude
        createdAt
      }
    }
  ''';

  static const String createAddressMutation = '''
    mutation CreateAddress(\$label: String!, \$delivery_address: String!, \$details: String, \$longitude: Float, \$latitude: Float, \$selected: Boolean) {
      createAddress(addressInput: {
        label: \$label,
        delivery_address: \$delivery_address,
        details: \$details,
        longitude: \$longitude,
        latitude: \$latitude,
        selected: \$selected
      }) {
        _id
        name
        addresses {
          _id
          label
          delivery_address
          details
          selected
        }
      }
    }
  ''';

  static const String updateOrderStatusMutation = '''
    mutation UpdateOrderStatus(\$id: ID!, \$status: String!) {
      updateOrderStatus(id: \$id, status: \$status) {
        _id
        order_id
        order_status
        paid_amount
        createdAt
      }
    }
  ''';

  static const String orderByIdQuery = '''
    query GetOrderById(\$id: String!) {
      order(id: \$id) {
        _id
        order_id
        delivery_charges
        payment_status
        payment_method
        bank_name
        payment_reference
        payment_proof_url
        delivery_address_text
        latitude
        longitude
        order_amount
        paid_amount
        order_status
        createdAt
      }
    }
  ''';

  static const String createCategoryMutation = '''
    mutation CreateCategory(\$title: String!, \$description: String) {
      createCategory(title: \$title, description: \$description) {
        _id
        title
        description
      }
    }
  ''';

  static const String createFoodMutation = '''
    mutation CreateFood(\$title: String!, \$price: Float!, \$categoryId: ID!, \$description: String, \$imgUrl: String) {
      createFood(title: \$title, price: \$price, categoryId: \$categoryId, description: \$description, imgUrl: \$imgUrl) {
        _id
        title
        description
        img_url
        price
        stock
      }
    }
  ''';

  static const String updatePaymentStatusMutation = '''
    mutation UpdatePaymentStatus(\$id: ID!, \$paymentStatus: String!, \$orderStatus: String!) {
      updatePaymentStatus(id: \$id, paymentStatus: \$paymentStatus, orderStatus: \$orderStatus) {
        _id
        order_id
        payment_status
        order_status
        paid_amount
      }
    }
  ''';
}
