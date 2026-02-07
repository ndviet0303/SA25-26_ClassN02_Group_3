-- Insert default subscription plans into paymentdb
-- Run: see README or command below

INSERT INTO subscription_plans (plan_type, name, description, price, currency, interval_months, stripe_price_id, active) VALUES
('FREE', 'Gói Miễn Phí', 'Xem phim miễn phí với quảng cáo', 0, 'vnd', 0, NULL, true),
('STUDENT_MONTHLY', 'Gói Học Sinh', 'Dành cho sinh viên, giá ưu đãi', 49000, 'vnd', 1, 'price_1Sx51lDF8r7KM6OqBxyUODsi', true),
('PREMIUM_MONTHLY', 'Premium Tháng', 'Xem phim không giới hạn, không quảng cáo', 99000, 'vnd', 1, 'price_1Sx4wHDF8r7KM6OqZ9W4Jkcv', true),
('PREMIUM_QUARTERLY', 'Premium Quý', 'Gói 3 tháng tiết kiệm', 249000, 'vnd', 3, 'price_1Sx533DF8r7KM6OqxrjM7QS5', true),
('PREMIUM_YEARLY', 'Premium Năm', 'Xem phim không giới hạn, tiết kiệm 20%', 948000, 'vnd', 12, 'price_1Sx53pDF8r7KM6OqXgNAWxxK', true),
('VIP_MONTHLY', 'VIP Tháng', 'Tất cả Premium + Xem sớm, chất lượng 4K', 199000, 'vnd', 1, 'price_1Sx54MDF8r7KM6OqFPfojR1I', true),
('VIP_YEARLY', 'VIP Năm', 'Tất cả VIP + Tiết kiệm 30%', 1668000, 'vnd', 12, 'price_1Sx55KDF8r7KM6OqhMmlo3wF', true)
ON CONFLICT (plan_type) DO UPDATE SET
    stripe_price_id = EXCLUDED.stripe_price_id,
    price = EXCLUDED.price;
