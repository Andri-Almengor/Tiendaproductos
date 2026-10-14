
package com.tienda.util;

public class Html {

    public static String escape(Object valor) {

        if (valor == null) {
            return "";
        }

        return String.valueOf(valor)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }
}
