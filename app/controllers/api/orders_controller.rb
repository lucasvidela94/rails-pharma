class Api::OrdersController < ApplicationController
  def index
    orders = Order.all
    render json: orders
  end

  def show
    order = Order.find(params[:id])
    render json: order
  end

  def resync
    begin
      order = Order.find(params[:id])
      
      # Iniciar resync de la orden específica
      sync_service = SyncService.new
      result = sync_service.sync_single_order_by_id(order.external_id)
      
      render json: {
        success: result[:success],
        order_id: order.id,
        external_id: order.external_id,
        message: result[:message],
        status: result[:success] ? 'resynced' : 'resync_failed'
      }
      
    rescue ActiveRecord::RecordNotFound
      render json: { 
        success: false, 
        error: 'order_not_found', 
        message: 'Order not found' 
      }, status: 404
      
    rescue SyncService::TiendaNubeService::AuthenticationError => e
      render json: { 
        success: false, 
        error: 'authentication_failed', 
        message: 'Invalid Tienda Nube credentials' 
      }, status: 401
      
    rescue SyncService::TiendaNubeService::APIError => e
      render json: { 
        success: false, 
        error: 'api_error', 
        message: e.message 
      }, status: 502
      
    rescue => e
      Rails.logger.error "Unexpected resync error: #{e.message}"
      render json: { 
        success: false, 
        error: 'internal_error', 
        message: 'Internal server error during resync' 
      }, status: 500
    end
  end
end
