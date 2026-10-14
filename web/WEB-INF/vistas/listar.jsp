
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.tienda.model.Producto"%>
<%@page import="com.tienda.util.Html"%>

<%
    @SuppressWarnings("unchecked")
    List<Producto> productos =
        (List<Producto>) request.getAttribute("productos");
%>

<!DOCTYPE html>
<html lang="es">
<head>

    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Productos | Tienda</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/estilos.css">

</head>

<body>

<header class="topbar">

    <div class="layout topbar-inner">

        <a class="brand"
           href="${pageContext.request.contextPath}/productos">
            TiendaProductos
        </a>

        <nav>
            <a class="active"
               href="${pageContext.request.contextPath}/productos">
                Inventario
            </a>

            <a href="${pageContext.request.contextPath}/registro.jsp">
                Registrar
            </a>
        </nav>

    </div>

</header>

<main class="layout main-container">

    <div class="page-title">

        <div>
            <div class="eyebrow">GESTIÓN DE INVENTARIO</div>

            <h1>Productos de la tienda</h1>

            <p class="subhead">
                Productos almacenados en MySQL.
            </p>
        </div>

        <a class="button button-primary"
           href="${pageContext.request.contextPath}/registro.jsp">
            + Nuevo producto
        </a>

    </div>

    <% if ("1".equals(request.getParameter("registrado"))) { %>

        <div class="alert alert-success">
            Producto registrado correctamente.
        </div>

    <% } %>

    <div class="metrics">

        <div class="metric-title">
            Total de productos
        </div>

        <div class="metric-number">
            <%= productos == null ? 0 : productos.size() %>
        </div>

    </div>

    <section class="panel panel-table">

        <div class="table-caption">
            Inventario actual
        </div>

        <div class="table-scroll">

            <table>

                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Producto</th>
                        <th>Precio</th>
                        <th>Stock</th>
                        <th>Estado</th>
                    </tr>
                </thead>

                <tbody>

                <%
                    if (productos == null || productos.isEmpty()) {
                %>

                    <tr>
                        <td colspan="5" class="empty">
                            No hay productos registrados.
                        </td>
                    </tr>

                <%
                    } else {
                        for (Producto producto : productos) {
                %>

                    <tr>

                        <td>
                            #<%= producto.getId() %>
                        </td>

                        <td class="product-name">
                            <%= Html.escape(producto.getNombre()) %>
                        </td>

                        <td class="price">
                            ₡<%= String.format(
                                java.util.Locale.US,
                                "%,.2f",
                                producto.getPrecio()
                            ) %>
                        </td>

                        <td>
                            <%= producto.getStock() %>
                        </td>

                        <td>

                        <% if (producto.getStock() > 0) { %>

                            <span class="status status-ok">
                                Disponible
                            </span>

                        <% } else { %>

                            <span class="status status-low">
                                Agotado
                            </span>

                        <% } %>

                        </td>

                    </tr>

                <%
                        }
                    }
                %>

                </tbody>

            </table>

        </div>

    </section>

</main>

</body>
</html>
