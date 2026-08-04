# 🚀 Quick Start - API Pharma Rails

## 📋 **¿Qué hace esta API?**

API de sincronización entre **Tienda Nube** y sistema de facturación farmacéutico.

### **Endpoints disponibles:**
- `GET /up` - Health check
- `GET /api/orders` - Listar órdenes
- `GET /api/sync/status` - Estado de sincronización
- `POST /api/sync/incremental` - Sincronización incremental

---

## 🛠️ **Setup Local (5 minutos)**

### **1. Clonar y configurar:**
```bash
git clone git@github.com:lucasvidela94/rails-pharma.git
cd rails-pharma
```

### **2. Variables de entorno:**
```bash
cp env.example .env
```

Editar `.env` con tus credenciales:
```bash
RAILS_ENV=development
RAILS_MASTER_KEY=f8a673817784b4e819805e1fb8a50d78
TIENDA_NUBE_STORE_ID=tu_store_id_aqui
TIENDA_NUBE_ACCESS_TOKEN=tu_access_token_aqui
```

### **3. Instalar dependencias:**
```bash
bundle install
```

### **4. Base de datos:**
```bash
rails db:create
rails db:migrate
```

### **5. Iniciar servidor:**
```bash
rails server
```

**¡Listo!** API disponible en `http://localhost:3000`

---

## 🐳 **Setup con Docker (2 minutos)**

### **1. Clonar:**
```bash
git clone git@github.com:lucasvidela94/rails-pharma.git
cd rails-pharma
```

### **2. Variables de entorno:**
```bash
cp env.example .env
# Editar .env con tus credenciales
```

### **3. Docker:**
```bash
docker build -t pharma-rails .
docker run -p 3000:3000 --env-file .env pharma-rails
```

**¡Listo!** API disponible en `http://localhost:3000`

---

## 🧪 **Pruebas Rápidas**

### **Health Check:**
```bash
curl http://localhost:3000/up
# Respuesta: <html><body style="background-color: green"></body></html>
```

### **Listar órdenes:**
```bash
curl http://localhost:3000/api/orders
# Respuesta: []
```

### **Estado de sync:**
```bash
curl http://localhost:3000/api/sync/status
# Respuesta: JSON con detalles del último sync
```

### **Sincronización:**
```bash
curl -X POST http://localhost:3000/api/sync/incremental
# Respuesta: JSON con resultado de la sincronización
```

---

## 🔧 **Configuración Tienda Nube**

### **Obtener credenciales:**
1. Ir a [Tienda Nube](https://tiendanube.com)
2. Panel de administración → **Desarrolladores**
3. **API** → Crear nueva aplicación
4. Copiar `Store ID` y `Access Token`

### **Configurar en .env:**
```bash
TIENDA_NUBE_STORE_ID=123456
TIENDA_NUBE_ACCESS_TOKEN=tu_token_aqui
```

---

## 📊 **API en Producción**

**URL:** https://rails-pharma.onrender.com

### **Endpoints:**
- `GET https://rails-pharma.onrender.com/up`
- `GET https://rails-pharma.onrender.com/api/orders`
- `GET https://rails-pharma.onrender.com/api/sync/status`
- `POST https://rails-pharma.onrender.com/api/sync/incremental`

---

## 🚨 **Troubleshooting**

### **Error: "Invalid credentials"**
- Verificar `TIENDA_NUBE_STORE_ID` y `TIENDA_NUBE_ACCESS_TOKEN` en `.env`

### **Error: "Database connection"**
- Ejecutar `rails db:create db:migrate`

### **Error: "Port already in use"**
- Cambiar puerto: `rails server -p 3001`

---

## 📚 **Documentación Completa**

- **README.md** - Documentación completa
- **API_DOCUMENTATION.md** - Detalles de endpoints
- **Dockerfile** - Configuración Docker

---

## 🎯 **¿Qué probar?**

1. **Health check** - Verificar que la API responde
2. **Listar órdenes** - Ver órdenes sincronizadas
3. **Estado de sync** - Ver historial de sincronizaciones
4. **Sincronización** - Probar sync con Tienda Nube

**¡Disfruta probando la API!** 🚀
