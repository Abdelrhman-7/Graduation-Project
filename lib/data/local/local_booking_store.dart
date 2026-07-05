import 'dart:convert';



import 'package:shared_preferences/shared_preferences.dart';



import '../models/booking/booking_model.dart';



/// يحفظ الحجوزات محلياً حتى يتوفر Doctor/BookingApi على السيرفر.

class LocalBookingStore {

  LocalBookingStore._();



  static final LocalBookingStore instance = LocalBookingStore._();



  static const _storageKey = 'local_pending_bookings';



  Future<List<BookingModel>> getAll() async {

    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) return [];



    try {

      final decoded = jsonDecode(raw);

      if (decoded is! List) return [];

      return decoded

          .whereType<Map>()

          .map((e) => BookingModel.fromJson(Map<String, dynamic>.from(e)))

          .where((b) => b.id > 0)

          .toList();

    } catch (_) {

      return [];

    }

  }



  Future<void> addBooking(BookingModel booking) async {

    final all = await getAll()..removeWhere((b) => b.id == booking.id);

    all.add(booking);

    await _save(all);

  }



  Future<List<BookingModel>> getAllForClinics(Set<int> clinicIds) async {

    if (clinicIds.isEmpty) return [];

    final all = await getAll();

    return all

        .where((b) => b.clinicId != null && clinicIds.contains(b.clinicId))

        .toList()

      ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));

  }



  Future<List<BookingModel>> getPendingForClinics(Set<int> clinicIds) async {

    if (clinicIds.isEmpty) return [];

    final all = await getAll();

    return all

        .where(

          (b) =>

              b.clinicId != null &&

              clinicIds.contains(b.clinicId) &&

              b.isPending,

        )

        .toList()

      ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));

  }



  Future<List<BookingModel>> getForClinic(

    int clinicId, {

    bool pendingOnly = false,

  }) async {

    final all = await getAll();

    return all

        .where((b) {

          if (b.clinicId != clinicId) return false;

          if (pendingOnly && !b.isPending) return false;

          return true;

        })

        .toList()

      ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));

  }



  Future<List<BookingModel>> getBookingsForPatient({

    String? patientName,

    String? patientEmail,

  }) async {

    final all = await getAll();

    return all.where((b) => _matchesPatient(b, patientName, patientEmail)).toList()

      ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));

  }



  Future<List<BookingModel>> getUnreadNotificationsForPatient({

    String? patientName,

    String? patientEmail,

  }) async {

    final bookings =

        await getBookingsForPatient(patientName: patientName, patientEmail: patientEmail);

    return bookings

        .where((b) => b.notificationUnread && !b.isPending)

        .toList()

      ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));

  }



  Future<void> markNotificationRead(int bookingId) async {

    final all = await getAll();

    final index = all.indexWhere((b) => b.id == bookingId);

    if (index < 0) return;

    all[index] = all[index].copyWith(notificationUnread: false);

    await _save(all);

  }



  Future<void> markAllNotificationsRead({

    String? patientName,

    String? patientEmail,

  }) async {

    final all = await getAll();

    var changed = false;

    for (var i = 0; i < all.length; i++) {

      final b = all[i];

      if (b.notificationUnread &&

          !b.isPending &&

          _matchesPatient(b, patientName, patientEmail)) {

        all[i] = b.copyWith(notificationUnread: false);

        changed = true;

      }

    }

    if (changed) await _save(all);

  }



  Future<bool> updateStatus(int bookingId, String status) async {

    final all = await getAll();

    final index = all.indexWhere((b) => b.id == bookingId);

    if (index < 0) return false;



    final current = all[index];

    final wasPending = current.isPending;

    final notifyPatient = wasPending &&

        (status == 'Approved' || status == 'Rejected');



    all[index] = current.copyWith(

      status: status,

      notificationUnread: notifyPatient ? true : current.notificationUnread,

    );

    await _save(all);

    return true;

  }



  Future<void> deleteBooking(int bookingId) async {

    final all = await getAll();

    final previousLength = all.length;

    all.removeWhere((b) => b.id == bookingId);

    if (all.length != previousLength) {

      await _save(all);

    }

  }



  bool _matchesPatient(

    BookingModel booking,

    String? patientName,

    String? patientEmail,

  ) {

    if (patientEmail != null &&

        patientEmail.isNotEmpty &&

        booking.patientEmail != null &&

        booking.patientEmail!.isNotEmpty) {

      return booking.patientEmail!.toLowerCase() == patientEmail.toLowerCase();

    }

    if (patientName != null && patientName.isNotEmpty) {

      return booking.patientName.toLowerCase() == patientName.toLowerCase();

    }

    return false;

  }



  Future<void> _save(List<BookingModel> bookings) async {

    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(bookings.map((b) => b.toJson()).toList());

    await prefs.setString(_storageKey, encoded);

  }

}

