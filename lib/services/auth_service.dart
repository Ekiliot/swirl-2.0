import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final int? age;
  final String? gender;

  AuthUser({required this.uid, this.email, this.displayName, this.age, this.gender});

  factory AuthUser.fromFirebase(User user, {Map<String, dynamic>? profile}) {
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: profile?['name'] ?? user.displayName,
      age: profile?['age'],
      gender: profile?['gender'],
    );
  }
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<AuthUser?> get authStateChanges async* {
    await for (final user in _auth.authStateChanges()) {
      if (user == null) {
        yield null;
      } else {
        final profileSnap = await _db.collection('Users').doc(user.uid).get();
        yield AuthUser.fromFirebase(user, profile: profileSnap.data());
      }
    }
  }

  Future<AuthUser> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = cred.user!;
    await user.updateDisplayName(name);

    await _db.collection('Users').doc(user.uid).set({
      'email': email,
      'name': name,
      'age': age,
      'gender': gender,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final profile = (await _db.collection('Users').doc(user.uid).get()).data();
    return AuthUser.fromFirebase(user, profile: profile);
  }

  Future<AuthUser> loginWithEmail({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = cred.user!;
    final profile = (await _db.collection('Users').doc(user.uid).get()).data();
    return AuthUser.fromFirebase(user, profile: profile);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentFirebaseUser => _auth.currentUser;
}
