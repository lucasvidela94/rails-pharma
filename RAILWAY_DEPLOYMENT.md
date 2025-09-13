# 🚂 Railway Deployment Guide

## 🎯 Configuración para Railway

### 1. Preparar el Proyecto

#### Archivos Necesarios
- ✅ `Dockerfile` (ya existe)
- ✅ `railway.toml` (creado)
- ✅ `docker-compose.yml` (para desarrollo local)

#### Variables de Entorno Requeridas
```bash
RAILS_ENV=production
RAILS_MASTER_KEY=tu_master_key_aqui
DATABASE_URL=postgresql://user:pass@host:port/db
```

### 2. Configurar Railway

#### Paso 1: Conectar Repositorio
1. Ir a [Railway.app](https://railway.app)
2. Conectar tu repositorio de GitHub
3. Seleccionar el proyecto `pharma-rails`

#### Paso 2: Configurar Base de Datos
1. Agregar servicio PostgreSQL
2. Railway generará automáticamente `DATABASE_URL`
3. La base de datos estará disponible en la red interna

#### Paso 3: Configurar Variables de Entorno
```bash
# En Railway Dashboard > Variables
RAILS_ENV=production
RAILS_MASTER_KEY=f8a673817784b4e819805e1fb8a50d78
# DATABASE_URL se genera automáticamente
```

### 3. Deploy

#### Automático
- Railway detecta el `Dockerfile`
- Deploy automático en cada push a `main`
- Health check en `/up`

#### Manual
```bash
# Si necesitas deploy manual
railway deploy
```

## 🔧 Configuración de Base de Datos

### Migraciones
Railway ejecutará automáticamente:
```bash
./bin/rails db:prepare
```

### Seeds (Opcional)
Si necesitas datos iniciales:
```bash
# En Railway Dashboard > Deployments > Run Command
./bin/rails db:seed
```

## 🌐 Dominio y SSL

### Dominio Automático
- **URL**: `https://tu-app.railway.app`
- **SSL**: Automático con Let's Encrypt

### Dominio Personalizado
1. En Railway Dashboard > Settings > Domains
2. Agregar tu dominio
3. Configurar DNS records
4. SSL automático

## 📊 Monitoreo

### Logs
```bash
# Ver logs en tiempo real
railway logs

# O en Railway Dashboard > Deployments > Logs
```

### Métricas
- CPU y memoria
- Requests por segundo
- Tiempo de respuesta
- Errores

## 🔒 Seguridad

### Variables de Entorno
- ✅ `RAILS_MASTER_KEY` (secreto)
- ✅ `DATABASE_URL` (automático)
- ✅ SSL automático

### Credenciales
- ✅ Encriptadas con `credentials.yml.enc`
- ✅ Clave maestra en variables de entorno
- ✅ No expuestas en el código

## 🚀 Comandos Útiles

### Railway CLI
```bash
# Instalar Railway CLI
npm install -g @railway/cli

# Login
railway login

# Conectar proyecto
railway link

# Ver logs
railway logs

# Ejecutar comando
railway run bin/rails console
```

### Comandos Rails
```bash
# Console
railway run bin/rails console

# Migraciones
railway run bin/rails db:migrate

# Seeds
railway run bin/rails db:seed

# Logs
railway logs
```

## 🔄 CI/CD

### GitHub Actions (Opcional)
```yaml
# .github/workflows/deploy.yml
name: Deploy to Railway
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to Railway
        run: railway deploy
```

## 🐛 Troubleshooting

### Error de Credenciales
```bash
# Verificar variables de entorno
railway variables

# Regenerar master key si es necesario
railway run bin/rails credentials:edit
```

### Error de Base de Datos
```bash
# Verificar conexión
railway run bin/rails db:version

# Ejecutar migraciones manualmente
railway run bin/rails db:migrate
```

### Error de Deploy
```bash
# Ver logs detallados
railway logs --tail

# Verificar Dockerfile
railway run docker build .
```

## 📋 Checklist de Deploy

### Antes del Deploy
- [ ] `Dockerfile` configurado
- [ ] `railway.toml` creado
- [ ] Variables de entorno configuradas
- [ ] Base de datos PostgreSQL agregada
- [ ] `RAILS_MASTER_KEY` configurado

### Después del Deploy
- [ ] Health check en `/up` funciona
- [ ] API endpoints responden
- [ ] Base de datos conectada
- [ ] Logs sin errores
- [ ] SSL funcionando

### Testing
- [ ] `GET /up` → 200 OK
- [ ] `GET /api/orders` → 200 OK
- [ ] `GET /api/sync/status` → 200 OK
- [ ] `POST /api/sync` → 200 OK

## 🎉 Resultado Final

### URL de Producción
```
https://tu-app.railway.app
```

### Endpoints Disponibles
- ✅ `GET /up` - Health check
- ✅ `GET /api/orders` - Lista órdenes
- ✅ `GET /api/sync/status` - Estado sync
- ✅ `POST /api/sync` - Ejecutar sync
- ✅ `POST /api/sync/incremental` - Sync incremental

### Características
- ✅ SSL automático
- ✅ Base de datos PostgreSQL
- ✅ Deploy automático
- ✅ Monitoreo integrado
- ✅ Escalado automático

---

*Guía generada el 2025-09-13*
