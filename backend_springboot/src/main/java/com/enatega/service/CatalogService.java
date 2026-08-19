package com.enatega.service;

import com.enatega.model.FoodEntity;
import com.enatega.repository.CategoryRepository;
import com.enatega.repository.FoodRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CatalogService {

    private final CategoryRepository categoryRepository;
    private final FoodRepository foodRepository;

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getCategories() {
        return categoryRepository.findAll().stream().map(cat -> {
            Map<String, Object> map = new HashMap<>();
            map.put("_id", cat.getId());
            map.put("title", cat.getTitle());
            map.put("description", cat.getDescription());
            map.put("img_menu", cat.getImgMenu());
            return map;
        }).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getFoodByCategory(String category) {
        List<FoodEntity> foods = (category != null && !category.isEmpty())
                ? foodRepository.findByCategoryId(category)
                : foodRepository.findAll();

        return foods.stream().map(food -> {
            Map<String, Object> map = new HashMap<>();
            map.put("_id", food.getId());
            map.put("title", food.getTitle());
            map.put("description", food.getDescription());
            map.put("img_url", food.getImgUrl());
            map.put("stock", food.getStock());

            if (food.getCategory() != null) {
                Map<String, Object> catMap = new HashMap<>();
                catMap.put("_id", food.getCategory().getId());
                catMap.put("title", food.getCategory().getTitle());
                map.put("category", catMap);
            }

            return map;
        }).collect(Collectors.toList());
    }
}
