
package com.tienda.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexion {

    private static final String URL =
        "jdbc:mysql://localhost:3305/tienda"
        + "?useSSL=false"
        + "&allowPublicKeyRetrieval=true"
        + "&serverTimezone=UTC";

    private static final String USUARIO = "root";

    public static Connection obtenerConexion() throws SQLException {

        // Obtener contraseña desde Windows
        String password = System.getenv("TIENDA_DB_PASSWORD");

        if (password == null || password.isEmpty()) {
            throw new SQLException(
                "No se configuró la variable TIENDA_DB_PASSWORD."
            );
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            return DriverManager.getConnection(
                URL,
                USUARIO,
                password
            );

        } catch (ClassNotFoundException e) {
            throw new SQLException(
                "No se encontró MySQL Connector/J.",
                e
            );
        }
    }
}
