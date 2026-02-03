package com.bookcycle.marketplace.application.dto;

import com.bookcycle.marketplace.domain.model.ListingCondition;
import com.bookcycle.marketplace.domain.model.ListingStatus;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ListingResponse {
    private UUID id;
    private String title;
    private String author;
    private String isbn;
    private ListingCondition condition;
    private BigDecimal priceAmount;
    private String priceCurrency;
    private String city;
    private String zipCode;
    private String genre;
    private String gradeYearGroup;
    private String fieldOfStudy;
    private String description;
    private ListingStatus status;
    private String thumbnailUrl;
    private List<String> photoUrls;
    private UUID sellerId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime publishedAt;
}
