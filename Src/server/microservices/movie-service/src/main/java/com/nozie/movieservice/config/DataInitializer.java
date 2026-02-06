package com.nozie.movieservice.config;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.nozie.movieservice.common.model.Country;
import com.nozie.movieservice.common.model.Genre;
import com.nozie.movieservice.common.model.Movie;
import com.nozie.movieservice.common.repository.CountryRepository;
import com.nozie.movieservice.common.repository.GenreRepository;
import com.nozie.movieservice.common.repository.MovieRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;

import java.io.InputStream;
import java.util.List;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {

    private final MovieRepository movieRepository;
    private final GenreRepository genreRepository;
    private final CountryRepository countryRepository;
    private final ResourceLoader resourceLoader;

    @Override
    public void run(String... args) throws Exception {
        log.info("🚀 Data Initialization Check...");

        // Use a customized ObjectMapper
        ObjectMapper mapper = new ObjectMapper();
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        mapper.registerModule(new JavaTimeModule());
        mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

        if (genreRepository.count() == 0) {
            log.info("📁 Seeding Genres...");
            seed(mapper, "classpath:data/genres.json", new TypeReference<List<Genre>>() {
            }, genreRepository);
        }

        if (countryRepository.count() == 0) {
            log.info("📁 Seeding Countries...");
            seed(mapper, "classpath:data/countries.json", new TypeReference<List<Country>>() {
            }, countryRepository);
        }

        if (movieRepository.count() == 0) {
            log.info("📁 Seeding Movies...");
            seed(mapper, "classpath:data/movies.json", new TypeReference<List<Movie>>() {
            }, movieRepository);
        }
    }

    private <T> void seed(ObjectMapper mapper, String path, TypeReference<List<T>> type,
            org.springframework.data.mongodb.repository.MongoRepository<T, String> repo) {
        try {
            Resource res = resourceLoader.getResource(path);
            if (res.exists()) {
                try (InputStream is = res.getInputStream()) {
                    List<T> data = mapper.readValue(is, type);
                    repo.saveAll(data);
                    log.info("✅ Imported {} items from {}", data.size(), path);
                }
            } else {
                log.warn("⚠️ Data source not found: {}", path);
            }
        } catch (Exception e) {
            log.error("❌ Failed to seed data from {}: {}", path, e.getMessage());
            e.printStackTrace();
        }
    }
}
