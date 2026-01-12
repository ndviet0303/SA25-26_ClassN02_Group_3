INSERT INTO transactions (customer_id, movie_id, amount, currency, status, stripe_payment_intent_id, created_at, paid_at) VALUES 
(1, 3, 2.99, 'USD', 'COMPLETED', 'pi_sample_1', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 5, 19.99, 'USD', 'COMPLETED', 'pi_sample_2', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
