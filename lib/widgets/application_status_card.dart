import 'package:flutter/material.dart';
import '../models/government_scheme_models.dart' as models;
import '../utils/app_theme.dart';

class ApplicationStatusCard extends StatelessWidget {
  final models.SchemeApplication application;
  final VoidCallback onTap;

  const ApplicationStatusCard({
    super.key,
    required this.application,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildApplicationInfo(),
              const SizedBox(height: 12),
              _buildStatusTimeline(),
              const SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(application.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStatusIcon(application.status),
            color: _getStatusColor(application.status),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                application.schemeName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'ID: ${application.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (application.trackingNumber != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        application.trackingNumber!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _getStatusColor(application.status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(application.status),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            'Applied Date',
            _formatDate(application.appliedDate),
            Icons.calendar_today,
          ),
          if (application.lastUpdated != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              'Last Updated',
              _formatDate(application.lastUpdated!),
              Icons.update,
            ),
          ],
          if (application.rejectionReason != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              'Rejection Reason',
              application.rejectionReason!,
              Icons.error_outline,
              valueColor: Colors.red[600],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: valueColor ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline() {
    if (application.statusUpdates.isEmpty) {
      return const SizedBox.shrink();
    }

    final recentUpdates = application.statusUpdates.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Updates',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...recentUpdates.map((update) => _buildTimelineItem(update)),
      ],
    );
  }

  Widget _buildTimelineItem(models.StatusUpdate update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update.message,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  update.messageHindi,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  _formatDate(update.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (application.documentPath != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _viewDocument(context),
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('View PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
                side: const BorderSide(color: AppTheme.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        if (application.documentPath != null) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _trackStatus(context),
            icon: const Icon(Icons.track_changes, size: 18),
            label: const Text('Track'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusText(models.ApplicationStatus status) {
    switch (status) {
      case models.ApplicationStatus.draft:
        return 'Draft';
      case models.ApplicationStatus.submitted:
        return 'Submitted';
      case models.ApplicationStatus.underReview:
        return 'Under Review';
      case models.ApplicationStatus.approved:
        return 'Approved';
      case models.ApplicationStatus.rejected:
        return 'Rejected';
      case models.ApplicationStatus.documentsPending:
        return 'Docs Pending';
      case models.ApplicationStatus.paymentProcessing:
        return 'Processing';
      case models.ApplicationStatus.completed:
        return 'Completed';
    }
  }

  IconData _getStatusIcon(models.ApplicationStatus status) {
    switch (status) {
      case models.ApplicationStatus.draft:
        return Icons.drafts;
      case models.ApplicationStatus.submitted:
        return Icons.send;
      case models.ApplicationStatus.underReview:
        return Icons.hourglass_empty;
      case models.ApplicationStatus.approved:
        return Icons.check_circle;
      case models.ApplicationStatus.rejected:
        return Icons.cancel;
      case models.ApplicationStatus.documentsPending:
        return Icons.folder_open;
      case models.ApplicationStatus.paymentProcessing:
        return Icons.payment;
      case models.ApplicationStatus.completed:
        return Icons.done_all;
    }
  }

  Color _getStatusColor(models.ApplicationStatus status) {
    switch (status) {
      case models.ApplicationStatus.draft:
        return Colors.grey[600]!;
      case models.ApplicationStatus.submitted:
        return Colors.blue[600]!;
      case models.ApplicationStatus.underReview:
        return Colors.orange[600]!;
      case models.ApplicationStatus.approved:
        return Colors.green[600]!;
      case models.ApplicationStatus.rejected:
        return Colors.red[600]!;
      case models.ApplicationStatus.documentsPending:
        return Colors.amber[600]!;
      case models.ApplicationStatus.paymentProcessing:
        return Colors.purple[600]!;
      case models.ApplicationStatus.completed:
        return Colors.teal[600]!;
    }
  }

  void _viewDocument(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening PDF document...'),
      ),
    );
  }

  void _trackStatus(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tracking application ${application.trackingNumber ?? application.id}'),
      ),
    );
  }
}
