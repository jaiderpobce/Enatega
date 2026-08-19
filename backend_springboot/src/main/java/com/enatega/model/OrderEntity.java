package com.enatega.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "orders")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(name = "order_id", unique = true, nullable = false)
    private String orderId;

    @Column(name = "delivery_charges")
    private Double deliveryCharges;

    @Column(name = "payment_status")
    private String paymentStatus;

    @Column(name = "payment_method")
    private String paymentMethod;

    @Column(name = "bank_name")
    private String bankName;

    @Column(name = "payment_reference")
    private String paymentReference;

    @Column(name = "payment_proof_url", length = 1000)
    private String paymentProofUrl;

    @Column(name = "delivery_address", length = 1000)
    private String deliveryAddress;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "longitude")
    private Double longitude;

    @Column(name = "order_amount")
    private Double orderAmount;

    @Column(name = "paid_amount")
    private Double paidAmount;

    @Column(name = "order_status")
    private String orderStatus;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private UserEntity user;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (orderStatus == null) {
            orderStatus = "PENDING";
        }
    }
}
