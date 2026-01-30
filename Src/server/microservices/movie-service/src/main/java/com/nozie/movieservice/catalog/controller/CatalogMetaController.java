package com.nozie.movieservice.catalog.controller;

import com.nozie.common.dto.ApiResponse;
import com.nozie.movieservice.catalog.service.CatalogService;
import com.nozie.movieservice.common.model.Country;
import com.nozie.movieservice.common.model.Genre;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Catalog metadata API - Thể loại, quốc gia, năm (dùng cho filter UI).
 */
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CatalogMetaController {

    private final CatalogService catalogService;

    @GetMapping("/genres")
    public ResponseEntity<ApiResponse<List<Genre>>> getGenres() {
        return ResponseEntity.ok(ApiResponse.success(catalogService.getAllGenres()));
    }

    @GetMapping("/countries")
    public ResponseEntity<ApiResponse<List<Country>>> getCountries() {
        return ResponseEntity.ok(ApiResponse.success(catalogService.getAllCountries()));
    }

    @GetMapping("/years")
    public ResponseEntity<ApiResponse<List<Integer>>> getYears() {
        return ResponseEntity.ok(ApiResponse.success(catalogService.getDistinctYears()));
    }
}
