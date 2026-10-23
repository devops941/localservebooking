import 'package:flutter/material.dart';
import '../../core/models/booking_model.dart';
import '../../core/services/booking_service.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';

class ReviewScreen extends StatefulWidget {
  final BookingModel booking;

  const ReviewScreen({super.key, required this.booking});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _tags = [
    'On Time',
    'Polite & Professional',
    'Clean & Tidy Work',
    'Fair Pricing',
    'Quick Service',
    'Highly Recommended',
  ];
  final Set<String> _selectedTags = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));

    String finalComment = _commentController.text.trim();
    if (_selectedTags.isNotEmpty) {
      final tagsString = _selectedTags.join(', ');
      finalComment = finalComment.isEmpty
          ? tagsString
          : '$finalComment\n(Highlights: $tagsString)';
    }

    BookingService().submitReview(widget.booking.id, _rating, finalComment);
    setState(() => _isSubmitting = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you! Your review has been submitted.'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Rate & Review Service',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Provider Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.12),
                    child: Text(
                      widget.booking.providerName[0],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.booking.providerName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.booking.serviceTitle,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'How was your experience?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Your feedback helps us maintain top quality services.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            // Star selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  iconSize: 40,
                  icon: Icon(
                    starValue <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = starValue.toDouble();
                    });
                  },
                );
              }),
            ),
            Text(
              _rating == 5
                  ? 'Excellent!'
                  : _rating == 4
                      ? 'Very Good'
                      : _rating == 3
                          ? 'Average'
                          : _rating == 2
                              ? 'Poor'
                              : 'Terrible',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF92400E),
              ),
            ),
            const SizedBox(height: 24),
            // Tags
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'What did you like the most?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1E88E5).withValues(alpha: 0.15),
                  checkmarkColor: const Color(0xFF1E88E5),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade800,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Comment
            CustomTextField(
              controller: _commentController,
              hintText: 'Share more details about your service experience...',
              labelText: 'Write a Review (Optional)',
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Submit Review',
              isLoading: _isSubmitting,
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
