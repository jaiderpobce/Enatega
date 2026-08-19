package com.enatega.controller;

import com.enatega.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;

import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
public class OrderGraphQLController {

    private final OrderService orderService;

    @QueryMapping
    public List<Map<String, Object>> orders() {
        return orderService.getOrders();
    }

    @QueryMapping
    public Map<String, Object> order(@Argument String id) {
        return orderService.getOrderById(id);
    }

    @MutationMapping
    public Map<String, Object> placeOrder(@Argument("amount") Double amount, @Argument("paymentMethod") String paymentMethod) {
        return orderService.placeOrder(amount != null ? amount : 0.0, paymentMethod);
    }
}
