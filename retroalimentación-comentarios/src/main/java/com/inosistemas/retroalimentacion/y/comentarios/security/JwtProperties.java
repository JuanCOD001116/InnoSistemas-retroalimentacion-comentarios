package com.inosistemas.retroalimentacion.y.comentarios.security;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "jwt")
public class JwtProperties {
    /** Clave Base64 para HS256 */
    private String secret;
    /** Minutos de expiración del token para utilidades locales */
    private int expMinutes = 60;

    public String getSecret() { return secret; }
    public void setSecret(String secret) { this.secret = secret; }

    public int getExpMinutes() { return expMinutes; }
    public void setExpMinutes(int expMinutes) { this.expMinutes = expMinutes; }
}


