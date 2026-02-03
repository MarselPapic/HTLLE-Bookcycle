package com.bookcycle.marketplace.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.UUID;

@Entity
@Table(schema = "marketplace", name = "photos")
public class Photo {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "listing_id", nullable = false)
    private Listing listing;

    @Column(name = "url", length = 500, nullable = false)
    private String url;

    @Column(name = "is_thumbnail", nullable = false)
    private boolean thumbnail;

    protected Photo() {
        // JPA
    }

    private Photo(Listing listing, String url, boolean thumbnail) {
        this.listing = listing;
        this.url = url;
        this.thumbnail = thumbnail;
    }

    public static Photo of(Listing listing, String url, boolean thumbnail) {
        return new Photo(listing, url, thumbnail);
    }

    public UUID getId() {
        return id;
    }

    public Listing getListing() {
        return listing;
    }

    public String getUrl() {
        return url;
    }

    public boolean isThumbnail() {
        return thumbnail;
    }

    public void setThumbnail(boolean thumbnail) {
        this.thumbnail = thumbnail;
    }
}
