package com.bookcycle.marketplace.presentation.rest;

import com.bookcycle.marketplace.application.dto.CreateListingRequest;
import com.bookcycle.marketplace.application.dto.ListingResponse;
import com.bookcycle.marketplace.application.dto.ListingSearchCriteria;
import com.bookcycle.marketplace.application.service.ListingImageStorageService;
import com.bookcycle.marketplace.domain.model.ListingCondition;
import com.bookcycle.marketplace.application.service.ListingApplicationService;
import jakarta.validation.Valid;
import java.time.Duration;
import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

/**
 * User Stories: US-001 Search Listings, US-002 Create & Publish Listing
 */
@RestController
@RequestMapping("/api/v1/listings")
@RequiredArgsConstructor
public class ListingController {
    private final ListingApplicationService listingService;
    private final ListingImageStorageService listingImageStorageService;

    @PostMapping
    public ResponseEntity<ListingResponse> create(@Valid @RequestBody CreateListingRequest request) {
        ListingResponse response = listingService.createListing(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/{id}/publish")
    public ResponseEntity<ListingResponse> publish(@PathVariable UUID id) {
        return ResponseEntity.ok(listingService.publishListing(id));
    }

    @PostMapping("/{id}/close")
    public ResponseEntity<ListingResponse> close(@PathVariable UUID id) {
        return ResponseEntity.ok(listingService.closeListing(id));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ListingResponse> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(listingService.getListing(id));
    }

    @GetMapping("/search")
    public ResponseEntity<Page<ListingResponse>> search(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String genre,
            @RequestParam(required = false) ListingCondition condition,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String zip,
            @RequestParam(required = false) String gradeYearGroup,
            @RequestParam(required = false) String fieldOfStudy,
            @RequestParam(defaultValue = "relevance") String sort,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        ListingSearchCriteria criteria = new ListingSearchCriteria();
        criteria.setQuery(q);
        criteria.setGenre(genre);
        criteria.setMinCondition(condition);
        criteria.setMinPrice(minPrice);
        criteria.setMaxPrice(maxPrice);
        criteria.setCity(city);
        criteria.setZipCode(zip);
        criteria.setGradeYearGroup(gradeYearGroup);
        criteria.setFieldOfStudy(fieldOfStudy);

        Pageable pageable = PageRequest.of(page, size, resolveSort(sort));
        return ResponseEntity.ok(listingService.searchListings(criteria, pageable));
    }

    @PostMapping(value = "/uploads", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, String>> uploadListingImage(
            @RequestParam("file") MultipartFile file) {
        ListingImageStorageService.StoredImage storedImage = listingImageStorageService.store(file);
        String url = ServletUriComponentsBuilder.fromCurrentContextPath()
            .path("/api/v1/listings/uploads/")
            .path(storedImage.fileName())
            .toUriString();

        return ResponseEntity.status(HttpStatus.CREATED)
            .body(Map.of(
                "fileName", storedImage.fileName(),
                "url", url
            ));
    }

    @GetMapping("/uploads/{fileName:.+}")
    public ResponseEntity<Resource> getListingImage(@PathVariable String fileName) {
        Resource resource = listingImageStorageService.loadAsResource(fileName);
        MediaType mediaType = listingImageStorageService.resolveMediaType(fileName);
        return ResponseEntity.ok()
            .contentType(mediaType)
            .cacheControl(CacheControl.maxAge(Duration.ofDays(7)).cachePublic())
            .body(resource);
    }

    private Sort resolveSort(String sort) {
        if (sort == null) {
            return Sort.by(Sort.Direction.DESC, "publishedAt");
        }
        return switch (sort.toLowerCase()) {
            case "price" -> Sort.by(Sort.Direction.ASC, "price.amount");
            case "date" -> Sort.by(Sort.Direction.DESC, "publishedAt");
            default -> Sort.by(Sort.Direction.DESC, "publishedAt");
        };
    }
}
