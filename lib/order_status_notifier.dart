import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderStatusNotifier with ChangeNotifier {
  Map<String, String> lastKnownStatuses = {};

  void checkOrderStatus(QuerySnapshot snapshot) {
    for (var order in snapshot.docs) {
      var orderId = order['orderId'];
      var orderStatus = order['orderstatus'].toLowerCase();

      if (lastKnownStatuses[orderId] == 'pending' && orderStatus == 'done') {
        // Notify listeners to trigger a dialog
        notifyListeners();
      }

      // Update last known status
      lastKnownStatuses[orderId] = orderStatus;
    }
  }
}