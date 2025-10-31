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
        http.csrf(csrf -> csrf.disable())
            .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(reg -> reg
                .requestMatchers(
                    "/swagger-ui.html", "/swagger-ui/**",
                    "/api-docs", "/api-docs/**",
                    "/v3/api-docs", "/v3/api-docs/**",
                    "/ws/**"
                ).permitAll()
                .anyRequest().authenticated())
            .httpBasic(httpBasic -> httpBasic.disable());

        http.addFilterBefore(new JwtAuthenticationFilter(jwtService), BasicAuthenticationFilter.class)
            .addFilterAfter(new UserIdHeaderFilter(), JwtAuthenticationFilter.class); // fallback dev
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


