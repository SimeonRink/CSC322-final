// Dart imports
import 'dart:io';

// Flutter imports
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

// File imports
import '../../providers/user_profile_provider.dart';
import '../../models/user_profile.dart';
import 'firestore_keys.dart';

class DBUserProfile {
  ////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////
  // CLOUD FIRESTORE ACCESS METHODS
  ////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////
  // Pulls the Firebase user's user profile from Firestore and uses the passed in provider
  // to update displays througout the app.
  //
  // Returns true if data was fetched and set in provider; false otherwise
  ////////////////////////////////////////////////////////////////////////////////////////////
  static Future<bool> fetchUserProfileAndSyncProvider(
      UserProfileProvider userProfileProvider) async {
    // Initialize success variable
    bool success = false;

    // Get Firebase instance
    var db = FirebaseFirestore.instance;
    if (FirebaseAuth.instance.currentUser != null) {
      // Get the authenticated firebase user
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      // If no user logged in, return; otherwise continue
      if (user == null) {
        return false;
      }
      String uid = user.uid;

      // Try to get the user's data from firestore
      try {
        // This code does a one-time read of the database object
        //var ref = await db.collection(FS_COL_SA_USER_PROFILES).doc(uid).get();
        // if (ref.exists) {
        //   Map<String, dynamic>? data = ref.data()!;
        //   UserProfile userProfile = populateUserProfileFromFirestoreObject(data);

        //   // Use the provider to update the profile with new data
        //   userProfileProvider.updateUserProfile(userProfile);
        //   success = true;
        // }

        // This code sets up a listener to do a one-time read, and then it executes
        // again every time the document changes
        db.collection(FS_COL_SA_USER_PROFILES).doc(uid).snapshots().listen((docRef) {
          if (docRef.exists) {
            Map<String, dynamic>? data = docRef.data()!;
            UserProfile userProfile = populateUserProfileFromFirestoreObject(data);

            // Use the provider to update the profile with new data
            userProfileProvider.updateUserProfile(userProfile);
            success = true;
          }
        });
      } catch (e) {
        print("Encountered problem loading user profile from firestore: ${e.toString()}");
        userProfileProvider.wipe();
      }
    }

    // Return status
    return await Future.value(success);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  // Writes the provided user profile to the database
  ////////////////////////////////////////////////////////////////////////////////////////////
  static Future<bool> writeUserProfile(UserProfile userProfile) async {
    // Initialize success variable
    bool success = false;

    // Get Firebase instance
    var db = FirebaseFirestore.instance;
    if (FirebaseAuth.instance.currentUser != null) {
      // Get the authenticated firebase user
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      // If no user logged in, return; otherwise continue
      if (user == null) {
        return false;
      }
      String uid = user.uid;

      // Try to get the user's data from firestore
      try {
        // Attempt to write data
        await db
            .collection(FS_COL_SA_USER_PROFILES)
            .doc(uid)
            .set(userProfile.toJsonForDb(), SetOptions(merge: true));
        success = true;
      } catch (e) {
        print("Encountered problem writing user profile to firestore: ${e.toString()}");
        success = false;
      }
    }

    // Return status
    return success;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  // Creates a new User profile and populates using the JSON object passed in as parameter
  ////////////////////////////////////////////////////////////////////////////////////////////
  static UserProfile populateUserProfileFromFirestoreObject(Map<String, dynamic> data) {
    String userEmail = FirebaseAuth.instance.currentUser!.email ?? "";
    UserProfile userProfile = UserProfile.fromJsonDbObject(data, userEmail);
    return userProfile;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////
  // CLOUD STORAGE ACCESS METHODS
  ////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////
  // Pulls the Firebase user's user profile image from Cloud Storage and uses the passed in
  // provider to update displays througout the app.
  //
  // Returns true if image data was fetched and set in provider; false otherwise
  ////////////////////////////////////////////////////////////////////////////////////////////
  static Future<bool> fetchUserProfileImageAndSyncProvider(
      UserProfileProvider userProfileProvider) async {
    // Initialize success variable
    bool success = false;

    // Try to download the image
    try {
      // Get logged-in user's uid
      if (FirebaseAuth.instance.currentUser == null) {
        return false;
      }
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Get a Google Storage reference to the profile picture
      final ref =
          FirebaseStorage.instance.ref().child('users/$uid/profile_picture/userProfilePicture.jpg');

      var url = await ref.getDownloadURL();
      userProfileProvider.userImage = NetworkImage(url);
      success = true;
    } catch (e) {
      // If ref is bad/incomplete, set to local image
      userProfileProvider.userImage = GENERIC_IMAGE;
    }

    // Return status
    return await Future.value(success);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  // Uplads the user profile image to Google Cloud Storage
  ////////////////////////////////////////////////////////////////////////////////////////////
  static Future<bool> uploadNewUserProfileImage(
      File imageFile, UserProfileProvider userProfileProvider) async {
    // Initialize success variable
    bool success = false;

    try {
      // Get logged-in user's uid
      if (FirebaseAuth.instance.currentUser == null) {
        return false;
      }
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Get a reference to the logged-in user's profile pic and upload the new picture
      final gcsPath = 'users/$uid/profile_picture/userProfilePicture.jpg';
      final ref = FirebaseStorage.instance.ref().child(gcsPath);
      await ref.putFile(imageFile);
      success = true;
    } catch (e) {
      success = false;
    }

    return success;
  }
}
