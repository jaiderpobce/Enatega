package com.enatega.config;

import com.enatega.model.CategoryEntity;
import com.enatega.model.FoodEntity;
import com.enatega.model.PermissionEntity;
import com.enatega.model.RoleEntity;
import com.enatega.model.UserEntity;
import com.enatega.repository.CategoryRepository;
import com.enatega.repository.FoodRepository;
import com.enatega.repository.PermissionRepository;
import com.enatega.repository.RoleRepository;
import com.enatega.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.Set;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;
    private final FoodRepository foodRepository;
    private final RoleRepository roleRepository;
    private final PermissionRepository permissionRepository;

    @Override
    public void run(String... args) {
        // 1. Seed Permissions
        PermissionEntity readMenu = createPermissionIfNotFound("READ_MENU", "Permiso para ver el menú y categorías");
        PermissionEntity placeOrder = createPermissionIfNotFound("PLACE_ORDER", "Permiso para realizar pedidos");
        PermissionEntity manageOrders = createPermissionIfNotFound("MANAGE_ORDERS", "Permiso para gestionar pedidos");
        PermissionEntity deliverOrder = createPermissionIfNotFound("DELIVER_ORDER", "Permiso para realizar entregas (Rider)");
        PermissionEntity manageUsers = createPermissionIfNotFound("MANAGE_USERS", "Permiso para administración global de usuarios");

        // 2. Seed Roles
        RoleEntity roleCustomer = createRoleIfNotFound("ROLE_CUSTOMER", "Usuario cliente de la aplicación", Set.of(readMenu, placeOrder));
        RoleEntity roleRider = createRoleIfNotFound("ROLE_RIDER", "Motorizado / Repartidor", Set.of(readMenu, deliverOrder));
        RoleEntity roleVendor = createRoleIfNotFound("ROLE_VENDOR", "Gestor de Restaurante / Tienda", Set.of(readMenu, manageOrders));
        RoleEntity roleAdmin = createRoleIfNotFound("ROLE_ADMIN", "Administrador Global del Sistema", Set.of(readMenu, placeOrder, manageOrders, deliverOrder, manageUsers));

        // 3. Seed Demo and Admin Users
        if (!userRepository.existsByEmail("demo@enatega.com")) {
            UserEntity demoUser = UserEntity.builder()
                    .name("Demo Enatega Admin")
                    .email("demo@enatega.com")
                    .password("123456")
                    .phone("+584120000000")
                    .isActive(true)
                    .roles(new HashSet<>(Set.of(roleAdmin, roleCustomer)))
                    .build();
            userRepository.save(demoUser);
        }

        if (!userRepository.existsByEmail("admin@enatega.com")) {
            UserEntity adminUser = UserEntity.builder()
                    .name("Administrador Sistema")
                    .email("admin@enatega.com")
                    .password("admin123")
                    .phone("+584149999999")
                    .isActive(true)
                    .roles(new HashSet<>(Set.of(roleAdmin, roleCustomer)))
                    .build();
            userRepository.save(adminUser);
        }

        // 4. Seed Categories and Foods
        if (categoryRepository.count() == 0) {
            CategoryEntity pizzas = categoryRepository.save(
                    CategoryEntity.builder().title("Pizzas").description("Deliciosas pizzas artesanales").imgMenu("https://picsum.photos/200/200?pizza").build()
            );

            CategoryEntity burgers = categoryRepository.save(
                    CategoryEntity.builder().title("Hamburguesas").description("Hamburguesas gourmet 100% carne").imgMenu("https://picsum.photos/200/200?burger").build()
            );

            CategoryEntity drinks = categoryRepository.save(
                    CategoryEntity.builder().title("Bebidas").description("Refrescos y jugos naturales").imgMenu("https://picsum.photos/200/200?drink").build()
            );

            foodRepository.save(FoodEntity.builder()
                    .title("Pizza Pepperoni")
                    .description("Queso mozzarella, salsa de tomate y abundante pepperoni premium.")
                    .imgUrl("https://picsum.photos/400/300?pepperoni")
                    .stock(50)
                    .price(12.99)
                    .category(pizzas)
                    .build());

            foodRepository.save(FoodEntity.builder()
                    .title("Hamburguesa Clásica")
                    .description("Carne de res, queso cheddar, lechuga, tomate y salsa especial.")
                    .imgUrl("https://picsum.photos/400/300?burger")
                    .stock(30)
                    .price(9.50)
                    .category(burgers)
                    .build());

            foodRepository.save(FoodEntity.builder()
                    .title("Limonada Natural")
                    .description("Limonada fresca recién exprimida con menta.")
                    .imgUrl("https://picsum.photos/400/300?lemonade")
                    .stock(100)
                    .price(3.00)
                    .category(drinks)
                    .build());
        }
    }

    private PermissionEntity createPermissionIfNotFound(String name, String description) {
        return permissionRepository.findByName(name)
                .orElseGet(() -> permissionRepository.save(
                        PermissionEntity.builder().name(name).description(description).build()
                ));
    }

    private RoleEntity createRoleIfNotFound(String name, String description, Set<PermissionEntity> permissions) {
        return roleRepository.findByName(name)
                .orElseGet(() -> roleRepository.save(
                        RoleEntity.builder().name(name).description(description).permissions(permissions).build()
                ));
    }
}
