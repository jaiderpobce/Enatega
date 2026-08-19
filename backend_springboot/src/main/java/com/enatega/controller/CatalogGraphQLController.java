package com.enatega.controller;

import com.enatega.service.CatalogService;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;

import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
public class CatalogGraphQLController {

    private final CatalogService catalogService;

    @QueryMapping
    public List<Map<String, Object>> categories() {
        return catalogService.getCategories();
    }

    @QueryMapping
    public List<Map<String, Object>> foodByCategory(@Argument String category) {
        return catalogService.getFoodByCategory(category);
    }
}
