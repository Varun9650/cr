import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../notification_model/notification_model.dart';
import '../view model/notifications_view_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final NotificationViewModel viewModel;
  final VoidCallback? onTap;

  const NotificationTile({
    Key? key,
    required this.notification,
    required this.viewModel,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.withOpacity(0.2)
              : Colors.blue.withOpacity(0.3),
          width: notification.isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with status and actions
                Row(
                  children: [
                    // Unread indicator
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          shape: BoxShape.circle,
                        ),
                      ),

                    if (!notification.isRead) const SizedBox(width: 8),

                    // Notification text
                    Expanded(
                      child: Text(
                        notification.notification,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: notification.isRead
                              ? FontWeight.w400
                              : FontWeight.w500,
                          color: notification.isRead
                              ? Colors.grey[600]
                              : Colors.grey[800],
                        ),
                      ),
                    ),

                    // Action buttons
                    if (!notification.isRead) ...[
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.check,
                        label: 'Mark as Read',
                        color: Colors.green[600]!,
                        isLoading: viewModel.isLoading,
                        onTap: () => _markAsRead(context),
                      ),
                    ],

                    if (notification.isAccepted || notification.isIgnored) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: notification.isAccepted
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          notification.isAccepted ? 'Accepted' : 'Ignored',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: notification.isAccepted
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Timestamp and actions row
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Timestamp
                    Text(
                      notification.time,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),

                    const Spacer(),

                    // Action buttons for unread notifications
                    if (!notification.isRead) ...[
                      if (!notification.isAccepted &&
                          !notification.isIgnored) ...[
                        _buildActionButton(
                          icon: Icons.check_circle,
                          label: 'Accept',
                          color: Colors.green[600]!,
                          isLoading: viewModel.isLoading,
                          onTap: () => _acceptNotification(context),
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.cancel,
                          label: 'Ignore',
                          color: Colors.orange[600]!,
                          isLoading: viewModel.isLoading,
                          onTap: () => _ignoreNotification(context),
                        ),
                      ],
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
              Icon(
                icon,
                size: 14,
                color: color,
              ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _markAsRead(BuildContext context) async {
    try {
      await viewModel.markNotificationAsRead(notification.id);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification marked as read'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as read: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _acceptNotification(BuildContext context) async {
    try {
      await viewModel.acceptNotification(notification.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification accepted'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _ignoreNotification(BuildContext context) async {
    try {
      await viewModel.ignoreNotification(notification.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification ignored'),
            backgroundColor: Colors.orange[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ignore: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
