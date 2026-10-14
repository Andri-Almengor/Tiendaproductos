
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.tienda.util.Html"%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Registrar producto | Tienda</title>

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
            <a href="${pageContext.request.contextPath}/productos">
                Inventario
            </a>

            <a class="active"
               href="${pageContext.request.contextPath}/registro.jsp">
                Registrar
            </a>
        </nav>

    </div>
</header>

<main class="layout main-container narrow">

    <div class="eyebrow">GESTIÓN DE INVENTARIO</div>

    <h1>Registrar producto</h1>

    <p class="subhead">
        Agregue un nuevo producto a la tienda.
    </p>

    <% if (request.getAttribute("error") != null) { %>

        <div class="alert alert-error">
            <%= Html.escape(request.getAttribute("error")) %>
        </div>

    <% } %>

    <section class="panel">

        <form method="post"
              action="${pageContext.request.contextPath}/productos"
              accept-charset="UTF-8">

            <div class="form-field">

                <label for="nombre">
                    Nombre del producto *
                </label>

                <input
                    type="text"
                    id="nombre"
                    name="nombre"
                    maxlength="100"
                    required
                    placeholder="Ejemplo: Teclado mecánico"
                    value="<%= Html.escape(request.getAttribute("nombre")) %>">

            </div>

            <div class="input-grid">

                <div class="form-field">

                    <label for="precio">Precio *</label>

                    <input
                        type="number"
                        id="precio"
                        name="precio"
                        min="0"
                        max="99999999.99"
                        step="0.01"
                        required
                        placeholder="0.00"
                        value="<%= Html.escape(request.getAttribute("precio")) %>">

                </div>

                <div class="form-field">

                    <label for="stock">Stock *</label>

                    <input
                        type="number"
                        id="stock"
                        name="stock"
                        min="0"
                        max="2147483647"
                        step="1"
                        required
                        placeholder="0"
                        value="<%= Html.escape(request.getAttribute("stock")) %>">

                </div>

            </div>

            <div class="form-actions">

                <a class="button button-light"
                   href="${pageContext.request.contextPath}/productos">
                    Cancelar
                </a>

                <button type="submit"
                        class="button button-primary">
                    Guardar producto
                </button>

            </div>

        </form>

    </section>

</main>

</body>
</html>
