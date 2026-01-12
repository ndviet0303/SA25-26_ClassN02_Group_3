INSERT INTO notifications (customer_id, title, description, type, read, created_at) VALUES 
(1, 'Welcome to Nozie!', 'Thank you for joining our movie streaming platform.', 'WELCOME', false, CURRENT_TIMESTAMP),
(1, 'Subscription Active', 'Your premium subscription is now active. Enjoy!', 'SUBSCRIPTION', false, CURRENT_TIMESTAMP),
(2, 'New Movie Alert', 'Dune: Part Two is now available for streaming.', 'NEW_CONTENT', true, CURRENT_TIMESTAMP);
