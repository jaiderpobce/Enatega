package com.enatega.controller;

import com.enatega.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;

import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
public class AuthGraphQLController {

    private final AuthService authService;

    @MutationMapping
    public Map<String, Object> login(@Argument String email, @Argument String password) {
        return authService.login(email, password);
    }

    @MutationMapping
    public Map<String, Object> createUser(@Argument("userInput") Map<String, Object> userInput) {
        return authService.createUser(userInput);
    }

    @QueryMapping
    public Map<String, Object> profile() {
        return authService.getProfile();
    }

    @QueryMapping
    public List<Map<String, Object>> roles() {
        return authService.getAllRoles();
    }

    @MutationMapping
    public Map<String, Object> assignRoleToUser(@Argument String userId, @Argument String roleName) {
        return authService.assignRoleToUser(userId, roleName);
    }
}
