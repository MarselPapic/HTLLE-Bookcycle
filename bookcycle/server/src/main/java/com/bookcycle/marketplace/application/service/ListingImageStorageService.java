package com.bookcycle.marketplace.application.service;

import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class ListingImageStorageService {

    private final Path storageDirectory;

    public ListingImageStorageService(
            @Value("${app.uploads.listing-dir:/tmp/bookcycle/uploads/listings}") String storageDir) {
        this.storageDirectory = Paths.get(storageDir).toAbsolutePath().normalize();
    }

    @PostConstruct
    void initializeStorage() {
        try {
            Files.createDirectories(storageDirectory);
        } catch (IOException ex) {
            throw new IllegalStateException("Could not initialize listing image storage directory", ex);
        }
    }

    public StoredImage store(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("Image file is required.");
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.toLowerCase(Locale.ROOT).startsWith("image/")) {
            throw new IllegalArgumentException("Only image uploads are supported.");
        }

        String extension = extractExtension(file.getOriginalFilename());
        String fileName = UUID.randomUUID() + extension;
        Path destination = storageDirectory.resolve(fileName).normalize();

        if (!destination.startsWith(storageDirectory)) {
            throw new IllegalArgumentException("Invalid file destination.");
        }

        try {
            Files.copy(file.getInputStream(), destination, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException ex) {
            throw new IllegalStateException("Could not store uploaded image.", ex);
        }

        return new StoredImage(fileName, resolveMediaType(fileName));
    }

    public Resource loadAsResource(String fileName) {
        String safeFileName = Paths.get(fileName).getFileName().toString();
        Path source = storageDirectory.resolve(safeFileName).normalize();

        if (!source.startsWith(storageDirectory) || !Files.exists(source)) {
            throw new IllegalArgumentException("Image not found: " + safeFileName);
        }

        try {
            return new UrlResource(source.toUri());
        } catch (IOException ex) {
            throw new IllegalStateException("Could not read uploaded image.", ex);
        }
    }

    public MediaType resolveMediaType(String fileName) {
        String safeFileName = Paths.get(fileName).getFileName().toString();
        Path source = storageDirectory.resolve(safeFileName).normalize();
        try {
            String detected = Files.probeContentType(source);
            if (detected != null && !detected.isBlank()) {
                return MediaType.parseMediaType(detected);
            }
        } catch (IOException ignored) {
            // Fallback below.
        }
        return MediaType.APPLICATION_OCTET_STREAM;
    }

    private String extractExtension(String originalFilename) {
        if (originalFilename == null || originalFilename.isBlank()) {
            return ".jpg";
        }
        int idx = originalFilename.lastIndexOf('.');
        if (idx < 0 || idx == originalFilename.length() - 1) {
            return ".jpg";
        }
        String extension = originalFilename.substring(idx).toLowerCase(Locale.ROOT);
        if (extension.length() > 10) {
            return ".jpg";
        }
        return extension;
    }

    public record StoredImage(String fileName, MediaType mediaType) {
    }
}
