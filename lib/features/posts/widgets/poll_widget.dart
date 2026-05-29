import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../models/post_model.dart';

class PollWidget extends StatefulWidget {
  final PostModel post;
  final void Function(String option) onVote;

  const PollWidget({super.key, required this.post, required this.onVote});

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  String? _voted;

  int get _totalVotes => widget.post.pollVotes.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final options = widget.post.pollOptions;

    if (options.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...options.map((option) {
            final votes = widget.post.pollVotes[option] ?? 0;
            final total = _totalVotes;
            final pct = total > 0 ? votes / total : 0.0;
            final isChosen = _voted == option;

            return GestureDetector(
              onTap: _voted == null
                  ? () {
                      setState(() => _voted = option);
                      widget.onVote(option);
                    }
                  : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Stack(
                  children: [
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color: isChosen ? primary : Colors.grey.shade300,
                          width: isChosen ? 2 : 1,
                        ),
                        color: AppColors.surfaceColor(isDigital),
                      ),
                    ),
                    if (_voted != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        child: FractionallySizedBox(
                          widthFactor: pct,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 44,
                            color: primary.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 44,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isChosen ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (_voted != null)
                              Text(
                                '${(pct * 100).round()}%',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primary),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (_totalVotes > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '$_totalVotes votes',
                style: TextStyle(fontSize: 11, color: AppColors.textSubFor(isDigital)),
              ),
            ),
        ],
      ),
    );
  }
}
