package com.inosistemas.retroalimentacion.y.comentarios;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class RetroalimentacionYComentariosApplication {

	public static void main(String[] args) {
		SpringApplication.run(RetroalimentacionYComentariosApplication.class, args);
	}

}
