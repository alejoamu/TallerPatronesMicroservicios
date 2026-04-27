# Taller Microservicios: Service Discovery + Circuit Breaker (Resilence4J)

Este repositorio contiene 3 microservicios Spring Boot que implementan:

- **Service Discovery (Eureka)**: el servicio catálogo descubre dinámicamente al servicio de cursos por nombre.
- **Circuit Breaker (Hystrix)**: el servicio catálogo responde con **fallback** cuando el servicio de cursos falla o está caído.

## Repositorios / módulos

- **`FutureXEurekaServer`**: `fx-discovery-server` (Eureka Server) — puerto **8761**
- **`FutureXCourseApp`**: `fx-course-service` (Course Service) — puerto **8001**
- **`FutureXCourseCatalog`**: `fx-catalog-service` (Catalog Service) — puerto **8002**

## Criterios de calificación (cómo se cumple)

### 1) Comprensión del Service Discovery (40%)

- **Cómo descubre `fx-catalog-service` a `fx-course-service`**:
  - `fx-course-service` y `fx-catalog-service` se registran en Eureka (`fx-discovery-server`).
  - En `CatalogController`, el catálogo consulta Eureka por el nombre lógico **`fx-course-service`** y obtiene su URL real (host/puerto) antes de llamar con `RestTemplate`.

- **Demostración por endpoints** (en `fx-catalog-service`):
  - `GET http://localhost:8002/` → llama `fx-course-service /`
  - `GET http://localhost:8002/catalog` → llama `fx-course-service /courses`
  - `GET http://localhost:8002/firstcourse` → llama `fx-course-service /{id}`

### 2) Implementación de Hystrix (60%)

- **Configuración correcta de Hystrix**:
  - Dependencia `spring-cloud-starter-netflix-hystrix` en `FutureXCourseCatalog/pom.xml`
  - AOP habilitado para interceptar `@HystrixCommand` (ver `HystrixConfig.java`)

- **Fallbacks implementados**:
  - Cada endpoint del catálogo tiene un método fallback asociado (misma salida `String`).

- **Uso de `@HystrixCommand`**:
  - En `CatalogController`, cada método que llama a `fx-course-service` está anotado con:
    - `@HystrixCommand(fallbackMethod = "...")`

- **Propiedades de Hystrix**:
  - En `FutureXCourseCatalog/src/main/resources/application.properties` se ajustan timeouts y umbrales con `hystrix.command.default.*`.

- **Demostración del Circuit Breaker**:
  - Al apagar `fx-course-service`, los endpoints del catálogo devuelven el **fallback** en lugar de un error 500.

- **Cómo Hystrix mejora resiliencia**:
  - Evita que fallas/latencias del servicio de cursos propaguen errores al servicio catálogo.
  - Devuelve una respuesta degradada (fallback) y protege el sistema de cascadas de fallos.

## Ejecución local (PowerShell o Git Bash)

En 3 terminales separadas:

1. **Eureka Server**

```bash
cd FutureXEurekaServer
mvn -DskipTests spring-boot:run
```

2. **Course Service**

```bash
cd FutureXCourseApp
mvn -DskipTests spring-boot:run
```

3. **Catalog Service**

```bash
cd FutureXCourseCatalog
mvn -DskipTests spring-boot:run
```

## Prueba rápida (demo)

- **Eureka UI**: `http://localhost:8761/`  
  Debe mostrar **FX-COURSE-SERVICE** y **FX-CATALOG-SERVICE** registrados.

- Con los 3 arriba:
  - `http://localhost:8002/catalog` debe retornar el listado (vía llamada al course service).
  - `http://localhost:8002/firstcourse` debe retornar el nombre del primer curso.

- **Prueba de fallback**:
  1) Detener `FutureXCourseApp` (CTRL+C).  
  2) Volver a entrar a:
     - `http://localhost:8002/catalog`
     - `http://localhost:8002/firstcourse`
  3) Deben retornar los mensajes de **fallback**.

## Evidencia (capturas)
