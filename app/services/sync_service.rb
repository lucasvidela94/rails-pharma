class SyncService
  def initialize(sync_log_id = nil)
    @sync_log_id = sync_log_id
    @tienda_nube_service = create_tienda_nube_service
  end

  # Sincronización completa de todas las órdenes
  def sync_all_orders(since_date: nil)
    sync_log = create_or_find_sync_log('full')
    
    begin
      update_sync_log(sync_log, status: 'running', started_at: Time.current)
      
      orders_processed = 0
      orders_synced = 0
      errors = []
      
      # Si no se especifica fecha, sincronizar desde hace 30 días por defecto
      since_date ||= 30.days.ago
      
      page = 1
      loop do
        # Usar sincronización incremental si hay fecha
        orders = if since_date
          @tienda_nube_service.fetch_orders_since(since_date)
        else
          @tienda_nube_service.fetch_orders(page: page, per_page: 50)
        end
        
        break if orders.empty?
        
        orders.each do |order_data|
          orders_processed += 1
          
          begin
            if sync_single_order(order_data)
              orders_synced += 1
            end
          rescue => e
            errors << "Order #{order_data[:external_id]}: #{e.message}"
            Rails.logger.error "Error syncing order #{order_data[:external_id]}: #{e.message}"
          end
        end
        
        # Si estamos usando sincronización incremental, no paginamos
        break if since_date
        
        page += 1
        
        # Actualizar progreso
        log_attributes = {
          orders_processed: orders_processed,
          orders_synced: orders_synced
        }
        log_attributes[:error_details] = errors.join('; ') if errors.any?
        
        update_sync_log(sync_log, log_attributes)
      end
      
      # Completar sincronización
      completed_at = Time.current
      duration = (completed_at - sync_log.started_at).to_i
      
      update_sync_log(sync_log,
        status: 'completed',
        completed_at: completed_at,
        duration: duration,
        error_details: errors.any? ? errors.join('; ') : nil
      )
      
      {
        success: true,
        sync_log_id: sync_log.id,
        orders_processed: orders_processed,
        orders_synced: orders_synced,
        errors_count: errors.count,
        duration: duration
      }
      
    rescue => e
      # Marcar como fallido
      update_sync_log(sync_log,
        status: 'failed',
        completed_at: Time.current,
        error_details: e.message
      )
      
      Rails.logger.error "Sync failed: #{e.message}"
      raise e
    end
  end

  # Sincronización incremental (solo órdenes nuevas/modificadas)
  def sync_incremental
    # Obtener la fecha de la última sincronización exitosa
    last_sync = SyncLog.completed.order(:completed_at).last
    since_date = last_sync&.completed_at || 1.day.ago
    
    sync_all_orders(since_date: since_date)
  end

  # Sincronizar una orden específica
  def sync_single_order_by_id(external_id)
    sync_log = create_or_find_sync_log('single')
    
    begin
      update_sync_log(sync_log, status: 'running', started_at: Time.current)
      
      order_data = @tienda_nube_service.fetch_order(external_id)
      raise "Order #{external_id} not found in Tienda Nube" unless order_data
      
      success = sync_single_order(order_data)
      
      if success
        update_sync_log(sync_log,
          status: 'completed',
          completed_at: Time.current,
          orders_processed: 1,
          orders_synced: 1
        )
        
        { success: true, message: "Order #{external_id} synced successfully" }
      else
        update_sync_log(sync_log,
          status: 'failed',
          completed_at: Time.current,
          orders_processed: 1,
          orders_synced: 0,
          error_details: "Order already synced or sync failed"
        )
        
        { success: false, message: "Order #{external_id} sync failed" }
      end
      
    rescue => e
      update_sync_log(sync_log,
        status: 'failed',
        completed_at: Time.current,
        error_details: e.message
      )
      
      raise e
    end
  end

  private

  def create_tienda_nube_service
    # Obtener credenciales de configuración
    store_id = Rails.application.config.tienda_nube['store_id']
    access_token = Rails.application.config.tienda_nube['access_token']
    
    raise "Tienda Nube credentials not configured" unless store_id && access_token
    
    TiendaNubeService.new(store_id, access_token)
  end

  def create_or_find_sync_log(sync_type)
    if @sync_log_id
      SyncLog.find(@sync_log_id)
    else
      SyncLog.create!(
        sync_type: sync_type,
        status: 'pending',
        orders_processed: 0,
        orders_synced: 0
      )
    end
  end

  def update_sync_log(sync_log, attributes)
    sync_log.update!(attributes)
  end

  def sync_single_order(order_data)
    # Buscar orden existente
    order = Order.find_by(external_id: order_data[:external_id])
    
    if order
      # Actualizar orden existente si no está sincronizada
      unless order.synced?
        update_order_with_billing(order, order_data)
        return true
      end
      return false # Ya estaba sincronizada
    else
      # Crear nueva orden
      create_order_with_billing(order_data)
      return true
    end
  end

  def create_order_with_billing(order_data)
    # Crear orden
    order = Order.create!(order_data.except(:billing_data))
    
    # Enviar a sistema de facturación
    billing_result = @tienda_nube_service.send_to_billing_system(order_data)
    
    if billing_result[:success]
      # Parsear el JSON existente y agregar el resultado de billing
      existing_data = JSON.parse(order.data)
      updated_data = existing_data.merge(billing_result)
      
      order.update!(
        synced: true,
        data: updated_data.to_json
      )
      Rails.logger.info "Order #{order.external_id} created and synced successfully"
    else
      Rails.logger.error "Failed to send order #{order.external_id} to billing system"
    end
    
    order
  end

  def update_order_with_billing(order, order_data)
    # Actualizar datos de la orden
    order.update!(
      status: order_data[:status],
      total: order_data[:total],
      data: order_data[:data]
    )
    
    # Enviar a sistema de facturación
    billing_result = @tienda_nube_service.send_to_billing_system(order_data)
    
    if billing_result[:success]
      # Parsear el JSON existente y agregar el resultado de billing
      existing_data = JSON.parse(order.data)
      updated_data = existing_data.merge(billing_result)
      
      order.update!(
        synced: true,
        data: updated_data.to_json
      )
      Rails.logger.info "Order #{order.external_id} updated and synced successfully"
    else
      Rails.logger.error "Failed to send order #{order.external_id} to billing system"
    end
    
    order
  end
end
