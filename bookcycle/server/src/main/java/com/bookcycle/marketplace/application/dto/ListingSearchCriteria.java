package com.bookcycle.marketplace.application.dto;

import com.bookcycle.marketplace.domain.model.ListingCondition;

import java.math.BigDecimal;

public class ListingSearchCriteria {
    private String query;
    private String genre;
    private ListingCondition minCondition;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private String city;
    private String zipCode;
    private String gradeYearGroup;
    private String fieldOfStudy;

    public String getQuery() {
        return query;
    }

    public void setQuery(String query) {
        this.query = query;
    }

    public String getGenre() {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    public ListingCondition getMinCondition() {
        return minCondition;
    }

    public void setMinCondition(ListingCondition minCondition) {
        this.minCondition = minCondition;
    }

    public BigDecimal getMinPrice() {
        return minPrice;
    }

    public void setMinPrice(BigDecimal minPrice) {
        this.minPrice = minPrice;
    }

    public BigDecimal getMaxPrice() {
        return maxPrice;
    }

    public void setMaxPrice(BigDecimal maxPrice) {
        this.maxPrice = maxPrice;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getZipCode() {
        return zipCode;
    }

    public void setZipCode(String zipCode) {
        this.zipCode = zipCode;
    }

    public String getGradeYearGroup() {
        return gradeYearGroup;
    }

    public void setGradeYearGroup(String gradeYearGroup) {
        this.gradeYearGroup = gradeYearGroup;
    }

    public String getFieldOfStudy() {
        return fieldOfStudy;
    }

    public void setFieldOfStudy(String fieldOfStudy) {
        this.fieldOfStudy = fieldOfStudy;
    }
}
