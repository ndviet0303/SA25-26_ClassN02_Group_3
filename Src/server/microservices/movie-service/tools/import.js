/**
 * OPhim Import Tool
 * Tool import data từ OPhim API vào MongoDB
 * Dùng 1 lần cho initial data, xong có thể xóa
 * 
 * Usage:
 *   node import.js --all           # Import tất cả (genres, countries, movies)
 *   node import.js --genres        # Chỉ import genres
 *   node import.js --countries     # Chỉ import countries
 *   node import.js --movies        # Chỉ import movies
 *   node import.js --movies --pages 5   # Import 5 trang movies
 *   node import.js --slug ke-danh-cap-giac-mo  # Import 1 phim cụ thể
 */

import { MongoClient } from 'mongodb';

// ==================== CONFIG ====================
const OPHIM_BASE_URL = 'https://ophim1.com/v1/api';
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017';
const DB_NAME = 'moviedb';
const CDN_IMAGE = 'https://img.ophim.live';

// Rate limiting
const DELAY_BETWEEN_REQUESTS = 500; // ms
const DELAY_BETWEEN_PAGES = 1000; // ms

// ==================== HELPERS ====================
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

async function fetchJson(url) {
    console.log(`  -> Fetching: ${url}`);
    const response = await fetch(url);
    if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${url}`);
    }
    return response.json();
}

function buildFullImageUrl(relativePath) {
    if (!relativePath) return null;
    if (relativePath.startsWith('http')) return relativePath;
    return `${CDN_IMAGE}/uploads/movies/${relativePath}`;
}

// ==================== IMPORTERS ====================

/**
 * Import danh sách thể loại
 */
async function importGenres(db) {
    console.log('\n========== IMPORTING GENRES ==========');
    
    const data = await fetchJson(`${OPHIM_BASE_URL}/the-loai`);
    
    if (data.status !== 'success' || !data.data?.items) {
        console.error('Failed to fetch genres');
        return { imported: 0, errors: 1 };
    }

    const genres = data.data.items.map(item => ({
        _id: item._id,
        name: item.name,
        slug: item.slug,
        source: 'OPHIM',
        importedAt: new Date()
    }));

    const collection = db.collection('genres');
    
    let imported = 0;
    for (const genre of genres) {
        await collection.updateOne(
            { slug: genre.slug },
            { $set: genre },
            { upsert: true }
        );
        imported++;
    }

    console.log(`✓ Imported ${imported} genres`);
    return { imported, errors: 0 };
}

/**
 * Import danh sách quốc gia
 */
async function importCountries(db) {
    console.log('\n========== IMPORTING COUNTRIES ==========');
    
    const data = await fetchJson(`${OPHIM_BASE_URL}/quoc-gia`);
    
    if (data.status !== 'success' || !data.data?.items) {
        console.error('Failed to fetch countries');
        return { imported: 0, errors: 1 };
    }

    const countries = data.data.items.map(item => ({
        _id: item._id,
        name: item.name,
        slug: item.slug,
        source: 'OPHIM',
        importedAt: new Date()
    }));

    const collection = db.collection('countries');
    
    let imported = 0;
    for (const country of countries) {
        await collection.updateOne(
            { slug: country.slug },
            { $set: country },
            { upsert: true }
        );
        imported++;
    }

    console.log(`✓ Imported ${imported} countries`);
    return { imported, errors: 0 };
}

/**
 * Map OPhim movie data to our schema
 */
function mapMovieFromOPhim(ophimMovie, isDetailView = false) {
    const movie = {
        externalId: ophimMovie._id,
        name: ophimMovie.name,
        slug: ophimMovie.slug,
        originName: ophimMovie.origin_name,
        type: ophimMovie.type, // single, series, hoathinh
        thumbUrl: buildFullImageUrl(ophimMovie.thumb_url),
        posterUrl: buildFullImageUrl(ophimMovie.poster_url),
        year: ophimMovie.year,
        quality: ophimMovie.quality,
        lang: ophimMovie.lang,
        langKey: ophimMovie.lang_key || [],
        time: ophimMovie.time,
        episodeCurrent: ophimMovie.episode_current,
        episodeTotal: ophimMovie.episode_total,
        subDocquyen: ophimMovie.sub_docquyen || false,
        chieuRap: ophimMovie.chieurap || false,
        
        // Categories & Countries as embedded refs
        category: (ophimMovie.category || []).map(c => ({
            id: c.id,
            name: c.name,
            slug: c.slug
        })),
        country: (ophimMovie.country || []).map(c => ({
            id: c.id,
            name: c.name,
            slug: c.slug
        })),
        
        // TMDB & IMDB info
        tmdb: ophimMovie.tmdb ? {
            type: ophimMovie.tmdb.type,
            id: ophimMovie.tmdb.id,
            season: ophimMovie.tmdb.season,
            voteAverage: ophimMovie.tmdb.vote_average,
            voteCount: ophimMovie.tmdb.vote_count
        } : null,
        imdb: ophimMovie.imdb ? {
            id: ophimMovie.imdb.id,
            voteAverage: ophimMovie.imdb.vote_average,
            voteCount: ophimMovie.imdb.vote_count
        } : null,
        
        // Metadata
        source: 'OPHIM',
        accessType: 'FREE',
        importedAt: new Date(),
        modifiedAt: ophimMovie.modified?.time ? new Date(ophimMovie.modified.time) : new Date()
    };

    // Detail view has more fields
    if (isDetailView) {
        movie.content = ophimMovie.content;
        movie.status = ophimMovie.status;
        movie.trailerUrl = ophimMovie.trailer_url;
        movie.actor = ophimMovie.actor || [];
        movie.director = ophimMovie.director || [];
        movie.alternativeNames = ophimMovie.alternative_names || [];
        movie.view = ophimMovie.view;
        movie.isCopyright = ophimMovie.is_copyright || false;
        movie.notify = ophimMovie.notify;
        movie.showtimes = ophimMovie.showtimes;
        
        // Episodes with link_embed and link_m3u8
        movie.episodes = (ophimMovie.episodes || []).map(ep => ({
            serverName: ep.server_name,
            isAi: ep.is_ai || false,
            serverData: (ep.server_data || []).map(sd => ({
                name: sd.name,
                slug: sd.slug,
                filename: sd.filename,
                linkEmbed: sd.link_embed,
                linkM3u8: sd.link_m3u8
            }))
        }));
    }

    return movie;
}

/**
 * Import 1 phim chi tiết theo slug
 */
async function importMovieBySlug(db, slug) {
    console.log(`\n  Importing movie: ${slug}`);
    
    const data = await fetchJson(`${OPHIM_BASE_URL}/phim/${slug}`);
    
    if (data.status !== 'success' || !data.data?.item) {
        console.error(`  ✗ Failed to fetch movie: ${slug}`);
        return null;
    }

    const movie = mapMovieFromOPhim(data.data.item, true);
    
    const collection = db.collection('movies');
    await collection.updateOne(
        { slug: movie.slug },
        { $set: movie },
        { upsert: true }
    );
    
    console.log(`  ✓ Imported: ${movie.name} (${movie.episodes?.length || 0} servers)`);
    return movie;
}

/**
 * Import movies từ danh sách (basic info only, không có episodes)
 */
async function importMoviesFromList(db, movies) {
    const collection = db.collection('movies');
    let imported = 0;
    
    for (const ophimMovie of movies) {
        const movie = mapMovieFromOPhim(ophimMovie, false);
        
        // Chỉ update nếu chưa có hoặc là basic import (không override detail import)
        const existing = await collection.findOne({ slug: movie.slug });
        
        if (!existing || !existing.episodes || existing.episodes.length === 0) {
            await collection.updateOne(
                { slug: movie.slug },
                { $set: movie },
                { upsert: true }
            );
            imported++;
        }
    }
    
    return imported;
}

/**
 * Import movies từ trang home hoặc danh sách
 */
async function importMovies(db, options = {}) {
    console.log('\n========== IMPORTING MOVIES ==========');
    
    const { pages = 3, withDetails = true } = options;
    
    let totalImported = 0;
    let totalErrors = 0;
    const slugsToImport = [];

    // Bước 1: Lấy danh sách phim từ các trang
    for (let page = 1; page <= pages; page++) {
        console.log(`\n--- Page ${page}/${pages} ---`);
        
        try {
            const data = await fetchJson(`${OPHIM_BASE_URL}/danh-sach/phim-moi-cap-nhat?page=${page}`);
            
            if (data.status !== 'success' || !data.data?.items) {
                console.error(`Failed to fetch page ${page}`);
                totalErrors++;
                continue;
            }

            const movies = data.data.items;
            console.log(`  Found ${movies.length} movies on page ${page}`);
            
            // Import basic info first
            const imported = await importMoviesFromList(db, movies);
            totalImported += imported;
            
            // Collect slugs for detail import
            if (withDetails) {
                for (const movie of movies) {
                    slugsToImport.push(movie.slug);
                }
            }
            
            await sleep(DELAY_BETWEEN_PAGES);
            
        } catch (error) {
            console.error(`Error on page ${page}:`, error.message);
            totalErrors++;
        }
    }

    // Bước 2: Import chi tiết từng phim (để lấy episodes)
    if (withDetails && slugsToImport.length > 0) {
        console.log(`\n--- Importing details for ${slugsToImport.length} movies ---`);
        
        for (let i = 0; i < slugsToImport.length; i++) {
            const slug = slugsToImport[i];
            console.log(`[${i + 1}/${slugsToImport.length}]`);
            
            try {
                await importMovieBySlug(db, slug);
                await sleep(DELAY_BETWEEN_REQUESTS);
            } catch (error) {
                console.error(`  ✗ Error importing ${slug}:`, error.message);
                totalErrors++;
            }
        }
    }

    console.log(`\n✓ Total imported: ${totalImported} movies, ${totalErrors} errors`);
    return { imported: totalImported, errors: totalErrors };
}

/**
 * Import phim theo thể loại
 */
async function importMoviesByGenre(db, genreSlug, options = {}) {
    console.log(`\n========== IMPORTING MOVIES BY GENRE: ${genreSlug} ==========`);
    
    const { pages = 2, withDetails = true } = options;
    
    let totalImported = 0;
    let totalErrors = 0;
    const slugsToImport = [];

    for (let page = 1; page <= pages; page++) {
        console.log(`\n--- Page ${page}/${pages} ---`);
        
        try {
            const data = await fetchJson(`${OPHIM_BASE_URL}/the-loai/${genreSlug}?page=${page}`);
            
            if (data.status !== 'success' || !data.data?.items) {
                console.error(`Failed to fetch page ${page}`);
                totalErrors++;
                continue;
            }

            const movies = data.data.items;
            console.log(`  Found ${movies.length} movies`);
            
            const imported = await importMoviesFromList(db, movies);
            totalImported += imported;
            
            if (withDetails) {
                for (const movie of movies) {
                    slugsToImport.push(movie.slug);
                }
            }
            
            await sleep(DELAY_BETWEEN_PAGES);
            
        } catch (error) {
            console.error(`Error on page ${page}:`, error.message);
            totalErrors++;
        }
    }

    if (withDetails && slugsToImport.length > 0) {
        console.log(`\n--- Importing details for ${slugsToImport.length} movies ---`);
        
        for (let i = 0; i < slugsToImport.length; i++) {
            const slug = slugsToImport[i];
            console.log(`[${i + 1}/${slugsToImport.length}]`);
            
            try {
                await importMovieBySlug(db, slug);
                await sleep(DELAY_BETWEEN_REQUESTS);
            } catch (error) {
                console.error(`  ✗ Error importing ${slug}:`, error.message);
                totalErrors++;
            }
        }
    }

    console.log(`\n✓ Total imported: ${totalImported} movies, ${totalErrors} errors`);
    return { imported: totalImported, errors: totalErrors };
}

// ==================== MAIN ====================
async function main() {
    const args = process.argv.slice(2);
    
    console.log('==========================================');
    console.log('       OPhim Import Tool');
    console.log('==========================================');
    console.log(`MongoDB: ${MONGODB_URI}/${DB_NAME}`);
    console.log(`OPhim API: ${OPHIM_BASE_URL}`);
    
    const client = new MongoClient(MONGODB_URI);
    
    try {
        await client.connect();
        console.log('✓ Connected to MongoDB\n');
        
        const db = client.db(DB_NAME);
        
        // Parse arguments
        const doGenres = args.includes('--genres') || args.includes('--all');
        const doCountries = args.includes('--countries') || args.includes('--all');
        const doMovies = args.includes('--movies') || args.includes('--all');
        const slugIndex = args.indexOf('--slug');
        const pagesIndex = args.indexOf('--pages');
        const genreIndex = args.indexOf('--genre');
        
        const specificSlug = slugIndex !== -1 ? args[slugIndex + 1] : null;
        const pages = pagesIndex !== -1 ? parseInt(args[pagesIndex + 1]) || 3 : 3;
        const specificGenre = genreIndex !== -1 ? args[genreIndex + 1] : null;
        
        // Import specific slug
        if (specificSlug) {
            await importMovieBySlug(db, specificSlug);
            return;
        }
        
        // Import by genre
        if (specificGenre) {
            await importMoviesByGenre(db, specificGenre, { pages, withDetails: true });
            return;
        }
        
        // Default: show help
        if (!doGenres && !doCountries && !doMovies) {
            console.log(`
Usage:
  node import.js --all                    Import tất cả (genres, countries, movies)
  node import.js --genres                 Chỉ import genres
  node import.js --countries              Chỉ import countries  
  node import.js --movies                 Import movies (mặc định 3 trang)
  node import.js --movies --pages 5       Import 5 trang movies
  node import.js --slug ten-phim          Import 1 phim cụ thể theo slug
  node import.js --genre hanh-dong        Import phim theo thể loại
  node import.js --genre hanh-dong --pages 3   Import 3 trang phim hành động
`);
            return;
        }

        const results = {};
        
        if (doGenres) {
            results.genres = await importGenres(db);
            await sleep(DELAY_BETWEEN_REQUESTS);
        }
        
        if (doCountries) {
            results.countries = await importCountries(db);
            await sleep(DELAY_BETWEEN_REQUESTS);
        }
        
        if (doMovies) {
            results.movies = await importMovies(db, { pages, withDetails: true });
        }

        console.log('\n==========================================');
        console.log('           IMPORT COMPLETE');
        console.log('==========================================');
        console.log('Results:', JSON.stringify(results, null, 2));
        
    } catch (error) {
        console.error('Fatal error:', error);
        process.exit(1);
    } finally {
        await client.close();
        console.log('\n✓ Disconnected from MongoDB');
    }
}

main();
