import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/core/resources/assets_manager.dart';
import '../cubit/lab_results_cubit.dart';
import '../cubit/lab_results_state.dart';
import '../widgets/top_bar.dart';
import '../widgets/hemoglobin_trend_card.dart';
import '../widgets/report_card.dart';
import '../widgets/detailed_result_item.dart';
import '../widgets/section_header.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';
import '../../../../core/resources/values_manager.dart';
import '../../patient_home_dashboard/widgets/patient_bottom_nav.dart';

class LabResultsViewBody extends StatelessWidget {
  const LabResultsViewBody({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.88, 1.15);
        double s(double v) => v * scale;
        return BlocBuilder<LabResultsCubit, LabResultsState>(
          builder: (context, state) {
            if (state is LabResultsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LabResultsError) {
              return Center(child: Text(state.message));
            }
            return Container(
              color: ColorManager.whiteLilac,
              child: Column(
                children: [
                  LabResultsTopBar(scale: scale),
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: SizedBox(height: s(16))),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: s(AppPadding.p24),
                          ),
                          sliver: SliverToBoxAdapter(
                            child: HemoglobinTrendCard(scale: scale),
                          ),
                        ),
                        LabSectionHeader(
                          scale: scale,
                          title: AppStrings.latestReports,
                          onSeeAll: () {},
                        ),
                        _buildLatestReportsList(scale),
                        LabSectionHeader(
                          scale: scale,
                          title: AppStrings.detailedResults,
                        ),
                        _buildDetailedResultsList(scale),
                        SliverToBoxAdapter(child: SizedBox(height: s(32))),
                      ],
                    ),
                  ),
                  const PatientBottomNav(currentIndex: 2),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLatestReportsList(double scale) {
    double s(double v) => v * scale;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: s(AppPadding.p24)),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          LabReportCard(
            scale: scale,
            title: AppStrings.completeBloodCount,
            date: 'Oct 24, 2023',
            status: AppStrings.normal,
            statusColor: ColorManager.salem,
            statusBgColor: ColorManager.feta,
          ),
          SizedBox(height: s(AppSize.s16)),
          LabReportCard(
            scale: scale,
            title: AppStrings.lipidProfile,
            date: 'Sep 15, 2023',
            status: AppStrings.attentionRequired,
            statusColor: ColorManager.tahitiGold,
            statusBgColor: ColorManager.butteryWhite,
            isWarning: true,
          ),
          SizedBox(height: s(AppSize.s16)),
          LabReportCard(
            scale: scale,
            title: AppStrings.thyroidFunctionTest,
            date: 'Aug 10, 2023',
            status: AppStrings.normal,
            statusColor: ColorManager.salem.withValues(alpha: 0.5),
            statusBgColor: ColorManager.feta.withValues(alpha: 0.5),
            isOpacity: true,
          ),
        ]),
      ),
    );
  }

  Widget _buildDetailedResultsList(double scale) {
    double s(double v) => v * scale;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: s(AppPadding.p24)),
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.circular(s(AppSize.s24)),
            border: Border.all(color: ColorManager.catskillWhite),
            boxShadow: [
              BoxShadow(
                color: ColorManager.black.withValues(alpha: 0.05),
                blurRadius: s(10),
                offset: Offset(0, s(4)),
              ),
            ],
          ),
          child: Column(
            children: [
              DetailedResultItem(
                scale: scale,
                title: AppStrings.glucoseFasting,
                value: '95',
                unit: AppStrings.mgDl,
                refRange: AppStrings.refRangeGlucose,
                icon: ImageAssets.glucose,
                iconBg: ColorManager.feta,
              ),
              DetailedResultItem(
                scale: scale,
                title: AppStrings.cholesterol,
                value: '210',
                unit: AppStrings.mgDl,
                refRange: AppStrings.refRangeCholesterol,
                icon: ImageAssets.cholesterol,
                iconBg: ColorManager.provincialPink,
                valueColor: ColorManager.alizarinCrimson,
                showButton: true,
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
