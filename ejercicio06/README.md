# Ejercicio 06

Primero lei un poco sobre los registry que existen para redhat en [https://access.redhat.com/RegistryAuthentication](https://access.redhat.com/RegistryAuthentication).
Por lo visto hay que usar `registry.access.redhat.com` que permite usuarios no autenticados, y no hay que hacer login.

Luego sabiendo la estructura para referenciar una imagen `<registry>/<username>/<image>:<version>` probé pullear la imagen, `latest`:
```bash
$ docker pull registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift
Using default tag: latest
latest: Pulling from redhat-openjdk-18/openjdk18-openshift
71104d043b69: Pull complete 
fde28b70fde8: Pull complete 
27b57fae054d: Pull complete 
Digest: sha256:1c749e31a05a6d025524853de7baa6a0c4fc16e573a99e518ffb12a7226fe28d
Status: Downloaded newer image for registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:latest
registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:latest
```
# Update: correccion

No me quedo muy en claro en la documentacion como utilizarlo, tuve que leer el [Dockerfile](https://catalog.redhat.com/software/containers/redhat-openjdk-18/openjdk18-openshift/58ada5701fbe981673cd6b10?container-tabs=dockerfile) para determinar que habia unos argumentos y variables de entorno que definen que usa los `*.jar` en la carpeta `/deployments` y en la [Informacion tecnica](https://catalog.redhat.com/software/containers/redhat-openjdk-18/openjdk18-openshift/58ada5701fbe981673cd6b10?container-tabs=technical-information&gti-tabs=get-the-source) que expone los puertos 8080, 8443 y 8778.
Por lo tanto hice el fix en el Dockerfile.

## Dockerfile
Para hacer el Dockerfile lo único que cambia respecto al ejercicio4 es el `FROM` ya que vamos a usar la imagen de redhat

## Build
Se buildea el Dockerfile, agregando un nuevo tag para la misma imagen `passwordapi`
```bash
$ docker build -f Dockerfile -t matiaslp28gm/passwordapi:8-openshift .
Sending build context to Docker daemon  25.44MB
Step 1/5 : FROM registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:latest
 ---> 6c139893584a
Step 2/5 : COPY passwordapi.jar /app/
 ---> 181f5273c88d
Step 3/5 : WORKDIR /app
 ---> Running in f9d2c2e1c7f4
Removing intermediate container f9d2c2e1c7f4
 ---> 30c88ce06df6
Step 4/5 : EXPOSE 8080
 ---> Running in 063e071918da
Removing intermediate container 063e071918da
 ---> 7df672131254
Step 5/5 : CMD ["java", "-jar", "passwordapi.jar"]
 ---> Running in cbf768ca52c4
Removing intermediate container cbf768ca52c4
 ---> 34829e27be66
Successfully built 34829e27be66
Successfully tagged matiaslp28gm/passwordapi:8-openshift

Use 'docker scan' to run Snyk tests against images to find vulnerabilities and learn how to fix them
```

## Subir la imagen al repositorio
Como ya esta tageado al momento de build, se sube directamente
```bash
$ docker push matiaslp28gm/passwordapi:8-openshift
The push refers to repository [docker.io/matiaslp28gm/passwordapi]
a0de971e9e1b: Pushed 
cc5403c47292: Pushed 
66f75fbc6cda: Pushed 
b39771317774: Pushed 
8-openshift: digest: sha256:6a87e1fa053c3082763b34a974c89787ea4b1cb9f4a4b2c73bbd12916976ae3e size: 1162
```
Ahora hay un nuevo tag el cual se puede descargar [passwordapi/tags](https://hub.docker.com/r/matiaslp28gm/passwordapi/tags) y el correspondiente a este ejercicio es: [passwordapi:8-openshift](https://hub.docker.com/layers/passwordapi/matiaslp28gm/passwordapi/8-openshift/images/sha256-6a87e1fa053c3082763b34a974c89787ea4b1cb9f4a4b2c73bbd12916976ae3e?context=explore)

## Prueba
Se probo la imagen buildeada local, para ver si funcionaba, funciona OK:
```bash
$ docker run -p 8080:8080 matiaslp28gm/passwordapi:8-openshift

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.0.3.RELEASE)

2022-06-19 23:02:37.332  INFO 1 --- [           main] com.nicopaez.passwordapi.Application     : Starting Application v1.5.0 on cd1039c55542 with PID 1 (/app/passwordapi.jar started by jboss in /app)
2022-06-19 23:02:37.335  INFO 1 --- [           main] com.nicopaez.passwordapi.Application     : No active profile set, falling back to default profiles: default
2022-06-19 23:02:37.388  INFO 1 --- [           main] ConfigServletWebServerApplicationContext : Refreshing org.springframework.boot.web.servlet.context.AnnotationConfigServletWebServerApplicationContext@198e2867: startup date [Sun Jun 19 23:02:37 UTC 2022]; root of context hierarchy
2022-06-19 23:02:38.657  INFO 1 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port(s): 8080 (http)
2022-06-19 23:02:38.681  INFO 1 --- [           main] o.apache.catalina.core.StandardService   : Starting service [Tomcat]
2022-06-19 23:02:38.682  INFO 1 --- [           main] org.apache.catalina.core.StandardEngine  : Starting Servlet Engine: Apache Tomcat/8.5.31
2022-06-19 23:02:38.692  INFO 1 --- [ost-startStop-1] o.a.catalina.core.AprLifecycleListener   : The APR based Apache Tomcat Native library which allows optimal performance in production environments was not found on the java.library.path: [/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib]
2022-06-19 23:02:38.767  INFO 1 --- [ost-startStop-1] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
2022-06-19 23:02:38.767  INFO 1 --- [ost-startStop-1] o.s.web.context.ContextLoader            : Root WebApplicationContext: initialization completed in 1382 ms
2022-06-19 23:02:39.331  INFO 1 --- [ost-startStop-1] o.s.b.w.servlet.ServletRegistrationBean  : Servlet dispatcherServlet mapped to [/]
2022-06-19 23:02:39.334  INFO 1 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean   : Mapping filter: 'characterEncodingFilter' to: [/*]
2022-06-19 23:02:39.335  INFO 1 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean   : Mapping filter: 'hiddenHttpMethodFilter' to: [/*]
2022-06-19 23:02:39.335  INFO 1 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean   : Mapping filter: 'httpPutFormContentFilter' to: [/*]
2022-06-19 23:02:39.335  INFO 1 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean   : Mapping filter: 'requestContextFilter' to: [/*]
2022-06-19 23:02:39.335  INFO 1 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean   : Mapping filter: 'httpTraceFilter' to: [/*]
2022-06-19 23:02:39.335  INFO 1 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean   : Mapping filter: 'webMvcMetricsFilter' to: [/*]
2022-06-19 23:02:39.741  INFO 1 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/password],methods=[GET]}" onto public java.util.Map<java.lang.String, java.lang.Object> com.nicopaez.passwordapi.PasswordController.password()
2022-06-19 23:02:39.742  INFO 1 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/check-match],methods=[GET]}" onto public java.util.Map<java.lang.String, java.lang.Object> com.nicopaez.passwordapi.PasswordController.checkMatch(java.lang.String,java.lang.String)
2022-06-19 23:02:39.743  INFO 1 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/],methods=[GET]}" onto public org.springframework.web.servlet.view.RedirectView com.nicopaez.passwordapi.PasswordController.index()
2022-06-19 23:02:39.743  INFO 1 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/hash],methods=[GET]}" onto public java.util.Map<java.lang.String, java.lang.Object> com.nicopaez.passwordapi.PasswordController.hash(java.lang.String)
2022-06-19 23:02:39.743  INFO 1 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/valid],methods=[GET]}" onto public java.util.Map<java.lang.String, java.lang.Object> com.nicopaez.passwordapi.PasswordController.valid(java.lang.String)
2022-06-19 23:02:39.749  INFO 1 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/swagger-resources/configuration/ui]}" onto public org.springframework.http.ResponseEntity<springfox.documentation.swagger.web.UiConfiguration> springfox.documentation.swagger.web.ApiResourceController.uiConfiguration()
2022-06-19 23:02:39.750  INFO 1 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/swagger-resources/configuration/security]}" onto public org.springframework.http.ResponseEntity<springfox.documentation.swagger.web.SecurityConfiguration> springfox.documentation.swagger.web.ApiResourceController.securityConfiguration()
2022-06-19 23:02:39.751  INFO 1 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/swagger-resources]}" onto public org.springframework.http.ResponseEntity<java.util.List<springfox.documentation.swagger.web.SwaggerResource>> springfox.documentation.swagger.web.ApiResourceController.swaggerResources()
2022-06-19 23:02:39.755  INFO 1 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/error],produces=[text/html]}" onto public org.springframework.web.servlet.ModelAndView org.springframework.boot.autoconfigure.web.servlet.error.BasicErrorController.errorHtml(javax.servlet.http.HttpServletRequest,javax.servlet.http.HttpServletResponse)
2022-06-19 23:02:39.756  INFO 1 --- [           main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/error]}" onto public org.springframework.http.ResponseEntity<java.util.Map<java.lang.String, java.lang.Object>> org.springframework.boot.autoconfigure.web.servlet.error.BasicErrorController.error(javax.servlet.http.HttpServletRequest)
2022-06-19 23:02:39.839  INFO 1 --- [           main] o.s.b.a.e.web.EndpointLinksResolver      : Exposing 2 endpoint(s) beneath base path '/actuator'
2022-06-19 23:02:39.851  INFO 1 --- [           main] s.b.a.e.w.s.WebMvcEndpointHandlerMapping : Mapped "{[/actuator/health],methods=[GET],produces=[application/vnd.spring-boot.actuator.v2+json || application/json]}" onto public java.lang.Object org.springframework.boot.actuate.endpoint.web.servlet.AbstractWebMvcEndpointHandlerMapping$OperationHandler.handle(javax.servlet.http.HttpServletRequest,java.util.Map<java.lang.String, java.lang.String>)
2022-06-19 23:02:39.851  INFO 1 --- [           main] s.b.a.e.w.s.WebMvcEndpointHandlerMapping : Mapped "{[/actuator/info],methods=[GET],produces=[application/vnd.spring-boot.actuator.v2+json || application/json]}" onto public java.lang.Object org.springframework.boot.actuate.endpoint.web.servlet.AbstractWebMvcEndpointHandlerMapping$OperationHandler.handle(javax.servlet.http.HttpServletRequest,java.util.Map<java.lang.String, java.lang.String>)
2022-06-19 23:02:39.852  INFO 1 --- [           main] s.b.a.e.w.s.WebMvcEndpointHandlerMapping : Mapped "{[/actuator],methods=[GET],produces=[application/vnd.spring-boot.actuator.v2+json || application/json]}" onto protected java.util.Map<java.lang.String, java.util.Map<java.lang.String, org.springframework.boot.actuate.endpoint.web.Link>> org.springframework.boot.actuate.endpoint.web.servlet.WebMvcEndpointHandlerMapping.links(javax.servlet.http.HttpServletRequest,javax.servlet.http.HttpServletResponse)
2022-06-19 23:02:39.984  INFO 1 --- [           main] pertySourcedRequestMappingHandlerMapping : Mapped URL path [/v2/api-docs] onto method [public org.springframework.http.ResponseEntity<springfox.documentation.spring.web.json.Json> springfox.documentation.swagger2.web.Swagger2Controller.getDocumentation(java.lang.String,javax.servlet.http.HttpServletRequest)]
2022-06-19 23:02:40.063  INFO 1 --- [           main] o.s.w.s.handler.SimpleUrlHandlerMapping  : Mapped URL path [/**/favicon.ico] onto handler of type [class org.springframework.web.servlet.resource.ResourceHttpRequestHandler]
2022-06-19 23:02:40.185  INFO 1 --- [           main] s.w.s.m.m.a.RequestMappingHandlerAdapter : Looking for @ControllerAdvice: org.springframework.boot.web.servlet.context.AnnotationConfigServletWebServerApplicationContext@198e2867: startup date [Sun Jun 19 23:02:37 UTC 2022]; root of context hierarchy
2022-06-19 23:02:40.262  INFO 1 --- [           main] o.s.w.s.handler.SimpleUrlHandlerMapping  : Mapped URL path [/webjars/**] onto handler of type [class org.springframework.web.servlet.resource.ResourceHttpRequestHandler]
2022-06-19 23:02:40.263  INFO 1 --- [           main] o.s.w.s.handler.SimpleUrlHandlerMapping  : Mapped URL path [/**] onto handler of type [class org.springframework.web.servlet.resource.ResourceHttpRequestHandler]
2022-06-19 23:02:40.481  INFO 1 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Registering beans for JMX exposure on startup
2022-06-19 23:02:40.492  INFO 1 --- [           main] o.s.c.support.DefaultLifecycleProcessor  : Starting beans in phase 2147483647
2022-06-19 23:02:40.492  INFO 1 --- [           main] d.s.w.p.DocumentationPluginsBootstrapper : Context refreshed
2022-06-19 23:02:40.512  INFO 1 --- [           main] d.s.w.p.DocumentationPluginsBootstrapper : Found 1 custom documentation plugin(s)
2022-06-19 23:02:40.554  INFO 1 --- [           main] s.d.s.w.s.ApiListingReferenceScanner     : Scanning for api listing references
2022-06-19 23:02:40.703  INFO 1 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 8080 (http) with context path ''
2022-06-19 23:02:40.708  INFO 1 --- [           main] com.nicopaez.passwordapi.Application     : Started Application in 3.661 seconds (JVM running for 4.012)
Password API is now running
```