import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/api/api_manager.dart';

class RateDoctorSheet extends StatefulWidget {
  final int doctorId;
  final VoidCallback? onReviewSubmitted;

  const RateDoctorSheet({
    super.key,
    required this.doctorId,
    this.onReviewSubmitted,
  });

  static void show(BuildContext context, int doctorId, {VoidCallback? onReviewSubmitted}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return RateDoctorSheet(
          doctorId: doctorId,
          onReviewSubmitted: onReviewSubmitted,
        );
      },
    );
  }

  @override
  State<RateDoctorSheet> createState() => _RateDoctorSheetState();
}

class _RateDoctorSheetState extends State<RateDoctorSheet> {
  int rating = 0;
  final commentController = TextEditingController();
  final focusNode = FocusNode();
  bool isLoading = true;
  int? existingReviewId;

  @override
  void initState() {
    super.initState();
    _fetchExistingReview();
  }

  Future<void> _fetchExistingReview() async {
    try {
      final api = await ApiManager.create();
      final reviews = await api.getPatientDoctorReviews(widget.doctorId);
      if (reviews.isNotEmpty && mounted) {
        final review = reviews.first;
        setState(() {
          existingReviewId = review['id'];
          rating = review['rating'] ?? 0;
          commentController.text = review['comment'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching existing review: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      existingReviewId != null ? 'Edit Review' : 'Rate Doctor',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: const Color(0xFFEAB308),
                            size: 40,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      focusNode: focusNode,
                      maxLines: 3,
                      autofocus: false, // Let user tap to focus
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add a comment (optional)...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onTap: () {
                        focusNode.requestFocus();
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: rating == 0
                            ? null
                            : () async {
                                final api = await ApiManager.create();
                                String? errorMessage;
                                
                                if (existingReviewId != null) {
                                  errorMessage = await api.editDoctorReview(
                                    reviewId: existingReviewId!,
                                    rating: rating,
                                    comment: commentController.text,
                                  );
                                } else {
                                  errorMessage = await api.addDoctorReview(
                                    doctorId: widget.doctorId,
                                    rating: rating,
                                    comment: commentController.text,
                                  );
                                }

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  widget.onReviewSubmitted?.call();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        errorMessage ?? (existingReviewId != null ? 'Review updated!' : 'Review submitted!'),
                                        style: GoogleFonts.cairo(),
                                      ),
                                      backgroundColor: errorMessage == null
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFFEF4444),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF137FEC),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          existingReviewId != null ? 'Update Review' : 'Submit Review',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (existingReviewId != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () async {
                            final api = await ApiManager.create();
                            final errorMessage = await api.deleteDoctorReview(existingReviewId!);
                            
                            if (context.mounted) {
                              Navigator.pop(context);
                              widget.onReviewSubmitted?.call();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    errorMessage ?? 'Review deleted!',
                                    style: GoogleFonts.cairo(),
                                  ),
                                  backgroundColor: errorMessage == null
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFEF4444),
                                ),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Delete Review',
                            style: GoogleFonts.cairo(
                              color: const Color(0xFFEF4444),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
