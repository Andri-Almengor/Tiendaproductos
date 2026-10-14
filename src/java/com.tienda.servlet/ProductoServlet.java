
package com.tienda.servlet;

import com.tienda.dao.ProductoDAO;
import com.tienda.model.Producto;
import com.tienda.util.ProductoValidator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/productos")
public class ProductoServlet extends HttpServlet {

    private final ProductoDAO dao = new ProductoDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {

            request.setAttribute(
                "productos",
                dao.listarTodos()
            );

            request.getRequestDispatcher(
                "/WEB-INF/vistas/listar.jsp"
            ).forward(request, response);

        } catch (SQLException e) {

            getServletContext().log(
                "Error al listar productos", e
            );

            mostrarError(
                request,
                response,
                "No se pudo consultar la base de datos."
            );
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String nombre = request.getParameter("nombre");
        String precio = request.getParameter("precio");
        String stock = request.getParameter("stock");

        try {

            Producto producto = ProductoValidator.validar(
                nombre,
                precio,
                stock
            );

            if (!dao.insertar(producto)) {
                throw new SQLException(
                    "No se insertó el producto."
                );
            }

            response.sendRedirect(
                request.getContextPath()
                + "/productos?registrado=1"
            );

        } catch (IllegalArgumentException e) {

            request.setAttribute("error", e.getMessage());
            request.setAttribute("nombre", nombre);
            request.setAttribute("precio", precio);
            request.setAttribute("stock", stock);

            request.getRequestDispatcher(
                "/registro.jsp"
            ).forward(request, response);

        } catch (SQLException e) {

            getServletContext().log(
                "Error al guardar producto", e
            );

            mostrarError(
                request,
                response,
                "No se pudo guardar el producto. "
                + "Verifique la conexión con MySQL."
            );
        }
    }

    private void mostrarError(
            HttpServletRequest request,
            HttpServletResponse response,
            String mensaje)
            throws ServletException, IOException {

        response.setStatus(
            HttpServletResponse.SC_SERVICE_UNAVAILABLE
        );

        request.setAttribute("mensajeError", mensaje);

        request.getRequestDispatcher(
            "/WEB-INF/vistas/error.jsp"
        ).forward(request, response);
    }
}
