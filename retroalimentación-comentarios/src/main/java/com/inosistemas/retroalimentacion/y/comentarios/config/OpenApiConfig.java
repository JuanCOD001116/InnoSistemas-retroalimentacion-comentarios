package com.inosistemas.retroalimentacion.y.comentarios.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Retroalimentación y Comentarios API")
                        .version("1.0")
                        .description("API para gestión de retroalimentación y comentarios"))
                .addServersItem(new Server()
                        .url("http://localhost:8092")
                        .description("Servidor Local"))
                .addServersItem(new Server()
                        .url("https://redesigned-carnival-xgq9vx6wvg43p4xg-8080.app.github.dev/")
                        .description("Servidor GitHub Codespaces"));
    }

}
