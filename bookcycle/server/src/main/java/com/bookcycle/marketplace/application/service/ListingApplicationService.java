package com.bookcycle.marketplace.application.service;

import com.bookcycle.marketplace.application.dto.CreateListingRequest;
import com.bookcycle.marketplace.application.dto.ListingResponse;
import com.bookcycle.marketplace.application.dto.ListingSearchCriteria;
import com.bookcycle.marketplace.application.dto.UpdateListingRequest;
import com.bookcycle.marketplace.domain.model.BookItem;
import com.bookcycle.marketplace.domain.model.Listing;
import com.bookcycle.marketplace.domain.service.ListingService;
import com.bookcycle.shared.domain.model.Isbn;
import com.bookcycle.shared.domain.model.Location;
import com.bookcycle.shared.domain.model.Money;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ListingApplicationService {
    private final ListingService listingService;

    @Transactional
    public ListingResponse createListing(CreateListingRequest request) {
        BookItem bookItem = BookItem.of(
            Isbn.of(request.getIsbn()),
            request.getCondition(),
            request.getGradeYearGroup(),
            request.getFieldOfStudy()
        );

        Listing listing = Listing.draft(
            request.getTitle(),
            request.getAuthor(),
            request.getDescription(),
            request.getGenre(),
            bookItem,
            Money.of(request.getPriceAmount(), request.getPriceCurrency()),
            Location.of(request.getCity(), request.getZipCode()),
            request.getSellerId()
        );

        if (request.getPhotoUrls() != null) {
            request.getPhotoUrls().forEach(listing::addPhoto);
        }

        Listing saved = listingService.save(listing);
        return toResponse(saved);
    }

    @Transactional
    public ListingResponse updateListing(java.util.UUID listingId, UpdateListingRequest request) {
        Listing listing = listingService.getListing(listingId);
        if (!listing.getSellerId().equals(request.getSellerId())) {
            throw new IllegalArgumentException("Only the listing owner can edit this listing.");
        }

        BookItem bookItem = BookItem.of(
            Isbn.of(request.getIsbn()),
            request.getCondition(),
            request.getGradeYearGroup(),
            request.getFieldOfStudy()
        );

        listing.updateDetails(
            request.getTitle(),
            request.getAuthor(),
            request.getDescription(),
            request.getGenre(),
            bookItem,
            Money.of(request.getPriceAmount(), request.getPriceCurrency()),
            Location.of(request.getCity(), request.getZipCode())
        );

        if (request.getPhotoUrls() != null) {
            listing.replacePhotos(request.getPhotoUrls());
        }

        Listing saved = listingService.save(listing);
        return toResponse(saved);
    }

    @Transactional
    public ListingResponse publishListing(java.util.UUID listingId) {
        return toResponse(listingService.publish(listingId));
    }

    @Transactional
    public ListingResponse closeListing(java.util.UUID listingId) {
        return toResponse(listingService.close(listingId));
    }

    @Transactional(readOnly = true)
    public ListingResponse getListing(java.util.UUID listingId) {
        return toResponse(listingService.getListing(listingId));
    }

    @Transactional(readOnly = true)
    public Page<ListingResponse> searchListings(ListingSearchCriteria criteria, Pageable pageable) {
        return listingService.search(criteria, pageable).map(this::toResponse);
    }

    @Transactional(readOnly = true)
    public Page<ListingResponse> findListingsBySeller(java.util.UUID sellerId, Pageable pageable) {
        return listingService.findBySellerId(sellerId, pageable).map(this::toResponse);
    }

    @Transactional
    public void deleteListing(java.util.UUID listingId, java.util.UUID sellerId) {
        Listing listing = listingService.getListing(listingId);
        if (!listing.getSellerId().equals(sellerId)) {
            throw new IllegalArgumentException("Only the listing owner can delete this listing.");
        }
        listingService.delete(listingId);
    }

    private ListingResponse toResponse(Listing listing) {
        List<String> photoUrls = listing.getPhotos().stream()
            .map(photo -> photo.getUrl())
            .collect(Collectors.toList());

        return ListingResponse.builder()
            .id(listing.getId())
            .title(listing.getTitle())
            .author(listing.getAuthor())
            .isbn(listing.getBookItem().getIsbn().getValue())
            .condition(listing.getBookItem().getCondition())
            .priceAmount(listing.getPrice().getAmount())
            .priceCurrency(listing.getPrice().getCurrency())
            .city(listing.getLocation().getCity())
            .zipCode(listing.getLocation().getZipCode())
            .genre(listing.getGenre())
            .gradeYearGroup(listing.getBookItem().getGradeYearGroup())
            .fieldOfStudy(listing.getBookItem().getFieldOfStudy())
            .description(listing.getDescription())
            .status(listing.getStatus())
            .thumbnailUrl(listing.getThumbnailUrl())
            .photoUrls(photoUrls)
            .sellerId(listing.getSellerId())
            .createdAt(listing.getCreatedAt())
            .updatedAt(listing.getUpdatedAt())
            .publishedAt(listing.getPublishedAt())
            .build();
    }
}
