package com.inosistemas.retroalimentacion.y.comentarios.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import com.inosistemas.retroalimentacion.y.comentarios.config.AppSecurityProperties;
import com.inosistemas.retroalimentacion.y.comentarios.config.WebsocketProperties;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter;
import org.springframework.security.core.userdetails.UserDetailsService;

@Configuration
@EnableConfigurationProperties({JwtProperties.class, AppSecurityProperties.class, WebsocketProperties.class})
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http, JwtService jwtService) throws Exception {
        // DESACTIVAR SEGURIDAD PARA PRUEBAS - Permitir todas las rutas sin autenticación
        http.csrf(csrf -> csrf.disable())
            .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(reg -> reg
                .anyRequest().permitAll()) // Permitir todo sin autenticación
            .httpBasic(httpBasic -> httpBasic.disable());

        // Agregar filtro para proveer usuario dummy desde headers
        http.addFilterAfter(new UserIdHeaderFilter(), BasicAuthenticationFilter.class);
        return http.build();
    }

    /**
     * Bean vacío para evitar la auto-configuración de usuarios en memoria y desactivar el login básico.
     */
    @Bean
    public UserDetailsService userDetailsService() {
        return username -> null;
    }
}


