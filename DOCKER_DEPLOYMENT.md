# 🐳 Docker Deployment Guide - Pharma Rails API

## 📋 Resumen

Esta API Rails está completamente dockerizada y lista para deployment en diferentes entornos. Este documento explica cómo funciona, las diferencias entre entornos y cómo deployar.

## 🏗️ Arquitectura Docker

### Dockerfile
- **Base**: Ruby 3.4.5-slim
- **Multi-stage build**: Optimizado para producción
- **Seguridad**: Usuario no-root (rails:1000)
- **Puerto**: 80 (configurable)
- **Entrypoint**: Automático con migraciones

### Configuración Actual
```dockerfile
# Producción por defecto
ENV RAILS_ENV="production"
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
```

## 🔧 Comandos de Docker

### Construcción
```bash
docker build -t pharma_rails .
```

### Ejecución Local (Desarrollo)
```bash
docker run -d -p 3000:80 \
  -e RAILS_ENV=development \
  -e SECRET_KEY_BASE=560e1b91e6115e5752cc2dc00570bdc41ace1f5b3f11cb9ea1c32ce9ac959e1f177730f6de4eab6d6a328881f8109d3acd05c122f79157399c47f4b5210b7a3b \
  --name pharma_rails_test pharma_rails
```

### Ejecución Producción
```bash
docker run -d -p 80:80 \
  -e RAILS_MASTER_KEY=tu_master_key_aqui \
  --name pharma_rails_prod pharma_rails
```

## 🔄 Diferencias Entre Entornos

### 🟢 Desarrollo (RAILS_ENV=development)
- **Base de datos**: SQLite local
- **Credenciales**: SECRET_KEY_BASE directo
- **Logs**: Detallados con debug
- **Recarga**: Código se recarga automáticamente
- **SSL**: Deshabilitado
- **Puerto**: 3000 (interno), 80 (externo)

### 🔴 Producción (RAILS_ENV=production)
- **Base de datos**: Configurable (PostgreSQL recomendado)
- **Credenciales**: RAILS_MASTER_KEY + credentials.yml.enc
- **Logs**: Solo errores importantes
- **Recarga**: Código precompilado
- **SSL**: Habilitado por defecto
- **Puerto**: 80 (interno y externo)

## ⚠️ Problema Actual con Credenciales

### El Problema
Las credenciales encriptadas (`credentials.yml.enc`) no funcionan correctamente con la clave maestra generada. Esto causa:
```
ActiveSupport::MessageEncryptor::InvalidMessage
```

### Solución Temporal
Usar `SECRET_KEY_BASE` directamente en desarrollo:
```bash
-e SECRET_KEY_BASE=tu_secret_key_aqui
```

### Solución Definitiva para Producción
1. Regenerar credenciales correctamente
2. Usar `RAILS_MASTER_KEY` en producción
3. Configurar base de datos externa

## 🚀 Deployment en Railway

### Configuración Necesaria

#### 1. Variables de Entorno
```bash
RAILS_ENV=production
RAILS_MASTER_KEY=tu_master_key_aqui
DATABASE_URL=postgresql://user:pass@host:port/db
```

#### 2. Railway Configuration
```yaml
# railway.toml (opcional)
[build]
builder = "dockerfile"

[deploy]
startCommand = "./bin/thrust ./bin/rails server"
healthcheckPath = "/up"
healthcheckTimeout = 300
restartPolicyType = "on_failure"
```

#### 3. Dockerfile para Railway
El Dockerfile actual es compatible, pero necesitamos:
- Configurar PostgreSQL
- Usar credenciales correctas
- Configurar variables de entorno

### Pasos para Railway

1. **Conectar repositorio** a Railway
2. **Configurar variables de entorno**:
   - `RAILS_ENV=production`
   - `RAILS_MASTER_KEY=...`
   - `DATABASE_URL=...` (Railway PostgreSQL)
3. **Deploy automático** desde main branch

## 📊 Estado Actual de la API

### Endpoints Funcionando
- ✅ `GET /up` - Health check
- ✅ `GET /api/orders` - Lista órdenes
- ✅ `GET /api/sync/status` - Estado sync
- ✅ `POST /api/sync` - Ejecutar sync
- ✅ `POST /api/sync/incremental` - Sync incremental

### Base de Datos
- **Desarrollo**: SQLite con 5 órdenes de prueba
- **Producción**: Necesita PostgreSQL

## 🔧 Próximos Pasos

### Para Producción
1. **Configurar PostgreSQL** en Railway
2. **Regenerar credenciales** correctamente
3. **Configurar SSL** y dominios
4. **Configurar monitoreo** y logs

### Para Desarrollo
1. **Crear docker-compose.yml** para desarrollo local
2. **Configurar hot-reload** para desarrollo
3. **Agregar tests** automatizados

## 🐛 Troubleshooting

### Error de Credenciales
```bash
# Solución temporal
-e SECRET_KEY_BASE=tu_secret_key_aqui
```

### Puerto no disponible
```bash
# Cambiar puerto
docker run -p 8080:80 ...
```

### Base de datos no conecta
```bash
# Verificar variables de entorno
docker exec -it container_name env | grep DATABASE
```

## 📝 Notas Importantes

1. **El Dockerfile está optimizado para producción**
2. **Las credenciales necesitan ser regeneradas correctamente**
3. **Railway requiere configuración de base de datos externa**
4. **El modo desarrollo funciona pero no es ideal para producción**

---

*Documentación generada el 2025-09-13*
