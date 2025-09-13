# 🏥 Pharma Rails API - Documentación

API Rails para sincronización de órdenes entre Tienda Nube y sistema de facturación farmacéutico.

## 🚀 Endpoints Disponibles

### **Sincronización**

#### `POST /api/sync`
Sincronización completa de todas las órdenes (últimos 30 días por defecto).

```bash
curl -X POST -H "Content-Type: application/json" http://localhost:3000/api/sync
```

**Respuesta:**
```json
{
  "success": true,
  "sync_id": 1,
  "status": "completed",
  "message": "Sync process completed",
  "orders_processed": 15,
  "orders_synced": 15,
  "errors_count": 0,
  "duration": 633
}
```

#### `POST /api/sync/incremental`
Sincronización incremental (solo órdenes nuevas/modificadas desde la última sync).

```bash
curl -X POST -H "Content-Type: application/json" http://localhost:3000/api/sync/incremental
```

#### `GET /api/sync/status`
Estado de la última sincronización.

```bash
curl -H "Content-Type: application/json" http://localhost:3000/api/sync/status
```

**Respuesta:**
```json
{
  "sync_id": 1,
  "status": "completed",
  "sync_type": "full",
  "started_at": "2025-09-13T00:26:56.677Z",
  "completed_at": "2025-09-13T00:26:57.310Z",
  "orders_processed": 15,
  "orders_synced": 15,
  "duration": 633,
  "error_details": null
}
```

### **Órdenes**

#### `GET /api/orders`
Lista todas las órdenes sincronizadas.

```bash
curl -H "Content-Type: application/json" http://localhost:3000/api/orders
```

#### `GET /api/orders/:id`
Ver una orden específica.

```bash
curl -H "Content-Type: application/json" http://localhost:3000/api/orders/1
```

#### `POST /api/orders/:id/resync`
Re-sincronizar una orden específica.

```bash
curl -X POST -H "Content-Type: application/json" http://localhost:3000/api/orders/1/resync
```

## 🔧 Configuración

### **Credenciales de Tienda Nube**

1. Copiar archivo de configuración:
```bash
cp config/tienda_nube.example.yml config/tienda_nube.yml
```

2. Configurar credenciales en `config/tienda_nube.yml`:
```yaml
development:
  store_id: "TU_STORE_ID"
  access_token: "TU_ACCESS_TOKEN"
```

### **Obtener Credenciales**

1. **Ir a Partners Portal**: https://partners.tiendanube.com
2. **Crear aplicación**: "Aplicaciones > Crear Aplicación"
3. **Instalar en tienda demo**: `https://www.tiendanube.com/apps/{app_id}/authorize`
4. **Obtener token OAuth 2**:
```bash
curl -X POST "https://www.tiendanube.com/apps/authorize/token" \
-d "client_id=client_id" \
-d "client_secret=client_secret" \
-d "code=authorization_code"
```

## 📊 Estructura de Datos

### **Order**
```json
{
  "id": 1,
  "external_id": "123",
  "status": "paid",
  "total": "2500.0",
  "synced": true,
  "data": {
    "id": 123,
    "status": "paid",
    "customer": {
      "name": "Juan Pérez",
      "email": "juan@example.com",
      "phone": "+5491123456789"
    },
    "products": [...],
    "billing_address": {...},
    "shipping_address": {...},
    "success": true,
    "billing_id": "BILL_123_1757723216",
    "message": "Order sent to billing system successfully"
  }
}
```

### **SyncLog**
```json
{
  "id": 1,
  "sync_type": "full",
  "status": "completed",
  "orders_processed": 15,
  "orders_synced": 15,
  "started_at": "2025-09-13T00:26:56.677Z",
  "completed_at": "2025-09-13T00:26:57.310Z",
  "duration": 633,
  "error_details": null
}
```

## 🏗️ Arquitectura

### **Servicios**

- **`TiendaNubeService`**: Integración con API de Tienda Nube
  - `fetch_orders()`: Obtener órdenes con paginación
  - `fetch_orders_since(date)`: Sincronización incremental
  - `fetch_order(id)`: Obtener orden específica
  - `send_to_billing_system()`: Envío a sistema de facturación

- **`SyncService`**: Lógica de sincronización
  - `sync_all_orders()`: Sincronización completa
  - `sync_incremental()`: Sincronización incremental
  - `sync_single_order_by_id()`: Sync de orden específica

### **Modelos**

- **`Order`**: Órdenes sincronizadas
- **`SyncLog`**: Logs de sincronización

## 🚦 Estados de Sincronización

- **`pending`**: Sincronización iniciada
- **`running`**: En proceso
- **`completed`**: Completada exitosamente
- **`failed`**: Falló con errores

## 🔄 Tipos de Sincronización

- **`full`**: Sincronización completa (todas las órdenes)
- **`single`**: Sincronización de orden específica
- **`incremental`**: Solo órdenes nuevas/modificadas

## ⚠️ Manejo de Errores

La API maneja automáticamente:
- **401**: Credenciales inválidas
- **429**: Rate limit excedido
- **502**: Error de API externa
- **500**: Error interno del servidor

## 🧪 Desarrollo

Para desarrollo, el sistema usa datos simulados de Tienda Nube cuando las credenciales son de prueba.

```yaml
# config/tienda_nube.yml
development:
  store_id: "123456"
  access_token: "fake_access_token_for_development"
```

## 🚀 Producción

Para producción, configurar credenciales reales y considerar:
- Implementar jobs en background para sincronización
- Configurar webhooks de Tienda Nube
- Agregar autenticación API
- Monitoreo y alertas
