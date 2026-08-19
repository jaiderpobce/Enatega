package com.enatega.service;

import com.enatega.model.RoleEntity;
import com.enatega.model.UserEntity;
import com.enatega.repository.RoleRepository;
import com.enatega.repository.UserRepository;
import com.enatega.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final JwtService jwtService;

    @Transactional(readOnly = true)
    public Map<String, Object> login(String email, String password) {
        if (email == null || password == null) {
            throw new IllegalArgumentException("Correo y contraseña son requeridos.");
        }

        UserEntity user = userRepository.findByEmail(email.trim().toLowerCase())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con el correo especificado."));

        if (!password.equals(user.getPassword())) {
            throw new RuntimeException("Contraseña incorrecta.");
        }

        List<String> roleNames = user.getRoles().stream()
                .map(RoleEntity::getName)
                .collect(Collectors.toList());

        String token = jwtService.generateToken(user.getId(), user.getEmail(), roleNames);

        Map<String, Object> response = buildUserMap(user);
        response.put("token", token);
        response.put("tokenExpiration", 86400);

        return response;
    }

    @Transactional
    public Map<String, Object> createUser(Map<String, Object> userInput) {
        String email = (String) userInput.get("email");
        String password = (String) userInput.get("password");
        String name = (String) userInput.get("name");
        String phone = (String) userInput.get("phone");

        if (userRepository.existsByEmail(email)) {
            throw new RuntimeException("El correo ya se encuentra registrado.");
        }

        RoleEntity defaultRole = roleRepository.findByName("ROLE_CUSTOMER")
                .orElseThrow(() -> new RuntimeException("Rol ROLE_CUSTOMER no configurado."));

        UserEntity newUser = UserEntity.builder()
                .email(email)
                .password(password)
                .name(name)
                .phone(phone)
                .isActive(true)
                .roles(new HashSet<>(Set.of(defaultRole)))
                .build();

        UserEntity saved = userRepository.save(newUser);
        List<String> roleNames = List.of(defaultRole.getName());
        String token = jwtService.generateToken(saved.getId(), saved.getEmail(), roleNames);

        Map<String, Object> response = buildUserMap(saved);
        response.put("token", token);

        return response;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getProfile() {
        UserEntity user = userRepository.findAll().stream().findFirst()
                .orElseThrow(() -> new RuntimeException("Perfil no disponible."));

        return buildUserMap(user);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllRoles() {
        return roleRepository.findAll().stream().map(role -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", role.getId());
            map.put("name", role.getName());
            map.put("description", role.getDescription());

            List<Map<String, Object>> perms = role.getPermissions().stream().map(p -> {
                Map<String, Object> pMap = new HashMap<>();
                pMap.put("id", p.getId());
                pMap.put("name", p.getName());
                pMap.put("description", p.getDescription());
                return pMap;
            }).collect(Collectors.toList());

            map.put("permissions", perms);
            return map;
        }).collect(Collectors.toList());
    }

    @Transactional
    public Map<String, Object> assignRoleToUser(String userId, String roleName) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con ID: " + userId));

        RoleEntity role = roleRepository.findByName(roleName)
                .orElseThrow(() -> new RuntimeException("Rol no encontrado: " + roleName));

        user.getRoles().add(role);
        UserEntity updated = userRepository.save(user);

        return buildUserMap(updated);
    }

    public Map<String, Object> buildUserMap(UserEntity user) {
        Map<String, Object> map = new HashMap<>();
        map.put("_id", user.getId());
        map.put("userId", user.getId());
        map.put("name", user.getName());
        map.put("email", user.getEmail());
        map.put("phone", user.getPhone());
        map.put("is_active", user.getIsActive() != null ? user.getIsActive() : true);
        map.put("notificationToken", user.getNotificationToken());
        map.put("is_order_notification", user.getIsOrderNotification() != null ? user.getIsOrderNotification() : true);
        map.put("is_offer_notification", user.getIsOfferNotification() != null ? user.getIsOfferNotification() : true);
        map.put("addresses", Collections.emptyList());

        List<Map<String, Object>> rolesList = user.getRoles().stream().map(role -> {
            Map<String, Object> rMap = new HashMap<>();
            rMap.put("id", role.getId());
            rMap.put("name", role.getName());
            rMap.put("description", role.getDescription());
            return rMap;
        }).collect(Collectors.toList());

        map.put("roles", rolesList);

        return map;
    }
}
