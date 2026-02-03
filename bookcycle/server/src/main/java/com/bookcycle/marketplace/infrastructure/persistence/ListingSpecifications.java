package com.bookcycle.marketplace.infrastructure.persistence;

import com.bookcycle.marketplace.application.dto.ListingSearchCriteria;
import com.bookcycle.marketplace.domain.model.Listing;
import com.bookcycle.marketplace.domain.model.ListingCondition;
import com.bookcycle.marketplace.domain.model.ListingStatus;
import org.springframework.data.jpa.domain.Specification;

import jakarta.persistence.criteria.Predicate;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;
import java.util.Locale;

public final class ListingSpecifications {
    private ListingSpecifications() {
    }

    public static Specification<Listing> withCriteria(ListingSearchCriteria criteria) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            predicates.add(cb.equal(root.get("status"), ListingStatus.PUBLISHED));

            if (criteria != null) {
                if (hasText(criteria.getQuery())) {
                    String like = "%" + criteria.getQuery().toLowerCase(Locale.ROOT) + "%";
                    Predicate titleMatch = cb.like(cb.lower(root.get("title")), like);
                    Predicate authorMatch = cb.like(cb.lower(root.get("author")), like);
                    Predicate isbnMatch = cb.equal(cb.lower(root.get("bookItem").get("isbn").get("value")),
                        criteria.getQuery().toLowerCase(Locale.ROOT));
                    predicates.add(cb.or(titleMatch, authorMatch, isbnMatch));
                }

                if (hasText(criteria.getGenre())) {
                    predicates.add(cb.equal(cb.lower(root.get("genre")), criteria.getGenre().toLowerCase(Locale.ROOT)));
                }

                if (criteria.getMinCondition() != null) {
                    predicates.add(root.get("bookItem").get("condition").in(conditionsAtLeast(criteria.getMinCondition())));
                }

                if (criteria.getMinPrice() != null) {
                    predicates.add(cb.greaterThanOrEqualTo(root.get("price").get("amount"), criteria.getMinPrice()));
                }

                if (criteria.getMaxPrice() != null) {
                    predicates.add(cb.lessThanOrEqualTo(root.get("price").get("amount"), criteria.getMaxPrice()));
                }

                if (hasText(criteria.getCity())) {
                    predicates.add(cb.equal(cb.lower(root.get("location").get("city")), criteria.getCity().toLowerCase(Locale.ROOT)));
                }

                if (hasText(criteria.getZipCode())) {
                    predicates.add(cb.equal(root.get("location").get("zipCode"), criteria.getZipCode()));
                }

                if (hasText(criteria.getGradeYearGroup())) {
                    predicates.add(cb.equal(cb.lower(root.get("bookItem").get("gradeYearGroup")), criteria.getGradeYearGroup().toLowerCase(Locale.ROOT)));
                }

                if (hasText(criteria.getFieldOfStudy())) {
                    predicates.add(cb.equal(cb.lower(root.get("bookItem").get("fieldOfStudy")), criteria.getFieldOfStudy().toLowerCase(Locale.ROOT)));
                }
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }

    private static EnumSet<ListingCondition> conditionsAtLeast(ListingCondition min) {
        EnumSet<ListingCondition> set = EnumSet.noneOf(ListingCondition.class);
        for (ListingCondition condition : ListingCondition.values()) {
            if (condition.ordinal() <= min.ordinal()) {
                set.add(condition);
            }
        }
        return set;
    }

    private static boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
