// import 'package:attendify/data/response/status.dart';
// import 'package:attendify/model/notification/notification_model.dart';
// import 'package:attendify/resources/app_colors/app_colors.dart';
// import 'package:attendify/resources/styles/app_text_styles.dart';
// import 'package:attendify/view_model/notifications/notifications_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:provider/provider.dart';

// import '../../resources/AppColors/app_colors.dart';
// import '../notification_model/notification_model.dart';
// import '../view model/notifications_view_model.dart';

// class NotificationsView extends StatefulWidget {
//   const NotificationsView({super.key});

//   @override
//   State<NotificationsView> createState() => _NotificationsViewState();
// }

// class _NotificationsViewState extends State<NotificationsView> {
//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<NotificationViewModel>().getNotifications();
//       context.read<NotificationViewModel>().markAllAsRead();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: AppColors.primary,
//           leading: IconButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               icon: Icon(
//                 Icons.adaptive.arrow_back,
//                 color: AppColors.textWhite,
//               )),
//           title: Text(
//             "Notifications",
//             style: AppTextStyles.textStyle18.copyWith(
//                 color: AppColors.textWhite, fontWeight: FontWeight.w700),
//           ),
//         ),
//         body: Consumer<NotificationViewModel>(
//           builder: (context, provider, child) {
//             return switch (provider.notifications.status) {
//               null => throw UnimplementedError(),
//               Status.LOADING => const Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               Status.SUCCESS => ListView.builder(
//                   itemCount: provider.notifications.data!.length,
//                   itemBuilder: (context, index) {
//                     final notification = provider.notifications.data![index];
//                     return Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: InkWell(
//                           borderRadius: BorderRadius.circular(12),
//                           onTap: !notification.isRead
//                               ? () {
//                                   context
//                                       .read<NotificationViewModel>()
//                                       .markSingleNotificationRead(
//                                           notification.id.toString());
//                                 }
//                               : null,
//                           child: notificationListTile(notification)),
//                     );
//                   },
//                 ),
//               Status.ERROR =>
//                 Center(child: Text(provider.notifications.message.toString())),
//             };
//           },
//         ));
//   }

//   Widget notificationListTile(NotificationModel notification) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 500),
//       height: 100,
//       decoration: BoxDecoration(
//           color: notification.isRead
//               ? AppColors.secondary.withOpacity(0.3)
//               : AppColors.accent.withOpacity(
//                   0.3), // if unread then only accent else secondary
//           borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           children: [
//             CircleAvatar(
//                 backgroundColor: notification.isRead
//                     ? AppColors.lightGrey
//                     : AppColors.primary,
//                 radius: 20,
//                 child: const Icon(
//                   Iconsax.notification5,
//                   color: AppColors.textWhite,
//                 )),
//             const SizedBox(
//               width: 10,
//             ),
//             Expanded(
//                 child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   notification.notification,
//                   style: AppTextStyles.textStyle16,
//                 ),
//                 Text(
//                   notification.time,
//                   style: AppTextStyles.textStyle12
//                       .copyWith(color: AppColors.appbarBg),
//                 ),
//               ],
//             )),
//             const SizedBox(
//               width: 10,
//             ),
//             Icon(
//               Iconsax.tick_circle,
//               color:
//                   notification.isRead ? AppColors.success : AppColors.appbarBg,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
