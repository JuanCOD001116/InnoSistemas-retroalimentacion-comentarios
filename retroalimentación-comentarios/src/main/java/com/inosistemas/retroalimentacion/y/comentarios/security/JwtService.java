package com.inosistemas.retroalimentacion.y.comentarios.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Base64;

@Component
class JwtService {

    private final SecretKey key;

    JwtService(JwtProperties properties) {
        byte[] decoded = Base64.getDecoder().decode(properties.getSecret());
        this.key = Keys.hmacShaKeyFor(decoded);
    }

    Claims parse(String token) {
        return Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token).getBody();
    }
}


