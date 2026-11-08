import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/appointment.dart';

class AppointmentRepository {
  static final AppointmentRepository _instance = AppointmentRepository._internal();
  factory AppointmentRepository() => _instance;

  final List<Appointment> _inMemoryAppointments = List.from(Appointment.demo);
  late final StreamController<List<Appointment>> _controller;

  AppointmentRepository._internal() {
    _controller = StreamController<List<Appointment>>.broadcast(
      onListen: () => _controller.add(List.unmodifiable(_inMemoryAppointments)),
    );
  }

  Stream<List<Appointment>> watchAppointments() {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance
            .collection('appointments')
            .snapshots()
            .map((snapshot) {
          if (snapshot.docs.isEmpty) return _inMemoryAppointments;
          return snapshot.docs.map((doc) => Appointment.fromMap(doc.id, doc.data())).toList();
        }).handleError((_) => _inMemoryAppointments);
      }
    } catch (_) {}
    return _controller.stream;
  }

  void bookAppointment(Appointment appointment) {
    _inMemoryAppointments.insert(0, appointment);
    _controller.add(List.unmodifiable(_inMemoryAppointments));
    try {
      if (Firebase.apps.isNotEmpty) {
        FirebaseFirestore.instance.collection('appointments').doc(appointment.id).set(appointment.toMap());
      }
    } catch (_) {}
  }

  void updateStatus(String appointmentId, String newStatus, {String? reason}) {
    final index = _inMemoryAppointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _inMemoryAppointments[index] = _inMemoryAppointments[index].copyWith(
        status: newStatus,
        cancelReason: newStatus == 'cancelled' ? reason : null,
        rejectionReason: newStatus == 'rejected' ? reason : null,
      );
      _controller.add(List.unmodifiable(_inMemoryAppointments));
    }
    try {
      if (Firebase.apps.isNotEmpty) {
        final updates = <String, dynamic>{'status': newStatus};
        if (reason != null) updates['reason'] = reason;
        FirebaseFirestore.instance.collection('appointments').doc(appointmentId).update(updates);
      }
    } catch (_) {}
  }

  List<Appointment> get currentAppointments => List.unmodifiable(_inMemoryAppointments);
}
