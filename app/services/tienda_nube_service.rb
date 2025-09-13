require 'net/http'
require 'timeout'

class TiendaNubeService
  BASE_URL = 'https://api.tiendanube.com/v1'
  
  def initialize(store_id, access_token)
    @store_id = store_id
    @access_token = access_token
    @headers = {
      'Authorization' => "Bearer #{access_token}",
      'Content-Type' => 'application/json',
      'User-Agent' => 'PharmaRails/1.0 (pharma@freelo.com)'
    }
  end

  # Obtener todas las órdenes de Tienda Nube
  def fetch_orders(page: 1, per_page: 50, created_at_min: nil)
    params = { page: page, per_page: per_page }
    params[:created_at_min] = created_at_min if created_at_min
    
    response = make_request(
      :get,
      "#{BASE_URL}/#{@store_id}/orders",
      params: params
    )
    
    return [] unless response&.dig('data')
    
    response['data'].map do |order_data|
      transform_order(order_data)
    end
  end

  # Obtener una orden específica por ID
  def fetch_order(order_id)
    response = make_request(
      :get,
      "#{BASE_URL}/#{@store_id}/orders/#{order_id}"
    )
    
    return nil unless response
    
    transform_order(response)
  end

  # Obtener órdenes desde una fecha específica (útil para sincronización incremental)
  def fetch_orders_since(date)
    fetch_orders(created_at_min: date.iso8601)
  end

  # Enviar orden al sistema de facturación (placeholder)
  def send_to_billing_system(order_data)
    # TODO: Implementar integración con sistema de facturación
    # Por ahora simulamos envío exitoso
    {
      success: true,
      billing_id: "BILL_#{order_data[:external_id]}_#{Time.current.to_i}",
      message: "Order sent to billing system successfully"
    }
  end

  private

  def make_request(method, url, params: {})
    # Para desarrollo, simular respuestas si las credenciales son de prueba
    if Rails.env.development? && @access_token == 'fake_access_token_for_development'
      return simulate_api_response(method, url, params)
    end

    uri = URI(url)
    uri.query = URI.encode_www_form(params) if params.any?
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30
    http.open_timeout = 10
    
    request = case method
    when :get
      Net::HTTP::Get.new(uri)
    when :post
      Net::HTTP::Post.new(uri)
    end
    
    @headers.each { |key, value| request[key] = value }
    
    response = http.request(request)
    
    case response.code.to_i
    when 200..299
      JSON.parse(response.body)
    when 401
      raise AuthenticationError, "Invalid credentials for Tienda Nube API"
    when 429
      raise RateLimitError, "Rate limit exceeded for Tienda Nube API"
    when 500..599
      raise ServerError, "Tienda Nube API server error: #{response.code}"
    else
      raise APIError, "Tienda Nube API error: #{response.code} - #{response.body}"
    end
  rescue JSON::ParserError => e
    raise APIError, "Invalid JSON response from Tienda Nube API: #{e.message}"
  rescue Timeout::Error => e
    raise TimeoutError, "Timeout connecting to Tienda Nube API: #{e.message}"
  rescue => e
    raise APIError, "Unexpected error calling Tienda Nube API: #{e.message}"
  end

  def simulate_api_response(method, url, params)
    case url
    when /\/orders$/
      simulate_orders_list(params[:page] || 1)
    when /\/orders\/\d+$/
      simulate_single_order
    else
      raise APIError, "Simulated API error for development"
    end
  end

  def simulate_orders_list(page)
    # Limitar a máximo 3 páginas (15 órdenes en total)
    return { 'data' => [], 'pagination' => { 'page' => page, 'per_page' => 5, 'total' => 0 } } if page > 3
    
    {
      'data' => (1..5).map do |i|
        order_id = (page - 1) * 5 + i
        {
          'id' => order_id,
          'status' => %w[pending paid cancelled fulfilled].sample,
          'total' => rand(100..5000),
          'customer' => {
            'name' => "Customer #{order_id}",
            'email' => "customer#{order_id}@example.com",
            'phone' => "+54911#{rand(10000000..99999999)}"
          },
          'billing_address' => {
            'address' => "Street #{order_id}",
            'city' => 'Buenos Aires',
            'zipcode' => '1234'
          },
          'shipping_address' => {
            'address' => "Street #{order_id}",
            'city' => 'Buenos Aires',
            'zipcode' => '1234'
          },
          'products' => [
            {
              'id' => order_id * 100,
              'name' => "Product #{order_id}",
              'quantity' => rand(1..5),
              'price' => rand(50..1000)
            }
          ],
          'payment_details' => {
            'method' => 'credit_card',
            'status' => 'paid'
          },
          'created_at' => (Time.current - rand(1..30).days).iso8601
        }
      end,
      'pagination' => {
        'page' => page,
        'per_page' => 5,
        'total' => 15  # Solo 15 órdenes en total
      }
    }
  end

  def simulate_single_order
    {
      'id' => 123,
      'status' => 'paid',
      'total' => 2500,
      'customer' => {
        'name' => 'John Doe',
        'email' => 'john@example.com',
        'phone' => '+5491123456789'
      },
      'billing_address' => {
        'address' => 'Main St 123',
        'city' => 'Buenos Aires',
        'zipcode' => '1234'
      },
      'shipping_address' => {
        'address' => 'Main St 123',
        'city' => 'Buenos Aires',
        'zipcode' => '1234'
      },
      'products' => [
        {
          'id' => 100,
          'name' => 'Test Product',
          'quantity' => 2,
          'price' => 1250
        }
      ],
      'payment_details' => {
        'method' => 'credit_card',
        'status' => 'paid'
      },
      'created_at' => Time.current.iso8601
    }
  end

  def transform_order(order_data)
    {
      external_id: order_data['id'].to_s,
      status: map_order_status(order_data['status']),
      total: BigDecimal(order_data['total'].to_s),
      data: order_data.to_json,
      synced: false,
      billing_data: extract_billing_data(order_data)
    }
  end

  def map_order_status(tienda_nube_status)
    case tienda_nube_status
    when 'pending', 'open'
      'pending'
    when 'paid'
      'paid'
    when 'cancelled'
      'cancelled'
    when 'fulfilled'
      'completed'
    else
      'unknown'
    end
  end

  def extract_billing_data(order_data)
    {
      customer: {
        id: order_data.dig('customer', 'id'),
        name: order_data.dig('customer', 'name'),
        email: order_data.dig('customer', 'email'),
        phone: order_data.dig('customer', 'phone')
      },
      billing_address: order_data['billing_address'],
      shipping_address: order_data['shipping_address'],
      items: order_data['products']&.map do |product|
        {
          id: product['id'],
          name: product['name'],
          quantity: product['quantity'],
          price: product['price'],
          variant_id: product['variant_id']
        }
      end,
      payment_method: order_data['payment_details'],
      shipping_method: order_data['shipping_method'],
      created_at: order_data['created_at'],
      updated_at: order_data['updated_at'],
      currency: order_data['currency'] || 'ARS'
    }
  end

  # Excepciones personalizadas
  class APIError < StandardError; end
  class AuthenticationError < APIError; end
  class RateLimitError < APIError; end
  class ServerError < APIError; end
  class TimeoutError < APIError; end
end
