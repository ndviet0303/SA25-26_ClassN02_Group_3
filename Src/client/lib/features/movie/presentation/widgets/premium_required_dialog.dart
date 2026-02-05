import 'package:flutter/material.dart';
import '../../../../core/app_export.dart';

/// Show Premium Required dialog when user tries to watch premium content
/// Returns true if user wants to navigate to subscription screen
Future<bool> showPremiumRequiredDialog(
  BuildContext context, {
  String? message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade800,
              Colors.purple.shade900,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Crown icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 48,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            const Text(
              'Premium Content',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message ?? 'This movie requires a Premium subscription to watch.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
            
            // Features
            _buildFeatureRow(Icons.movie, 'Unlimited premium movies'),
            const SizedBox(height: 8),
            _buildFeatureRow(Icons.hd, '4K Ultra HD streaming'),
            const SizedBox(height: 8),
            _buildFeatureRow(Icons.block, 'No advertisements'),
            
            const SizedBox(height: 24),
            
            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Upgrade to Premium',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Maybe Later',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  
  return result ?? false;
}

Widget _buildFeatureRow(IconData icon, String text) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: Colors.amber, size: 18),
      const SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 13,
        ),
      ),
    ],
  );
}
