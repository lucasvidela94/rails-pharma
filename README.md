# 🏥 Pharma Rails API

API Rails para sincronización de órdenes farmacéuticas con Tienda Nube.

## 🚀 Quick Start

### Docker (Recomendado)
```bash
# Construir imagen
docker build -t pharma_rails .

# Ejecutar en desarrollo
docker run -d -p 3000:80 \
  -e RAILS_ENV=development \
  -e SECRET_KEY_BASE=560e1b91e6115e5752cc2dc00570bdc41ace1f5b3f11cb9ea1c32ce9ac959e1f177730f6de4eab6d6a328881f8109d3acd05c122f79157399c47f4b5210b7a3b \
  --name pharma_rails pharma_rails

# Probar API
curl http://localhost:3000/api/orders
```

### Docker Compose (Desarrollo Local)
```bash
# Levantar todo
docker-compose up -d

# Ver logs
docker-compose logs -f app

# Parar
docker-compose down
```

## 📋 Características

- ✅ **API REST** para gestión de órdenes
- ✅ **Sincronización** con Tienda Nube
- ✅ **Dockerizado** para fácil deployment
- ✅ **Base de datos** SQLite (desarrollo) / PostgreSQL (producción)
- ✅ **Health checks** integrados
- ✅ **Logs** estructurados

## 🔗 Endpoints

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/up` | Health check |
| `GET` | `/api/orders` | Lista de órdenes |
| `GET` | `/api/orders/:id` | Detalle de orden |
| `POST` | `/api/orders/:id/resync` | Re-sincronizar orden |
| `GET` | `/api/sync/status` | Estado de sincronización |
| `POST` | `/api/sync` | Ejecutar sincronización completa |
| `POST` | `/api/sync/incremental` | Sincronización incremental |

## 🐳 Docker

### Desarrollo
```bash
# Con SQLite (actual)
docker run -d -p 3000:80 \
  -e RAILS_ENV=development \
  -e SECRET_KEY_BASE=tu_secret_key \
  --name pharma_rails pharma_rails
```

### Producción
```bash
# Con PostgreSQL
docker run -d -p 80:80 \
  -e RAILS_ENV=production \
  -e RAILS_MASTER_KEY=tu_master_key \
  -e DATABASE_URL=postgresql://user:pass@host:port/db \
  --name pharma_rails_prod pharma_rails
```

## 🚂 Railway Deployment

### Configuración Automática
1. Conectar repositorio a Railway
2. Agregar servicio PostgreSQL
3. Configurar variables de entorno:
   ```bash
   RAILS_ENV=production
   RAILS_MASTER_KEY=tu_master_key
   # DATABASE_URL se genera automáticamente
   ```
4. Deploy automático en cada push

### Ver [RAILWAY_DEPLOYMENT.md](./RAILWAY_DEPLOYMENT.md) para detalles completos

## 🔧 Configuración

### Variables de Entorno

#### Desarrollo
```bash
RAILS_ENV=development
SECRET_KEY_BASE=tu_secret_key_aqui
```

#### Producción
```bash
RAILS_ENV=production
RAILS_MASTER_KEY=tu_master_key_aqui
DATABASE_URL=postgresql://user:pass@host:port/db
```

### Base de Datos

#### Desarrollo (SQLite)
- Archivo: `storage/development.sqlite3`
- Migraciones automáticas
- Datos de prueba incluidos

#### Producción (PostgreSQL)
- URL: Variable `DATABASE_URL`
- SSL habilitado
- Backup automático

## 📊 Estado Actual

### ✅ Funcionando
- API endpoints
- Sincronización con Tienda Nube
- Base de datos SQLite
- Docker containerizado
- Health checks

### 🔄 En Progreso
- Configuración de credenciales para producción
- Migración a PostgreSQL
- Deployment en Railway

## 📚 Documentación

- [🐳 Docker Deployment Guide](./DOCKER_DEPLOYMENT.md)
- [🔍 Análisis de Entornos](./ENVIRONMENT_ANALYSIS.md)
- [🚂 Railway Deployment](./RAILWAY_DEPLOYMENT.md)
- [📖 API Documentation](./API_DOCUMENTATION.md)

## 🛠️ Desarrollo

### Requisitos
- Ruby 3.4.5
- Docker (recomendado)
- SQLite3 (desarrollo local)

### Comandos Útiles
```bash
# Desarrollo local
bin/rails server

# Tests
bin/rails test

# Console
bin/rails console

# Migraciones
bin/rails db:migrate

# Seeds
bin/rails db:seed
```

### Estructura del Proyecto
```
app/
├── controllers/api/     # API controllers
├── models/             # Models (Order, SyncLog)
├── services/           # Business logic
└── jobs/              # Background jobs

config/
├── routes.rb          # API routes
├── database.yml       # DB configuration
└── deploy.yml         # Kamal deployment

db/
├── migrate/           # Database migrations
└── seeds.rb          # Sample data
```

## 🔒 Seguridad

- ✅ Credenciales encriptadas
- ✅ Variables de entorno seguras
- ✅ SSL/TLS en producción
- ✅ Usuario no-root en Docker

## 📈 Monitoreo

- ✅ Health check en `/up`
- ✅ Logs estructurados
- ✅ Métricas de sincronización
- ✅ Error tracking

## 🤝 Contribución

1. Fork el proyecto
2. Crear feature branch
3. Commit cambios
4. Push al branch
5. Crear Pull Request

## 📄 Licencia

Este proyecto es privado y confidencial.

---

*Última actualización: 2025-09-13*
