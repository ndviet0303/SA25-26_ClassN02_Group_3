package com.nozie.movieservice.config;

import com.nozie.movieservice.model.Movie;
import com.nozie.movieservice.repository.MovieRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

/**
 * Data Initializer - Creates sample data on application startup.
 * Used for development and testing purposes.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {

    private final MovieRepository movieRepository;

    @Override
    public void run(String... args) throws Exception {
        log.info("Initializing sample movie data...");

        // Create sample movies
        movieRepository.save(Movie.builder()
                .name("Avengers: Endgame")
                .originName("Avengers: Endgame")
                .slug("avengers-endgame")
                .content("After the devastating events of Avengers: Infinity War, the universe is in ruins.")
                .type("movie")
                .status("completed")
                .quality("4K")
                .lang("Vietsub")
                .year(2019)
                .view(1500000L)
                .time("181 phút")
                .price(BigDecimal.valueOf(4.99))
                .isFree(false)
                .tmdbRating(8.4)
                .imdbRating(8.4)
                .posterUrl("https://image.tmdb.org/t/p/w500/ulzhLuWrPK07P1YkdWQLZnQh1JL.jpg")
                .build());

        movieRepository.save(Movie.builder()
                .name("Spider-Man: No Way Home")
                .originName("Spider-Man: No Way Home")
                .slug("spider-man-no-way-home")
                .content("Peter Parker's secret identity is revealed to the entire world.")
                .type("movie")
                .status("completed")
                .quality("FHD")
                .lang("Vietsub")
                .year(2021)
                .view(2000000L)
                .time("148 phút")
                .price(BigDecimal.ZERO)
                .isFree(true)
                .tmdbRating(8.2)
                .imdbRating(8.3)
                .posterUrl("https://image.tmdb.org/t/p/w500/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg")
                .build());

        movieRepository.save(Movie.builder()
                .name("One Piece")
                .originName("One Piece")
                .slug("one-piece")
                .content("Monkey D. Luffy sets off on an adventure with his pirate crew.")
                .type("series")
                .status("ongoing")
                .quality("HD")
                .lang("Vietsub")
                .year(1999)
                .view(5000000L)
                .episodeCurrent("1100")
                .episodeTotal("~")
                .price(BigDecimal.ZERO)
                .isFree(true)
                .tmdbRating(8.7)
                .imdbRating(8.9)
                .posterUrl("https://image.tmdb.org/t/p/w500/e3NBGiAifW9Xt8xD5tpARskjccO.jpg")
                .build());

        movieRepository.save(Movie.builder()
                .name("Demon Slayer")
                .originName("Kimetsu no Yaiba")
                .slug("demon-slayer")
                .content("A young boy becomes a demon slayer after his family is slaughtered.")
                .type("hoathinh")
                .status("ongoing")
                .quality("4K")
                .lang("Vietsub")
                .year(2019)
                .view(3500000L)
                .episodeCurrent("55")
                .episodeTotal("~")
                .price(BigDecimal.valueOf(2.99))
                .isFree(false)
                .tmdbRating(8.6)
                .imdbRating(8.6)
                .posterUrl("https://image.tmdb.org/t/p/w500/xUfRZu2mi8jH6SzQEJGP6osKFuq.jpg")
                .build());

        movieRepository.save(Movie.builder()
                .name("The Batman")
                .originName("The Batman")
                .slug("the-batman")
                .content("When a sadistic serial killer begins murdering key political figures in Gotham.")
                .type("movie")
                .status("completed")
                .quality("4K")
                .lang("Thuyetminh")
                .year(2022)
                .view(1800000L)
                .time("176 phút")
                .price(BigDecimal.valueOf(3.99))
                .isFree(false)
                .tmdbRating(7.7)
                .imdbRating(7.8)
                .posterUrl("https://image.tmdb.org/t/p/w500/74xTEgt7R36Fvdl3cGaXXd9VqCn.jpg")
                .build());

        log.info("✅ Sample data initialized: {} movies", movieRepository.count());
    }
}

