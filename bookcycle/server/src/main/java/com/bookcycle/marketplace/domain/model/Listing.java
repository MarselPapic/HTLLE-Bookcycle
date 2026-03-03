package com.bookcycle.marketplace.domain.model;

import com.bookcycle.shared.domain.model.Location;
import com.bookcycle.shared.domain.model.Money;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Embedded;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.AttributeOverrides;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

@Entity
@Table(schema = "marketplace", name = "listings")
public class Listing {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "title", length = 200, nullable = false)
    private String title;

    @Column(name = "author", length = 200, nullable = false)
    private String author;

    @Column(name = "description", length = 2000)
    private String description;

    @Column(name = "genre", length = 100)
    private String genre;

    @Embedded
    private BookItem bookItem;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "amount", column = @Column(name = "price_amount", precision = 12, scale = 2, nullable = false)),
        @AttributeOverride(name = "currency", column = @Column(name = "price_currency", length = 3, nullable = false))
    })
    private Money price;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "city", column = @Column(name = "location_city", length = 100, nullable = false)),
        @AttributeOverride(name = "zipCode", column = @Column(name = "location_zip", length = 20, nullable = false))
    })
    private Location location;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", length = 20, nullable = false)
    private ListingStatus status;

    @Column(name = "seller_id", nullable = false)
    private UUID sellerId;

    @Column(name = "thumbnail_url", length = 500)
    private String thumbnailUrl;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @Column(name = "published_at")
    private LocalDateTime publishedAt;

    @OneToMany(mappedBy = "listing", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<Photo> photos = new ArrayList<>();

    protected Listing() {
        // JPA
    }

    private Listing(String title, String author, String description, String genre,
                    BookItem bookItem, Money price, Location location, UUID sellerId) {
        this.title = requireText(title, "title");
        this.author = requireText(author, "author");
        this.description = description != null ? description.trim() : null;
        this.genre = genre != null ? genre.trim() : null;
        this.bookItem = Objects.requireNonNull(bookItem, "bookItem cannot be null");
        this.price = Objects.requireNonNull(price, "price cannot be null");
        this.location = Objects.requireNonNull(location, "location cannot be null");
        this.status = ListingStatus.DRAFT;
        this.sellerId = Objects.requireNonNull(sellerId, "sellerId cannot be null");
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public static Listing draft(String title, String author, String description, String genre,
                                BookItem bookItem, Money price, Location location, UUID sellerId) {
        return new Listing(title, author, description, genre, bookItem, price, location, sellerId);
    }

    public void publish() {
        if (status != ListingStatus.DRAFT && status != ListingStatus.CLOSED) {
            throw new IllegalStateException("Only draft or closed listings can be published");
        }
        validatePublishable();
        status = ListingStatus.PUBLISHED;
        publishedAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    public void reserve() {
        if (status != ListingStatus.PUBLISHED) {
            throw new IllegalStateException("Only published listings can be reserved");
        }
        status = ListingStatus.RESERVED;
        updatedAt = LocalDateTime.now();
    }

    public void unreserve() {
        if (status != ListingStatus.RESERVED) {
            throw new IllegalStateException("Only reserved listings can be reopened");
        }
        status = ListingStatus.PUBLISHED;
        updatedAt = LocalDateTime.now();
    }

    public void markSold() {
        if (status != ListingStatus.RESERVED && status != ListingStatus.PUBLISHED) {
            throw new IllegalStateException("Listing must be reserved or published to mark sold");
        }
        status = ListingStatus.SOLD;
        updatedAt = LocalDateTime.now();
    }

    public void close() {
        if (status == ListingStatus.SOLD) {
            throw new IllegalStateException("Sold listings cannot be closed");
        }
        status = ListingStatus.CLOSED;
        updatedAt = LocalDateTime.now();
    }

    public void hide() {
        status = ListingStatus.HIDDEN;
        updatedAt = LocalDateTime.now();
    }

    public void addPhoto(String url) {
        boolean makeThumbnail = photos.isEmpty();
        Photo photo = Photo.of(this, url, makeThumbnail);
        photos.add(photo);
        if (makeThumbnail) {
            thumbnailUrl = url;
        }
    }

    public void replacePhotos(List<String> urls) {
        photos.clear();
        thumbnailUrl = null;
        if (urls == null) {
            updatedAt = LocalDateTime.now();
            return;
        }
        urls.stream()
            .filter(Objects::nonNull)
            .map(String::trim)
            .filter(url -> !url.isEmpty())
            .forEach(this::addPhoto);
        updatedAt = LocalDateTime.now();
    }

    public void updateDetails(String title, String author, String description, String genre,
                              BookItem bookItem, Money price, Location location) {
        if (status == ListingStatus.SOLD) {
            throw new IllegalStateException("Sold listings cannot be edited");
        }
        this.title = requireText(title, "title");
        this.author = requireText(author, "author");
        this.description = description != null ? description.trim() : null;
        this.genre = genre != null ? genre.trim() : null;
        this.bookItem = Objects.requireNonNull(bookItem, "bookItem cannot be null");
        this.price = Objects.requireNonNull(price, "price cannot be null");
        this.location = Objects.requireNonNull(location, "location cannot be null");
        this.updatedAt = LocalDateTime.now();
    }

    public void refreshThumbnail() {
        Photo thumbnail = photos.stream().filter(Photo::isThumbnail).findFirst().orElse(null);
        if (thumbnail != null) {
            thumbnailUrl = thumbnail.getUrl();
        }
    }

    private void validatePublishable() {
        if (title == null || title.isBlank()) {
            throw new IllegalStateException("title is required");
        }
        if (author == null || author.isBlank()) {
            throw new IllegalStateException("author is required");
        }
        if (price == null) {
            throw new IllegalStateException("price is required");
        }
        if (location == null) {
            throw new IllegalStateException("location is required");
        }
        if (photos.isEmpty()) {
            throw new IllegalStateException("at least one photo is required");
        }
    }

    private static String requireText(String value, String field) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(field + " cannot be empty");
        }
        return value.trim();
    }

    public UUID getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getAuthor() {
        return author;
    }

    public String getDescription() {
        return description;
    }

    public String getGenre() {
        return genre;
    }

    public BookItem getBookItem() {
        return bookItem;
    }

    public Money getPrice() {
        return price;
    }

    public Location getLocation() {
        return location;
    }

    public ListingStatus getStatus() {
        return status;
    }

    public UUID getSellerId() {
        return sellerId;
    }

    public String getThumbnailUrl() {
        return thumbnailUrl;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public LocalDateTime getPublishedAt() {
        return publishedAt;
    }

    public List<Photo> getPhotos() {
        return photos;
    }
}
