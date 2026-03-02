import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/moderation/domain/report.dart';
import '../features/moderation/presentation/report_providers.dart';
import '../shared/providers.dart';
import '../theme/design_tokens.dart';
import '../widgets/widgets.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final String targetId;
  final String targetType;

  const ReportScreen({
    super.key,
    required this.targetId,
    required this.targetType,
  });

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  ReportReason _reason = ReportReason.spam;
  final TextEditingController _commentController = TextEditingController();

  final List<_ReasonOption> _options = const [
    _ReasonOption('Fake oder Betrug', ReportReason.fraud),
    _ReasonOption('Unangemessener Inhalt', ReportReason.inappropriate),
    _ReasonOption('Falsche Informationen', ReportReason.spam),
    _ReasonOption('Doppeltes Inserat', ReportReason.spam),
    _ReasonOption('Sonstiges', ReportReason.spam),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(reportSubmissionProvider);

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        title: const Text('Inserat melden'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bitte hilf uns, BookCycle sicher zu halten. Warum moechtest du dieses Inserat melden?',
              style: TextStyle(fontSize: 18, color: DesignTokens.textPrimary),
            ),
            const SizedBox(height: DesignTokens.md),
            ..._options.map(_buildOption),
            const SizedBox(height: DesignTokens.md),
            InputField(
              label: 'Zusaetzliche Anmerkungen (optional)',
              controller: _commentController,
              hint: 'Beschreibe das Problem hier...',
            ),
            const SizedBox(height: DesignTokens.lg),
            PrimaryButton(
              label: 'Meldung absenden',
              isLoading: submissionState.isLoading,
              onPressed: _submitReport,
            ),
            const SizedBox(height: DesignTokens.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
                child: const Text('Abbrechen'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(_ReasonOption option) {
    final selected = _reason == option.reason;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: selected ? DesignTokens.secondary : DesignTokens.border),
      ),
      child: ListTile(
        title: Text(option.label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? DesignTokens.secondary : DesignTokens.textMuted,
        ),
        onTap: () => setState(() => _reason = option.reason),
      ),
    );
  }

  Future<void> _submitReport() async {
    final user = await ref.read(currentUserProvider.future);
    if (!mounted) {
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first.')),
      );
      return;
    }

    try {
      await ref.read(reportSubmissionProvider.notifier).submitReport(
            ReportRequest(
              targetId: widget.targetId,
              targetType: widget.targetType,
              reason: _reason,
              comment: _commentController.text.trim(),
              reporterId: user.id,
            ),
          );

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBF4F7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    color: DesignTokens.secondary, size: 38),
              ),
              const SizedBox(height: 12),
              const Text(
                'Vielen Dank',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Deine Meldung wurde erfolgreich uebermittelt.',
                textAlign: TextAlign.center,
                style: TextStyle(color: DesignTokens.textMuted),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.secondary,
                  foregroundColor: DesignTokens.textPrimary,
                ),
                child: const Text('Zurueck zur Uebersicht'),
              ),
            ),
          ],
        ),
      );

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit report.')),
      );
    }
  }
}

class _ReasonOption {
  final String label;
  final ReportReason reason;

  const _ReasonOption(this.label, this.reason);
}
