package com.enatega.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "addresses")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AddressEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String label;
    
    @Column(columnDefinition = "TEXT")
    private String deliveryAddress;
    
    private String details;
    private Double longitude;
    private Double latitude;
    private Boolean selected;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private UserEntity user;
}
