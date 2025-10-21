package edu.dosw.sirha.SIRHA_BackEnd.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * Configuración de Swagger/OpenAPI para la documentación de la API
 * 
 * Una vez configurado, la documentación estará disponible en:
 * - Swagger UI: http://localhost:8080/swagger-ui.html
 * - OpenAPI JSON: http://localhost:8080/v3/api-docs
 */
@Configuration
public class SwaggerConfig {

    @Value("${server.port:8080}")
    private String serverPort;

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("SIRHA Backend API")
                        .version("1.0.0")
                        .description("API REST para el Sistema de Información de Recursos Humanos y Administrativos (SIRHA). " +
                                "Esta API proporciona endpoints para la gestión de estudiantes, materias, grupos y solicitudes académicas.")
                        .contact(new Contact()
                                .name("Equipo SIRHA")
                                .email("sirha@dosw.edu")
                                .url("https://dosw.edu"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")))
                .servers(List.of(
                        new Server()
                                .url("http://localhost:" + serverPort)
                                .description("Servidor de desarrollo local"),
                        new Server()
                                .url("https://sirha-api.dosw.edu")
                                .description("Servidor de producción")
                ));
    }
}