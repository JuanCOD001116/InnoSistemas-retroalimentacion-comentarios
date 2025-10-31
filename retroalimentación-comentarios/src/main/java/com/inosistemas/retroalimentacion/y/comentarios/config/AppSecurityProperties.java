package com.inosistemas.retroalimentacion.y.comentarios.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.security")
public class AppSecurityProperties {

    private boolean enabled = true;
    private String jwtPublicKeyPem;

    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }

    public String getJwtPublicKeyPem() { return jwtPublicKeyPem; }
    public void setJwtPublicKeyPem(String jwtPublicKeyPem) { this.jwtPublicKeyPem = jwtPublicKeyPem; }
}


