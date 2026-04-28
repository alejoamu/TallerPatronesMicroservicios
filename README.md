# Patrones de arquitectura en microservicios

**Integrantes**

- Alejandro Amu  
- Alejandro Torres  
- David Henao  
- Juan Calderon  

Trabajo basado en la guía del taller sobre **Service Discovery (Eureka)** y **Circuit Breaker con Resilience4j**, usando los proyectos tipo *FutureX* (servidor Eureka, servicio de cursos y servicio catálogo).

---

## Qué hace este repo

Hay **tres aplicaciones Spring Boot** que levantan por separado:

| Módulo | Rol | Puerto |
|--------|-----|--------|
| `FutureXEurekaServer` | Registro Eureka (`fx-discovery-server`) | **8761** |
| `FutureXCourseApp` | API de cursos (`fx-course-service`) | **8001** |
| `FutureXCourseCatalog` | Catálogo que descubre al curso por nombre y tolera fallos (`fx-catalog-service`) | **8002** |

El catálogo **no** usa una URL fija del otro microservicio: obtiene la dirección desde Eureka (`fx-course-service`) y llama con `RestTemplate`. Sobre esas llamadas va **Resilience4j** (`@CircuitBreaker`, instancia `courseService`): si el curso no responde, entran los métodos de **fallback** en lugar de tumbar la respuesta al cliente.

La configuración que gobierna el breaker en los endpoints del catálogo está en  
`FutureXCourseCatalog/src/main/resources/application.properties` (`resilience4j.circuitbreaker.instances.courseService.*`).  
Lo opcional del taller (bean `Resilience4JConfig`, Actuator) está también en ese módulo.

---

## Cómo ejecutarlo

### Opción rápida (Windows)

En la raíz del repositorio:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\levantar-servicios.ps1
```

El script abre **tres ventanas** de PowerShell y arranca Eureka → Course → Catalog con una pausa entre cada uno para que el registro no falle al arranque. Para la demo de caída del curso, pueden detener solo la ventana del **Course** con `Ctrl+C`.

### Opción manual

Tres terminales, en este orden. En cada una, entrar a la carpeta y ejecutar:

```text
cd FutureXEurekaServer
.\mvnw.cmd -DskipTests spring-boot:run
```

```text
cd FutureXCourseApp
.\mvnw.cmd -DskipTests spring-boot:run
```

```text
cd FutureXCourseCatalog
.\mvnw.cmd -DskipTests spring-boot:run
```

En **PowerShell** hace falta el prefijo `.\` antes de `mvnw.cmd`. Si tienen `mvn` en el PATH, pueden usar `mvn -DskipTests spring-boot:run` en cada proyecto.

---

## Qué probar en el navegador

| URL | Idea |
|-----|------|
| http://localhost:8761/ | Panel Eureka: deberían listarse los servicios registrados |
| http://localhost:8002/catalog | Catálogo → llama al curso en `/courses` |
| http://localhost:8002/firstcourse | Primer curso vía curso en `/1` |
| http://localhost:8002/actuator/health | (Opcional) Salud + estado del breaker `courseService` |

**Demo de resiliencia:** con todo funcionando, abran `/catalog`. Después detengan solo **FutureXCourseApp** y vuelvan a pedir `/catalog` o `/firstcourse`: deberían aparecer los mensajes de **fallback**.

---

## Más detalle para presentación

En **`GUIA_PRUEBAS_Y_PRESENTACION.md`** está el guion más largo: orden de la demo, qué contar si preguntan por el código y cómo interpretar `/actuator/health`. Este README solo resume comandos y URLs.

---

## Evidencia

Si documentan la práctica con capturas, pueden guardarlas en una carpeta `assets/` y referenciarlas desde el informe o la presentación.
