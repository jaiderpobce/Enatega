package com.enatega.service;

import com.enatega.model.OrderEntity;
import com.enatega.model.UserEntity;
import com.enatega.repository.OrderRepository;
import com.enatega.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getOrders() {
        return orderRepository.findAll().stream()
                .sorted((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()))
                .map(this::buildOrderMap)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getOrderById(String id) {
        OrderEntity order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pedido no encontrado con ID: " + id));
        return buildOrderMap(order);
    }

    @Transactional
    public Map<String, Object> placeOrder(double orderAmount, String paymentMethod, String bankName, String paymentReference, String paymentProofUrl) {
        UserEntity user = userRepository.findAll().stream().findFirst()
                .orElseThrow(() -> new RuntimeException("Usuario no autenticado para realizar pedido."));

        String orderId = "ORD-" + (100000 + new Random().nextInt(900000));

        OrderEntity newOrder = OrderEntity.builder()
                .orderId(orderId)
                .deliveryCharges(2.50)
                .paymentStatus("PAID")
                .paymentMethod(paymentMethod != null ? paymentMethod : "CASH")
                .bankName(bankName)
                .paymentReference(paymentReference)
                .paymentProofUrl(paymentProofUrl)
                .orderAmount(orderAmount)
                .paidAmount(orderAmount + 2.50)
                .orderStatus("PENDING")
                .user(user)
                .build();

        OrderEntity saved = orderRepository.save(newOrder);
        return buildOrderMap(saved);
    }

    @Transactional
    public Map<String, Object> updateOrderStatus(String id, String status) {
        OrderEntity order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pedido no encontrado con ID: " + id));

        order.setOrderStatus(status);
        OrderEntity updated = orderRepository.save(order);
        return buildOrderMap(updated);
    }

    private Map<String, Object> buildOrderMap(OrderEntity order) {
        Map<String, Object> map = new HashMap<>();
        map.put("_id", order.getId());
        map.put("order_id", order.getOrderId());
        map.put("delivery_charges", order.getDeliveryCharges());
        map.put("payment_status", order.getPaymentStatus());
        map.put("payment_method", order.getPaymentMethod());
        map.put("bank_name", order.getBankName());
        map.put("payment_reference", order.getPaymentReference());
        map.put("payment_proof_url", order.getPaymentProofUrl());
        map.put("order_amount", order.getOrderAmount());
        map.put("paid_amount", order.getPaidAmount());
        map.put("order_status", order.getOrderStatus());
        map.put("createdAt", order.getCreatedAt() != null ? order.getCreatedAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME) : "");
        map.put("items", Collections.emptyList());
        return map;
    }
}
