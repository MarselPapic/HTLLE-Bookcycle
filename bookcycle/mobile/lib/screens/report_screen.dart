import 'package:flutter/material.dart';
import '../features/moderation/domain/report.dart';
import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

/// User Story: US-007 Report Function
class ReportScreen extends StatefulWidget {
  final String targetId;
  final String targetType;

  const ReportScreen({
    super.key,
    required this.targetId,
    required this.targetType,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  ReportReason _reason = ReportReason.spam;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Report',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why are you reporting this?', style: DesignTokens.body),
          const SizedBox(height: DesignTokens.md),
          DropdownButton<ReportReason>(
            value: _reason,
            items: ReportReason.values
                .map((reason) => DropdownMenuItem(
                      value: reason,
                      child: Text(reason.name.toUpperCase()),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _reason = value ?? _reason),
          ),
          const SizedBox(height: DesignTokens.md),
          InputField(label: 'Comment (optional)', controller: _commentController),
          const SizedBox(height: DesignTokens.lg),
          PrimaryButton(
            label: 'Submit report',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted.')),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
