
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.tienda.util.Html"%>

<!DOCTYPE html>
<html lang="es">
<head>

    <meta charset="UTF-8">

    <title>Error | Tienda</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/estilos.css">

</head>

<body>

<main class="layout main-container narrow">

    <h1>No fue posible completar la solicitud</h1>

    <div class="alert alert-error">
        <%= Html.escape(request.getAttribute("mensajeError")) %>
    </div>

    <p class="subhead">
        Verifique que MySQL esté iniciado y que
        la base de datos tienda exista.
    </p>

    <a class="button button-primary"
       href="${pageContext.request.contextPath}/productos">
        Reintentar
    </a>

</main>

</body>
</html>
