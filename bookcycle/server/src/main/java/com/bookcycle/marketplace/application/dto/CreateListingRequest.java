package com.bookcycle.marketplace.application.dto;

import com.bookcycle.marketplace.domain.model.ListingCondition;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import lombok.Data;

@Data
public class CreateListingRequest {
    @NotBlank
    private String title;

    @NotBlank
    private String author;

    @NotBlank
    private String isbn;

    @NotNull
    private ListingCondition condition;

    @NotNull
    private BigDecimal priceAmount;

    @NotBlank
    private String priceCurrency;

    @NotBlank
    private String city;

    @NotBlank
    private String zipCode;

    private String genre;
    private String gradeYearGroup;
    private String fieldOfStudy;
    private String description;

    @NotNull
    private UUID sellerId;

    private List<String> photoUrls;
}
