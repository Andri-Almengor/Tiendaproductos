# TiendaProductos — Aplicación web con Java, JSP, Servlet, DAO y MySQL

**Universidad:** Universidad Castro Carazo  
**Curso:** 2026C3-G01-PROGRAMACIÓN DE COMPUTADORAS II  
**Autor:** Andrick Ivan Almengor Quirós  
**Fecha:** 14 de octubre de 2026  
**Documentación editable:** [Informe completo en Google Docs](https://docs.google.com/document/d/1VE81Of_VLwgVuBanEuKw-4FgmoloPDK-v1ldchuzjW8/edit)  

Aplicación de inventario desarrollada en Java Web con **JSP (vista), Servlet (controlador), DAO con `PreparedStatement` (acceso a datos) y MySQL (persistencia)**. Permite registrar productos y consultar su listado con precio, stock y estado de disponibilidad.

> Este README reproduce el contenido técnico del informe académico **sin fotografías ni capturas de pantalla**. Las capturas originales permanecen disponibles en el documento de Google Docs.

## 1. Índice

- [2. Repositorio GitHub](#seccion-2)
- [3. Creación de la base de datos](#seccion-3)
  - [3.1 Creación de la base de datos y de la tabla](#seccion-3-1)
  - [3.2 Inserción de cinco productos de prueba](#seccion-3-2)
  - [3.3 Usuario utilizado por la aplicación y consultas de comprobación](#seccion-3-3)
- [4. Explicación del código](#seccion-4)
  - [4.1 Modelo Producto.java](#seccion-4-1)
  - [4.2 Clase Conexion.java](#seccion-4-2)
  - [4.3 Clase ProductoDAO.java y PreparedStatement](#seccion-4-3)
  - [4.4 Controlador ProductoServlet.java](#seccion-4-4)
  - [4.5 Validación y seguridad: ProductoValidator.java y Html.java](#seccion-4-5)
  - [4.6 Formulario registro.jsp](#seccion-4-6)
  - [4.7 Página listar.jsp y vistas complementarias](#seccion-4-7)
  - [4.8 Flujo general de funcionamiento](#seccion-4-8)
- [5. Configuración de JDBC, NetBeans y Tomcat](#seccion-5)
  - [5.1 Puerto local de MySQL: 3305](#seccion-5-1)
  - [5.2 MySQL Connector/J y despliegue en Tomcat 11](#seccion-5-2)
  - [5.3 Ejecución de la aplicación y adaptación de puertos](#seccion-5-3)
- [6. Solución de problemas encontrados](#seccion-6)
  - [6.1 Error de lectura del archivo web.xml](#seccion-6-1)
  - [6.2 Error de despliegue: path is null](#seccion-6-2)
  - [6.3 Error Access denied for user root](#seccion-6-3)
  - [6.4 Comprobación de la conexión y validación de datos](#seccion-6-4)
  - [6.5 Resumen del diagnóstico](#seccion-6-5)
- [7. Evidencias](#seccion-7)
- [8. Referencias APA](#seccion-8)

---

<a id="seccion-2"></a>

## 2. Repositorio GitHub

El código fuente del proyecto TiendaProductos se encuentra publicado en el siguiente repositorio de GitHub:

[Ver código fuente en GitHub](https://github.com/Andri-Almengor/Tiendaproductos)

El repositorio contiene el proyecto de aplicación web creado en NetBeans con Apache Ant, las clases Java del modelo, el DAO y el Servlet, así como las páginas JSP, los estilos CSS y los archivos de configuración del despliegue. El repositorio utiliza actualmente el nombre de proyecto WebApplication1 y publica las clases de la aplicación en paquetes com.tienda.*.

Entre los archivos consultados destacan Producto.java, Conexion.java, ProductoDAO.java, ProductoServlet.java, ProductoValidator.java, Html.java, registro.jsp, listar.jsp, index.jsp, web.xml y context.xml. También se observan carpetas de construcción build y dist. El script SQL requerido se reproduce en la sección 3 de este informe para su entrega; al revisar el repositorio, no figuraba un archivo tienda.sql en la raíz.

<a id="seccion-3"></a>

## 3. Creación de la base de datos

La aplicación almacena su inventario en la base de datos MySQL llamada tienda. La tabla productos contiene un identificador único autoincremental, el nombre del producto, un precio decimal y una cantidad disponible en inventario.

<a id="seccion-3-1"></a>

### 3.1 Creación de la base de datos y de la tabla

El siguiente script crea la base, selecciona el esquema y define los campos solicitados en la práctica:

```sql
CREATE DATABASE IF NOT EXISTS tienda
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE tienda;

CREATE TABLE IF NOT EXISTS productos (
id INT AUTO_INCREMENT PRIMARY KEY,
nombre VARCHAR(100) NOT NULL,
precio DECIMAL(10,2) NOT NULL,
stock INT NOT NULL,
CONSTRAINT chk_precio CHECK (precio >= 0),
CONSTRAINT chk_stock CHECK (stock >= 0)
);
```

La columna id utiliza INT, AUTO_INCREMENT y PRIMARY KEY para generar una clave única. nombre se declara VARCHAR(100), precio utiliza DECIMAL(10,2) para representar valores monetarios sin las imprecisiones habituales de coma flotante y stock utiliza INT. Las restricciones CHECK evitan precios o existencias negativas.

<a id="seccion-3-2"></a>

### 3.2 Inserción de cinco productos de prueba

Para verificar el listado inicial se ejecuta una inserción de cinco registros. Este bloque debe ejecutarse una sola vez para no duplicar productos de ejemplo:

```sql
INSERT INTO productos (nombre, precio, stock)
VALUES
('Teclado mecánico', 24500.00, 12),
('Mouse inalámbrico', 8900.50, 20),
('Monitor 24 pulgadas', 72500.00, 6),
('Memoria USB 64 GB', 6500.00, 35),
('Audífonos Bluetooth', 19990.00, 0);
```

La evidencia del inventario inicial (evidencia 1) muestra estos cinco productos y distingue entre artículos disponibles y agotados cuando el stock es cero.

<a id="seccion-3-3"></a>

### 3.3 Usuario utilizado por la aplicación y consultas de comprobación

En la ejecución local documentada, la clase Conexion.java utiliza el usuario root y recupera la contraseña desde la variable de entorno TIENDA_DB_PASSWORD. La contraseña no se guarda directamente en el código fuente ni debe incluirse en el documento o en GitHub.

```sql
SHOW VARIABLES LIKE 'port';
SHOW DATABASES LIKE 'tienda';
USE tienda;
SELECT id, nombre, precio, stock
FROM productos ORDER BY id;
```

Estas instrucciones permiten confirmar que MySQL responde en el puerto correcto, que la base tienda existe y que los registros se almacenaron. Para un entorno real es preferible crear una cuenta propia con permisos limitados a SELECT e INSERT, en vez de utilizar root.

<a id="seccion-4"></a>

## 4. Explicación del código

La solución sigue una arquitectura sencilla de cuatro niveles: vista con JSP, controlador con Servlet, acceso a datos mediante DAO y persistencia en MySQL. La lógica se distribuye en clases independientes para separar las responsabilidades y facilitar la revisión.

<a id="seccion-4-1"></a>

### 4.1 Modelo Producto.java

Producto.java, dentro del paquete com.tienda.model, representa cada fila de la tabla productos. Sus atributos son id (int), nombre (String), precio (BigDecimal) y stock (int). Dispone de constructores, métodos get y set.

```java
private int id;
private String nombre;
private BigDecimal precio;
private int stock;
```

BigDecimal se utiliza para el precio porque mantiene una representación decimal adecuada para cantidades de dinero.

<a id="seccion-4-2"></a>

### 4.2 Clase Conexion.java

Conexion.java concentra la cadena JDBC, el usuario y el mecanismo de autenticación. En la computadora de desarrollo se utiliza localhost:3305, el esquema tienda y la clase com.mysql.cj.jdbc.Driver.

```java
private static final String URL =
"jdbc:mysql://localhost:3305/tienda"
+ "?useSSL=false"
+ "&allowPublicKeyRetrieval=true"
+ "&serverTimezone=UTC";

private static final String USUARIO = "root";
String password = System.getenv("TIENDA_DB_PASSWORD");
Class.forName("com.mysql.cj.jdbc.Driver");
return DriverManager.getConnection(URL, USUARIO, password);
```

Si TIENDA_DB_PASSWORD no está configurada, la versión publicada de Conexion.java genera SQLException con un mensaje explícito. useSSL=false y allowPublicKeyRetrieval=true se aplicaron a esta práctica local; para producción se deben configurar conexiones cifradas y usuarios con privilegios mínimos.

<a id="seccion-4-3"></a>

### 4.3 Clase ProductoDAO.java y PreparedStatement

ProductoDAO.java, en com.tienda.dao, implementa insertar() y listarTodos(). Para registrar un producto utiliza una consulta parametrizada mediante PreparedStatement; los datos se asignan con setString, setBigDecimal y setInt.

```sql
String sql = "INSERT INTO productos "
+ "(nombre, precio, stock) VALUES (?, ?, ?)";

try (Connection conexion = Conexion.obtenerConexion();
PreparedStatement ps = conexion.prepareStatement(sql)) {
ps.setString(1, producto.getNombre());
ps.setBigDecimal(2, producto.getPrecio());
ps.setInt(3, producto.getStock());
return ps.executeUpdate() == 1;
}
```

El signo ? representa cada parámetro. Esta separación evita concatenar directamente los valores recibidos en una sentencia SQL y ayuda a prevenir ataques de inyección SQL. La estructura try-with-resources asegura que Connection y PreparedStatement se cierren al terminar.

Para el listado, el DAO ejecuta una consulta SELECT, recorre ResultSet y construye objetos Producto:

```sql
String sql = "SELECT id, nombre, precio, stock "
+ "FROM productos ORDER BY id ASC";

while (rs.next()) {
Producto producto = new Producto();
producto.setId(rs.getInt("id"));
producto.setNombre(rs.getString("nombre"));
producto.setPrecio(rs.getBigDecimal("precio"));
producto.setStock(rs.getInt("stock"));
lista.add(producto);
}
```

<a id="seccion-4-4"></a>

### 4.4 Controlador ProductoServlet.java

ProductoServlet.java utiliza @WebServlet("/productos") y extiende HttpServlet. El método doGet llama a dao.listarTodos(), coloca la lista en el atributo productos y la envía a /WEB-INF/vistas/listar.jsp. El método doPost recibe los campos nombre, precio y stock desde registro.jsp, valida la información y llama al DAO para insertar el producto.

```java
@WebServlet("/productos")
public class ProductoServlet extends HttpServlet {
private final ProductoDAO dao = new ProductoDAO();
// doGet(): lista y realiza forward a listar.jsp.
// doPost(): valida e inserta y luego redirige.
}
```

Después de una inserción exitosa, el Servlet realiza sendRedirect hacia /productos?registrado=1. Este esquema de redirección evita repetir el POST al actualizar el navegador y permite mostrar el aviso “Producto registrado correctamente”. Ante un fallo JDBC, el Servlet registra la excepción en Tomcat y utiliza error.jsp.

<a id="seccion-4-5"></a>

### 4.5 Validación y seguridad: ProductoValidator.java y Html.java

ProductoValidator.java comprueba que el nombre no esté vacío y que tenga como máximo 100 caracteres, que el precio no sea negativo y tenga hasta dos decimales, y que stock sea un número entero no negativo.

```java
if (nombre == null || nombre.isBlank()) {
throw new IllegalArgumentException(
"El nombre es obligatorio.");
}
if (precio.signum() < 0 || precio.scale() > 2) {
throw new IllegalArgumentException(
"El precio debe ser positivo o cero.");
}
if (stock < 0) {
throw new IllegalArgumentException(
"El stock no puede ser negativo.");
}
```

La implementación completa también impone un precio máximo compatible con DECIMAL(10,2). Html.java reemplaza caracteres especiales como &, <, > y comillas por entidades HTML antes de representar nombres o mensajes introducidos por el usuario; esta operación reduce el riesgo de interpretar texto del usuario como etiquetas HTML.

<a id="seccion-4-6"></a>

### 4.6 Formulario registro.jsp

registro.jsp muestra el formulario con los campos Nombre del producto, Precio y Stock. El envío utiliza POST hacia la ruta del Servlet, de forma que la JSP únicamente captura y presenta los datos.

```jsp
<form method="post"
action="${pageContext.request.contextPath}/productos"
accept-charset="UTF-8">
<input type="text" name="nombre" maxlength="100" required>
<input type="number" name="precio" step="0.01" min="0" required>
<input type="number" name="stock" step="1" min="0" required>
<button type="submit">Guardar producto</button>
</form>
```

El formulario también recupera los datos introducidos cuando existe un error de validación y presenta el mensaje devuelto por el Servlet. La evidencia 2 muestra esta pantalla.

<a id="seccion-4-7"></a>

### 4.7 Página listar.jsp y vistas complementarias

listar.jsp obtiene desde request el atributo productos y recorre la colección de objetos. Construye una tabla de cinco columnas: ID, Producto, Precio, Stock y Estado. Si stock es superior a cero, la vista muestra Disponible; en caso contrario, Agotado.

```jsp
<%
List<Producto> productos =
(List<Producto>) request.getAttribute("productos");
%>
<% for (Producto producto : productos) { %>
<td><%= Html.escape(producto.getNombre()) %></td>
<td><%= producto.getStock() %></td>
<% } %>
```

index.jsp redirige internamente a /productos con jsp:forward. error.jsp presenta fallos de base de datos sin exponer detalles internos de la excepción al usuario. estilos.css proporciona el diseño responsive, tarjetas, botones y estilos para la tabla. web.xml declara el archivo de inicio y context.xml establece el contexto /WebApplication1.

<a id="seccion-4-8"></a>

### 4.8 Flujo general de funcionamiento

Al entrar en la dirección /WebApplication1, index.jsp transfiere la solicitud hacia /productos. ProductoServlet.doGet llama a ProductoDAO.listarTodos(), el DAO solicita una conexión a Conexion.java y MySQL devuelve los registros. El Servlet envía la lista a listar.jsp, que muestra el inventario.

Para registrar un artículo, el usuario abre registro.jsp y completa el formulario. La solicitud POST llega a ProductoServlet.doPost, el validador transforma los valores a un objeto Producto, el DAO ejecuta INSERT mediante PreparedStatement y el Servlet redirige al listado. La página informa sobre el registro exitoso y muestra el producto nuevo.

<a id="seccion-5"></a>

## 5. Configuración de JDBC, NetBeans y Tomcat

El proyecto se desarrolló como una aplicación Java Web en Apache NetBeans, con compilación Ant, páginas JSP y un Servlet compatible con Jakarta Servlet 6.1. El servidor de despliegue utilizado fue Apache Tomcat 11.0.11.

<a id="seccion-5-1"></a>

### 5.1 Puerto local de MySQL: 3305

Durante el desarrollo se confirmó que la instancia local de MySQL escucha en el puerto 3305. Este puerto es diferente del estándar 3306, de modo que la cadena JDBC del proyecto utiliza localhost:3305/tienda.

```sql
SHOW VARIABLES LIKE 'port';
-- Configuración de la práctica:
jdbc:mysql://localhost:3305/tienda
```

<a id="seccion-5-2"></a>

### 5.2 MySQL Connector/J y despliegue en Tomcat 11

Se agregó el archivo mysql-connector-j-*.jar en las Libraries del proyecto. La librería permite cargar com.mysql.cj.jdbc.Driver. El proyecto se despliega en Tomcat 11 y utiliza jakarta.servlet en lugar de javax.servlet.

La ejecución final registró los mensajes “OK - Desplegada aplicación en trayectoria de contexto [/WebApplication1]”, “OK - Arrancada aplicación” y “BUILD SUCCESSFUL”. Estos mensajes comprueban el despliegue correcto; las imágenes de las figuras 1 y 3 evidencian además consultas exitosas a MySQL.

<a id="seccion-5-3"></a>

### 5.3 Ejecución de la aplicación y adaptación de puertos

Para ejecutar, se inicia MySQL, se configura la variable TIENDA_DB_PASSWORD para el proceso de Tomcat, se selecciona Clean and Build en NetBeans y después Run (F6). La aplicación abre en http://localhost:8080/WebApplication1 y el listado se consulta en /WebApplication1/productos. Si MySQL emplea 3306, debe actualizarse la URL JDBC y comprobarla con SHOW VARIABLES LIKE 'port'.

<a id="seccion-6"></a>

## 6. Solución de problemas encontrados

Durante la práctica se detectaron y resolvieron errores reales en la configuración de la aplicación. El registro de Tomcat fue fundamental para distinguir fallos del descriptor XML, despliegue y autenticación JDBC.

<a id="seccion-6-1"></a>

### 6.1 Error de lectura del archivo web.xml

Inicialmente Tomcat informaba que el contexto /WebApplication1 no podía arrancar. El archivo catalina.2026-10-14.log señaló una SAXParseException en web.xml, línea 2, columna 6: la declaración XML no estaba permitida en esa posición. La causa se relacionó con declaraciones XML duplicadas o contenido ubicado antes de la cabecera.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app
xmlns="https://jakarta.ee/xml/ns/jakartaee"
version="6.1">
<welcome-file-list>
<welcome-file>index.jsp</welcome-file>
</welcome-file-list>
</web-app>
```

La solución fue conservar una única declaración XML al inicio del archivo y un solo elemento web-app válido. A partir de ese ajuste, la aplicación pudo superar el error inicial de lectura.

<a id="seccion-6-2"></a>

### 6.2 Error de despliegue: path is null

En otra prueba apareció “Cannot invoke String.isEmpty() because path is null” al usar context.xml sin el atributo path. En esta configuración de NetBeans y Tomcat se restableció la ruta de despliegue del proyecto:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Context path="/WebApplication1"/>
```

El error concreto de ruta dejó de aparecer. La definición del contexto se mantuvo separada del descriptor WEB-INF/web.xml.

<a id="seccion-6-3"></a>

### 6.3 Error Access denied for user root

Cuando Tomcat ya desplegaba correctamente, la aplicación mostraba “No se pudo consultar la base de datos”. El registro reveló el mensaje “Access denied for user 'root'@'localhost' (using password: NO)”, indicando que Java intentaba autenticarse sin contraseña.

Se identificó que la llamada System.getenv estaba consultando erróneamente el texto de la contraseña como nombre de variable. Se corrigió el código para leer TIENDA_DB_PASSWORD y se reiniciaron NetBeans/Tomcat para incorporar la variable de entorno. Por seguridad, el valor real no se reproduce en este informe.

```java
String password = System.getenv("TIENDA_DB_PASSWORD");
return DriverManager.getConnection(
URL, USUARIO, password);
```

Después de esta corrección fue posible consultar la tabla de productos desde el navegador, como muestran las evidencias presentadas.

<a id="seccion-6-4"></a>

### 6.4 Comprobación de la conexión y validación de datos

La interfaz permitió listar los cinco productos iniciales y luego mostrar un sexto producto después de registrar una fila nueva. En el formulario se observaron los controles de entrada y la aplicación implementa validación tanto de HTML como del lado del servidor, necesaria para rechazar precios que superen los límites admitidos.

La captura del formulario incluida como evidencia 2 muestra un precio extremadamente alto durante la edición del campo. Esa imagen demuestra la visualización del formulario, pero no debe interpretarse como prueba de que ese valor haya sido aceptado: la evidencia 3 demuestra un registro correcto del producto “otro” con precio ₡100.00 y stock 1.

<a id="seccion-6-5"></a>

### 6.5 Resumen del diagnóstico

El proceso de diagnóstico siguió una secuencia: primero se corrigió la estructura de web.xml, luego la ruta del contexto de Tomcat, después se confirmó que el proyecto desplegaba con BUILD SUCCESSFUL y finalmente se corrigió la lectura de la contraseña para MySQL. El resultado final evidencia que el listado y la inserción funcionan usando el esquema tienda.

<a id="seccion-7"></a>

## 7. Evidencias

Las pruebas documentadas se describen a continuación sin reproducir las capturas; las imágenes originales pueden consultarse en el [informe de Google Docs](https://docs.google.com/document/d/1VE81Of_VLwgVuBanEuKw-4FgmoloPDK-v1ldchuzjW8/edit).

Las siguientes capturas, obtenidas durante las pruebas locales, documentan el funcionamiento de la aplicación.

#### Evidencia 1. Listado inicial de cinco productos almacenados en MySQL

*Nota. Elaboración propia a partir de la ejecución local del proyecto. Se observan cinco productos, sus precios, existencias y estados Disponible o Agotado.*

#### Evidencia 2. Formulario JSP para el registro de nuevos productos

*Nota. Elaboración propia. La captura muestra los campos de nombre, precio y stock. El valor alto introducido en precio corresponde a la pantalla de edición, no a un registro exitoso.*

#### Evidencia 3. Confirmación de registro y listado actualizado a seis productos

*Nota. Elaboración propia a partir de la ejecución local del proyecto. La interfaz confirma el registro del producto “otro” por ₡100.00, con stock 1, y el contador aumenta de cinco a seis productos.*

Estas evidencias respaldan la funcionalidad del formulario, el Servlet, las operaciones SQL ejecutadas mediante el DAO y la representación del inventario en una JSP.

<a id="seccion-8"></a>

## 8. Referencias APA

Almengor Quirós, A. I. (2026). Tiendaproductos [Código fuente]. GitHub. https://github.com/Andri-Almengor/Tiendaproductos

Apache Software Foundation. (s. f.). Apache NetBeans. https://netbeans.apache.org/

Apache Software Foundation. (s. f.). Apache Tomcat 11. https://tomcat.apache.org/tomcat-11.0-doc/

Eclipse Foundation. (2024). Jakarta Servlet Specification, Version 6.1. https://jakarta.ee/specifications/servlet/6.1/

Oracle. (s. f.). JDBC basics. https://docs.oracle.com/javase/tutorial/jdbc/basics/

Oracle. (s. f.). MySQL 8.0 Reference Manual. https://dev.mysql.com/doc/refman/8.0/en/

Oracle. (s. f.). MySQL Connector/J Developer Guide. https://dev.mysql.com/doc/connector-j/en/

