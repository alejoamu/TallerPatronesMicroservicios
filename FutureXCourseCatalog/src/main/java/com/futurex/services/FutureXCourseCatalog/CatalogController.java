package com.futurex.services.FutureXCourseCatalog;

import com.netflix.appinfo.InstanceInfo;
import com.netflix.discovery.EurekaClient;
import com.netflix.hystrix.contrib.javanica.annotation.HystrixCommand;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
public class CatalogController {

    @Autowired
    private EurekaClient client;

    @RequestMapping("/")
    @HystrixCommand(fallbackMethod = "fallbackGetCatalogHome")
    public String getCatalogHome() {
        String courseAppMesage = "";
        //String courseAppURL = "http://localhost:8080/";
        RestTemplate restTemplate = new RestTemplate();
        InstanceInfo instanceInfo = client.getNextServerFromEureka("fx-course-service",false);
        String courseAppURL = instanceInfo.getHomePageUrl();
        courseAppMesage = restTemplate.getForObject(courseAppURL,String.class);

        return("Welcome to FutureX Course Catalog "+courseAppMesage);
    }

    public String fallbackGetCatalogHome(Throwable ex) {
        return "Welcome to FutureX Course Catalog (fallback: course service unavailable)";
    }

    @RequestMapping("/catalog")
    @HystrixCommand(fallbackMethod = "fallbackGetCatalog")
    public String getCatalog() {
        String courses = "";
        //String courseAppURL = "http://localhost:8080/courses";
        InstanceInfo instanceInfo = client.getNextServerFromEureka("fx-course-service",false);
        String courseAppURL = instanceInfo.getHomePageUrl();
        courseAppURL = courseAppURL+"/courses";
        RestTemplate restTemplate = new RestTemplate();
        courses = restTemplate.getForObject(courseAppURL,String.class);

        return("Our courses are "+courses);
    }

    public String fallbackGetCatalog(Throwable ex) {
        return "Our courses are (fallback: unable to retrieve courses right now)";
    }

    @RequestMapping("/firstcourse")
    @HystrixCommand(fallbackMethod = "fallbackGetSpecificCourse")
    public String getSpecificCourse() {
        Course course = new Course();
        //String courseAppURL = "http://localhost:8080/1";
        InstanceInfo instanceInfo = client.getNextServerFromEureka("fx-course-service",false);
        String courseAppURL = instanceInfo.getHomePageUrl();
        courseAppURL = courseAppURL+"/1";
        RestTemplate restTemplate = new RestTemplate();

        course = restTemplate.getForObject(courseAppURL,Course.class);

        return("Our first course is "+course.getCoursename());
    }

    public String fallbackGetSpecificCourse(Throwable ex) {
        return "Our first course is (fallback: course service unavailable)";
    }

}
