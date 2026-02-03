package com.bookcycle.marketplace.domain.model;

import com.bookcycle.shared.domain.model.Isbn;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.Embedded;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import java.util.Objects;

@Embeddable
public class BookItem {
    @Embedded
    @AttributeOverride(name = "value", column = @Column(name = "item_isbn", length = 20, nullable = false))
    private Isbn isbn;

    @Enumerated(EnumType.STRING)
    @Column(name = "item_condition", length = 20, nullable = false)
    private ListingCondition condition;

    @Column(name = "grade_year_group", length = 50)
    private String gradeYearGroup;

    @Column(name = "field_of_study", length = 100)
    private String fieldOfStudy;

    protected BookItem() {
        // JPA
    }

    private BookItem(Isbn isbn, ListingCondition condition, String gradeYearGroup, String fieldOfStudy) {
        this.isbn = Objects.requireNonNull(isbn, "isbn cannot be null");
        this.condition = Objects.requireNonNull(condition, "condition cannot be null");
        this.gradeYearGroup = gradeYearGroup != null ? gradeYearGroup.trim() : null;
        this.fieldOfStudy = fieldOfStudy != null ? fieldOfStudy.trim() : null;
    }

    public static BookItem of(Isbn isbn, ListingCondition condition, String gradeYearGroup, String fieldOfStudy) {
        return new BookItem(isbn, condition, gradeYearGroup, fieldOfStudy);
    }

    public Isbn getIsbn() {
        return isbn;
    }

    public ListingCondition getCondition() {
        return condition;
    }

    public String getGradeYearGroup() {
        return gradeYearGroup;
    }

    public String getFieldOfStudy() {
        return fieldOfStudy;
    }
}
