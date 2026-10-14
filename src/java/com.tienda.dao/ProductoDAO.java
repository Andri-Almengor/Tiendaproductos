
package com.tienda.dao;

import com.tienda.model.Producto;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProductoDAO {

    public boolean insertar(Producto producto) throws SQLException {

        String sql = "INSERT INTO productos "
                + "(nombre, precio, stock) VALUES (?, ?, ?)";

        try (Connection conexion = Conexion.obtenerConexion();
             PreparedStatement ps = conexion.prepareStatement(sql)) {

            ps.setString(1, producto.getNombre());
            ps.setBigDecimal(2, producto.getPrecio());
            ps.setInt(3, producto.getStock());

            return ps.executeUpdate() == 1;
        }
    }

    public List<Producto> listarTodos() throws SQLException {

        List<Producto> lista = new ArrayList<>();

        String sql = "SELECT id, nombre, precio, stock "
                + "FROM productos ORDER BY id ASC";

        try (Connection conexion = Conexion.obtenerConexion();
             PreparedStatement ps = conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Producto producto = new Producto();

                producto.setId(rs.getInt("id"));
                producto.setNombre(rs.getString("nombre"));
                producto.setPrecio(rs.getBigDecimal("precio"));
                producto.setStock(rs.getInt("stock"));

                lista.add(producto);
            }
        }

        return lista;
    }
}
