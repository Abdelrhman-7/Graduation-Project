import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/doctor_reviews_cubit.dart';
import '../cubit/doctor_reviews_state.dart';
import '../../../../../core/resources/color_manager.dart';

class DoctorReviewsView extends StatelessWidget {
  const DoctorReviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorReviewsCubit()..getDoctorReviews(),
      child: const _DoctorReviewsViewBody(),
    );
  }
}

class _DoctorReviewsViewBody extends StatelessWidget {
  const _DoctorReviewsViewBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Reviews',
          style: GoogleFonts.cairo(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<DoctorReviewsCubit, DoctorReviewsState>(
        builder: (context, state) {
          if (state is DoctorReviewsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DoctorReviewsError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.cairo(color: Colors.red),
              ),
            );
          } else if (state is DoctorReviewsSuccess) {
            final reviews = state.reviews;
            if (reviews.isEmpty) {
              return Center(
                child: Text(
                  'No reviews yet.',
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF64748B),
                    fontSize: 16,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                final rating = (review['rating'] ?? 0) as int;
                final comment = (review['comment'] ?? '').toString();
                final patientName = (review['patientName'] ?? 'Anonymous Patient').toString();
                // We don't have the date in standard reviews typically, but if we do:
                // final date = (review['reviewDate'] ?? '').toString();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x05000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFEFF6FF),
                            child: const Icon(Icons.person, color: Color(0xFF137FEC)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patientName,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < rating
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      size: 16,
                                      color: const Color(0xFFEAB308),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (comment.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          comment,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: const Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
