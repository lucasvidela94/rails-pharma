# 🔍 Análisis de Entornos - Pharma Rails API

## 📊 Comparación Detallada

### 🟢 DESARROLLO (RAILS_ENV=development)

#### Configuración Actual
```bash
RAILS_ENV=development
SECRET_KEY_BASE=560e1b91e6115e5752cc2dc00570bdc41ace1f5b3f11cb9ea1c32ce9ac959e1f177730f6de4eab6d6a328881f8109d3acd05c122f79157399c47f4b5210b7a3b
```

#### Características
- ✅ **Base de datos**: SQLite local (`storage/development.sqlite3`)
- ✅ **Credenciales**: SECRET_KEY_BASE directo (sin encriptación)
- ✅ **Logs**: Detallados con información de debug
- ✅ **Recarga**: Código se recarga automáticamente
- ✅ **SSL**: Deshabilitado
- ✅ **Puerto**: 3000 (interno), 80 (externo)
- ✅ **Performance**: Optimizado para desarrollo
- ✅ **Errores**: Páginas de error detalladas

#### Ventajas
- Fácil de configurar
- No requiere credenciales complejas
- Logs detallados para debugging
- Recarga automática de código

#### Desventajas
- No es seguro para producción
- Base de datos local (no escalable)
- No usa las mejores prácticas de Rails

---

### 🔴 PRODUCCIÓN (RAILS_ENV=production)

#### Configuración Requerida
```bash
RAILS_ENV=production
RAILS_MASTER_KEY=tu_master_key_aqui
DATABASE_URL=postgresql://user:pass@host:port/db
```

#### Características
- 🔴 **Base de datos**: PostgreSQL (recomendado)
- 🔴 **Credenciales**: RAILS_MASTER_KEY + credentials.yml.enc
- 🔴 **Logs**: Solo errores importantes
- 🔴 **Recarga**: Código precompilado
- 🔴 **SSL**: Habilitado por defecto
- 🔴 **Puerto**: 80 (interno y externo)
- 🔴 **Performance**: Optimizado para producción
- 🔴 **Errores**: Páginas de error genéricas

#### Ventajas
- Seguro y escalable
- Optimizado para performance
- Usa mejores prácticas de Rails
- Base de datos externa

#### Desventajas
- Configuración más compleja
- Requiere credenciales correctas
- Logs menos detallados

---

## ⚠️ Problema Actual

### El Issue
```bash
ActiveSupport::MessageEncryptor::InvalidMessage
```

### Causa
Las credenciales encriptadas (`credentials.yml.enc`) no coinciden con la clave maestra (`master.key`).

### Solución Temporal (Desarrollo)
```bash
-e SECRET_KEY_BASE=tu_secret_key_aqui
```

### Solución Definitiva (Producción)
1. Regenerar credenciales correctamente
2. Usar `RAILS_MASTER_KEY` en producción
3. Configurar base de datos externa

---

## 🚀 Configuración para Railway

### Variables de Entorno Requeridas
```bash
# Obligatorias
RAILS_ENV=production
RAILS_MASTER_KEY=tu_master_key_aqui
DATABASE_URL=postgresql://user:pass@host:port/db

# Opcionales
RAILS_LOG_LEVEL=info
WEB_CONCURRENCY=2
JOB_CONCURRENCY=1
```

### Base de Datos
Railway proporciona PostgreSQL automáticamente:
- **Host**: Variable `DATABASE_URL` automática
- **SSL**: Habilitado por defecto
- **Backup**: Automático

### SSL y Dominio
- **SSL**: Automático con Railway
- **Dominio**: `tu-app.railway.app`
- **Custom domain**: Configurable

---

## 🔧 Configuración de Base de Datos

### Desarrollo (SQLite)
```yaml
development:
  adapter: sqlite3
  database: storage/development.sqlite3
```

### Producción (PostgreSQL)
```yaml
production:
  adapter: postgresql
  url: <%= ENV['DATABASE_URL'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000
```

---

## 📋 Checklist para Producción

### ✅ Configuración Básica
- [ ] `RAILS_ENV=production`
- [ ] `RAILS_MASTER_KEY` configurado
- [ ] `DATABASE_URL` configurado
- [ ] SSL habilitado

### ✅ Base de Datos
- [ ] PostgreSQL configurado
- [ ] Migraciones ejecutadas
- [ ] Seeds ejecutados (si es necesario)

### ✅ Seguridad
- [ ] Credenciales encriptadas
- [ ] Variables de entorno seguras
- [ ] SSL/TLS configurado

### ✅ Performance
- [ ] Assets precompilados
- [ ] Logs optimizados
- [ ] Caching configurado

---

## 🐳 Docker Compose para Desarrollo

### Archivo: `docker-compose.yml`
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:80"
    environment:
      - RAILS_ENV=development
      - SECRET_KEY_BASE=tu_secret_key_aqui
    volumes:
      - ./storage:/rails/storage
      - ./log:/rails/log
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=pharma_rails_development
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
```

### Comandos
```bash
# Levantar todo
docker-compose up -d

# Ver logs
docker-compose logs -f app

# Ejecutar migraciones
docker-compose exec app bin/rails db:migrate

# Parar todo
docker-compose down
```

---

## 🎯 Recomendaciones

### Para Desarrollo Local
1. **Usar docker-compose.yml** para desarrollo
2. **SQLite** está bien para desarrollo
3. **SECRET_KEY_BASE** directo es aceptable

### Para Producción (Railway)
1. **PostgreSQL** obligatorio
2. **RAILS_MASTER_KEY** con credenciales encriptadas
3. **Variables de entorno** seguras
4. **SSL** automático con Railway

### Para Testing
1. **Entorno separado** con SQLite
2. **Datos de prueba** automáticos
3. **CI/CD** configurado

---

*Análisis generado el 2025-09-13*
