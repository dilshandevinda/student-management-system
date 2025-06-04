// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _announcementsRef;
  late StreamSubscription<QuerySnapshot>
      _announcementsSubscription; // Corrected type

  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  int _unseenCount = 0;

  @override
  void initState() {
    super.initState();
    _announcementsRef = _firestore.collection('announcements');
    _fetchAnnouncements();
  }

  void _fetchAnnouncements() {
    // Corrected stream and listener
    _announcementsSubscription = _announcementsRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      _notifications.clear();
      _unseenCount = 0;

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _notifications.add({
          'id': doc.id,
          'academicYear': data['academicYear'] ?? '',
          'department': data['department'] ?? '',
          'subject': data['subject'] ?? '',
          'description': data['description'] ?? '',
          'timestamp': data['timestamp'] ?? Timestamp.now(),
          'read': data['read'] ?? false,
          'seen': data['seen'] ?? false,
        });

        if (!(data['seen'] ?? false)) {
          _unseenCount++;
        }
      }

      _updateUnreadCount();
    }, onError: (error) {
      print("Error fetching announcements: $error");
    });
  }

  void _updateUnreadCount() {
    _unreadCount =
        _notifications.where((notification) => !notification['read']).length;
    if (mounted) {
      setState(() {});
    }
  }

  void _markAsRead(String id) {
    final notificationIndex =
        _notifications.indexWhere((notification) => notification['id'] == id);
    if (notificationIndex != -1) {
      _announcementsRef.doc(id).update({'read': true}).then((_) {
        if (mounted) {
          setState(() {
            _notifications[notificationIndex]['read'] = true;
            _updateUnreadCount();
          });
        }
      });
    }
  }

  void _markAsSeen(String id) {
    final notificationIndex =
        _notifications.indexWhere((notification) => notification['id'] == id);
    if (notificationIndex != -1) {
      _announcementsRef.doc(id).update({'seen': true}).then((_) {
        if (mounted) {
          setState(() {
            _notifications[notificationIndex]['seen'] = true;
            _unseenCount--;
          });
        }
      });
    }
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    _markAsSeen(notification['id']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(notification['subject']),
          content: Text(notification['description']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _markAsRead(notification['id']);
              },
              child: const Text('Mark as Read'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _announcementsSubscription
        .cancel(); // Correctly cancel the Firestore subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: badges.Badge(
                showBadge: _unseenCount > 0,
                badgeContent: Text(
                  _unseenCount.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
                child: Icon(
                  Icons.notifications,
                  color: _unseenCount > 0 ? Colors.red : Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            leading: Icon(
              Icons.notifications,
              color: notification['seen'] ? Colors.grey : Colors.red,
            ),
            title: Text(
              notification['subject'],
              style: TextStyle(
                fontWeight:
                    notification['read'] ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Text(notification['description']),
            trailing: Text(_formatTimestamp(notification[
                'timestamp'])), // Assuming you have a _formatTimestamp method
            onTap: () {
              _showNotificationDetails(notification);
            },
          );
        },
      ),
    );
  }

  // Helper method to format timestamps (using intl package)
  String _formatTimestamp(Timestamp timestamp) {
    if (timestamp == null) return '';
    DateTime dateTime = timestamp.toDate();
    // Use intl package for more formatting options
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}
