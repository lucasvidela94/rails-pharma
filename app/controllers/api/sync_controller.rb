class Api::SyncController < ApplicationController
  def create
    begin
      # Iniciar sincronización completa
      sync_service = SyncService.new
      result = sync_service.sync_all_orders
      
      render json: {
        success: true,
        sync_id: result[:sync_log_id],
        status: 'completed',
        message: 'Sync process completed',
        orders_processed: result[:orders_processed],
        orders_synced: result[:orders_synced],
        errors_count: result[:errors_count],
        duration: result[:duration]
      }
      
    rescue SyncService::TiendaNubeService::AuthenticationError => e
      render json: { 
        success: false, 
        error: 'authentication_failed', 
        message: 'Invalid Tienda Nube credentials' 
      }, status: 401
      
    rescue SyncService::TiendaNubeService::RateLimitError => e
      render json: { 
        success: false, 
        error: 'rate_limit_exceeded', 
        message: 'Too many requests to Tienda Nube API' 
      }, status: 429
      
    rescue SyncService::TiendaNubeService::APIError => e
      render json: { 
        success: false, 
        error: 'api_error', 
        message: e.message 
      }, status: 502
      
    rescue => e
      Rails.logger.error "Unexpected sync error: #{e.message}"
      render json: { 
        success: false, 
        error: 'internal_error', 
        message: 'Internal server error during sync' 
      }, status: 500
    end
  end

  def incremental
    begin
      # Iniciar sincronización incremental
      sync_service = SyncService.new
      result = sync_service.sync_incremental
      
      render json: {
        success: true,
        sync_id: result[:sync_log_id],
        status: 'completed',
        message: 'Incremental sync process completed',
        orders_processed: result[:orders_processed],
        orders_synced: result[:orders_synced],
        errors_count: result[:errors_count],
        duration: result[:duration]
      }
      
    rescue SyncService::TiendaNubeService::AuthenticationError => e
      render json: { 
        success: false, 
        error: 'authentication_failed', 
        message: 'Invalid Tienda Nube credentials' 
      }, status: 401
      
    rescue SyncService::TiendaNubeService::RateLimitError => e
      render json: { 
        success: false, 
        error: 'rate_limit_exceeded', 
        message: 'Too many requests to Tienda Nube API' 
      }, status: 429
      
    rescue SyncService::TiendaNubeService::APIError => e
      render json: { 
        success: false, 
        error: 'api_error', 
        message: e.message 
      }, status: 502
      
    rescue => e
      Rails.logger.error "Unexpected incremental sync error: #{e.message}"
      render json: { 
        success: false, 
        error: 'internal_error', 
        message: 'Internal server error during incremental sync' 
      }, status: 500
    end
  end

  def status
    last_sync = SyncLog.order(:started_at).last
    if last_sync
      render json: {
        sync_id: last_sync.id,
        status: last_sync.status,
        sync_type: last_sync.sync_type,
        started_at: last_sync.started_at,
        completed_at: last_sync.completed_at,
        orders_processed: last_sync.orders_processed,
        orders_synced: last_sync.orders_synced,
        duration: last_sync.duration,
        error_details: last_sync.error_details
      }
    else
      render json: { message: 'No syncs yet' }
    end
  end
end
