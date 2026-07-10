import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/resources/color_manager.dart';
import '../../../../../data/api/api_manager.dart';

class DoctorProfileHeader extends StatefulWidget {
  final String name;
  final String? imageUrl;
  final int? age;
  final int patientsCount;
  final VoidCallback? onEditTap;
  final String? specialization;

  const DoctorProfileHeader({
    super.key,
    required this.name,
    this.imageUrl,
    this.age,
    this.patientsCount = 0,
    this.specialization,
    this.onEditTap,
  });

  @override
  State<DoctorProfileHeader> createState() => _DoctorProfileHeaderState();
}

class _DoctorProfileHeaderState extends State<DoctorProfileHeader> {
  String averageRating = "0.0";
  String reviewCount = "0";

  @override
  void initState() {
    super.initState();
    _fetchRating();
  }

  Future<void> _fetchRating() async {
    try {
      final api = await ApiManager.create();
      final reviews = await api.getDoctorAllReviews();
      if (reviews.isNotEmpty && mounted) {
        double total = 0;
        int count = 0;
        for (var review in reviews) {
          final rating = (review['rating'] as num?)?.toDouble() ?? 0.0;
          if (rating > 0) {
            total += rating;
            count++;
          }
        }
        if (count > 0) {
          setState(() {
            averageRating = (total / count).toStringAsFixed(1);
            reviewCount = count.toString();
          });
        }
      }
    } catch (e) {
      print('Error fetching rating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.imageUrl == null ? const Color(0xFFF0F0F0) : null,
                image: widget.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(widget.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: widget.imageUrl == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: Color(0xFFBDBDBD),
                    )
                  : null,
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.headlineText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onEditTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: ColorManager.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.specialization ?? "Doctor",
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorManager.primary,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              "Age",
              widget.age != null ? "${widget.age} years" : "N/A",
            ),
            _buildStatItem("Patients", "${widget.patientsCount}"),
            _buildStatItem("Rating", "$averageRating/5 ($reviewCount)"),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: ColorManager.subtitleText,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ColorManager.headlineText,
            ),
          ),
        ],
      ),
    );
  }
}
