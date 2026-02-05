package com.nozie.movieservice.streaming.service;

import com.nozie.movieservice.common.model.Movie;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

/**
 * AccessControlService - Xử lý kiểm tra quyền xem phim (FREE/PREMIUM/RENTAL)
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class AccessControlService {

    private final RestTemplate restTemplate;

    @Value("${services.customer-service.url:http://customer-service:8082}")
    private String customerServiceUrl;

    /**
     * Kiểm tra quyền xem phim của user
     * 
     * @return true nếu được phép xem, false nếu bị từ chối
     */
    public boolean canWatch(Movie movie, Long userId) {
        log.info("Checking access for user {} to movie {} (Access: {})",
                userId, movie.getName(), movie.getAccessType());

        // 1. Nếu phim FREE thì ai cũng xem được
        if (movie.getAccessType() == null || movie.getAccessType() == Movie.AccessType.FREE) {
            return true;
        }

        // 2. Nếu phim PREMIUM hoặc RENTAL nhưng user không đăng nhập -> Chặn
        if (userId == null) {
            log.warn("Access denied: User not logged in for protected movie");
            return false;
        }

        // 3. Nếu phim PREMIUM -> Kiểm tra subscription qua customer-service
        if (movie.getAccessType() == Movie.AccessType.PREMIUM) {
            return checkSubscription(userId);
        }

        // 4. Nếu phim RENTAL -> (Dành cho UC sau) Kiểm tra xem user đã mua phim này
        // chưa
        if (movie.getAccessType() == Movie.AccessType.RENTAL) {
            // Tạm thời cho phép nếu có PREMIUM hoặc chặn nếu chưa implement RENTAL check
            return checkSubscription(userId);
        }

        return false;
    }

    /**
     * Gọi customer-service để kiểm tra trạng thái Subscription
     */
    private boolean checkSubscription(Long userId) {
        try {
            String url = customerServiceUrl + "/api/customers/" + userId;
            log.debug("Checking subscription at: {}", url);

            var response = restTemplate.exchange(
                    url,
                    HttpMethod.GET,
                    null,
                    new ParameterizedTypeReference<Map<String, Object>>() {
                    });

            if (response.getBody() != null && response.getBody().get("data") != null) {
                @SuppressWarnings("unchecked")
                Map<String, Object> customerData = (Map<String, Object>) response.getBody().get("data");

                Boolean isSubscribed = (Boolean) customerData.get("isSubscribed");
                return isSubscribed != null && isSubscribed;
            }
            return false;
        } catch (Exception e) {
            log.error("Error checking subscription for user {}: {}", userId, e.getMessage());
            return false;
        }
    }
}
