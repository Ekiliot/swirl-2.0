import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  static const int maxInterests = 13;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user');
    }
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> _userDoc([String? uid]) => _db.collection('Users').doc(uid ?? _uid);

  // Read current profile once
  Future<Map<String, dynamic>?> getProfile({String? uid}) async {
    final snap = await _userDoc(uid).get();
    return snap.data();
  }

  // Watch profile updates
  Stream<Map<String, dynamic>?> watchProfile({String? uid}) {
    return _userDoc(uid).snapshots().map((s) => s.data());
  }

  // Upsert full profile
  Future<void> setProfile({
    required String name,
    required int age,
    required String gender,
    required List<String> interests,
    String? bio,
    String? uid,
  }) async {
    await _userDoc(uid).set({
      'name': name,
      'age': age,
      'gender': gender,
      'interests': interests,
      if (bio != null) 'bio': bio,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Partial updates
  Future<void> updateName(String name, {String? uid}) async {
    await _userDoc(uid).update({
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAge(int age, {String? uid}) async {
    await _userDoc(uid).update({
      'age': age,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateGender(String gender, {String? uid}) async {
    await _userDoc(uid).update({
      'gender': gender,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setInterests(List<String> interests, {String? uid}) async {
    await _userDoc(uid).update({
      'interests': interests,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBio(String bio, {String? uid}) async {
    await _userDoc(uid).update({
      'bio': bio,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addInterest(String interest, {String? uid}) async {
    await _userDoc(uid).update({
      'interests': FieldValue.arrayUnion([interest]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeInterest(String interest, {String? uid}) async {
    await _userDoc(uid).update({
      'interests': FieldValue.arrayRemove([interest]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
