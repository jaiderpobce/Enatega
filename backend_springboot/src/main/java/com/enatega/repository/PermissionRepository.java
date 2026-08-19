package com.enatega.repository;

import com.enatega.model.PermissionEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface PermissionRepository extends JpaRepository<PermissionEntity, String> {
    Optional<PermissionEntity> findByName(String name);
    boolean existsByName(String name);
}
