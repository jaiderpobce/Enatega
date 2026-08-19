package com.enatega.repository;

import com.enatega.model.FoodEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface FoodRepository extends JpaRepository<FoodEntity, String> {
    List<FoodEntity> findByCategoryId(String categoryId);
}
