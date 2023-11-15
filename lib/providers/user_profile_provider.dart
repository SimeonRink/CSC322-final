// Dart imports
import 'dart:io';

// Flutter imports
import 'package:flutter/widgets.dart';

// File imports
import '../db_helpers/firebase/db_user_profile.dart';
import '../models/user_profile.dart';

// Constants
const ImageProvider GENERIC_IMAGE = const AssetImage('assets/images/logo.jpg');

//////////////////////////////////////////////////////////////////
// State class that manages order variables; implements
// ChangeNotifier mix-in so it can be accessed in multiple files.
//////////////////////////////////////////////////////////////////
class UserProfileProvider with ChangeNotifier {
  // The "instance variables" managed in this state
  UserProfile _userProfile = UserProfile.empty();
  ImageProvider _userImage = GENERIC_IMAGE;
  bool _dataLoaded = false;
  bool _imageLoaded = false;

  //////////////////////////////////////////////////////////////////
  // GETTERS/SETTERS
  //////////////////////////////////////////////////////////////////
  bool get dataLoaded => _dataLoaded;

  String get firstName => _userProfile.firstName;
  set firstName(String value) {
    _userProfile.firstName = value;
    notifyListeners();
  }

  String get lastName => _userProfile.lastName;
  set lastName(String value) {
    _userProfile.lastName = value;
    notifyListeners();
  }

  String get email => _userProfile.email;
  set email(String value) {
    _userProfile.email = value;
    notifyListeners();
  }

  String get defaultRoomId => _userProfile.defaultRoomId;
  set defaultRoomId(String value) {
    _userProfile.defaultRoomId = value;
    notifyListeners();
  }

  String get currentRoomId => _userProfile.currentRoomId;
  set currentRoomId(String value) {
    _userProfile.currentRoomId = value;
    notifyListeners();
  }

  String get organizationId => _userProfile.organizationId;
  set organizationId(String value) {
    _userProfile.organizationId = value;
    notifyListeners();
  }

  bool get isAdmin => _userProfile.isAdmin;
  set isAdmin(bool value) {
    _userProfile.isAdmin = value;
    notifyListeners();
  }

  ImageProvider get userImage => _userImage;
  set userImage(ImageProvider value) {
    _userImage = value;
    notifyListeners();
  }

  //////////////////////////////////////////////////////////////////
  // UTILITY METHODS
  //////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////
  // This function clears all of the information stored in this
  // provider
  //////////////////////////////////////////////////////////////////
  void wipe() {
    _userProfile = UserProfile.empty();
    _userImage = GENERIC_IMAGE;
    _dataLoaded = false;
    _imageLoaded = false;
    notifyListeners();
  }

  //////////////////////////////////////////////////////////////////
  // This function updates the entire user profile to the one being
  // passed in.
  //////////////////////////////////////////////////////////////////
  void updateUserProfile(UserProfile userProfile) {
    _userProfile = userProfile;
    _dataLoaded = true;
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////
  // CLOUD FIRESTORE ACCESS METHODS
  ////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////
  // Get the user profile from the DB helper and notify listeners if it is not already there
  // (notify is triggered by called method, so not done here)
  ////////////////////////////////////////////////////////////////////////////////////////////
  Future<bool> fetchUserProfileIfNeeded() async {
    // If data is missing (or empty), fetch profile
    if (_userProfile.isMissingKeyData() || !_dataLoaded) {
      bool success = await DBUserProfile.fetchUserProfileAndSyncProvider(this);
      if (success) {
        _dataLoaded = true;
      }
      return success;
      //return await fetchUserProfileImageIfNeeded();
    }

    // If made it here, we already have a profile
    return true;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  // Writes the user profile to the DB using the DB helper.
  ////////////////////////////////////////////////////////////////////////////////////////////
  Future<bool> writeUserProfileToDb() async {
    return await DBUserProfile.writeUserProfile(_userProfile);
  }

  //////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////
  // CLOUD STORAGE ACCESS METHODS
  //////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////
  // Get the user profile image from the DB helper (in GCS) and notify listeners if it is not
  // already there (notify is triggered by called method, so not done here)
  ////////////////////////////////////////////////////////////////////////////////////////////
  Future<bool> fetchUserProfileImageIfNeeded() async {
    // Ensure profile data (uid) has been loaded first
    if (!dataLoaded) {
      return false;
    }

    // Load image if not already loaded
    if (!_imageLoaded) {
      if (await DBUserProfile.fetchUserProfileImageAndSyncProvider(this)) {
        _imageLoaded = true;
        return true;
      } else {
        return false;
      }
    }

    // If made it here, we already have a profile
    return true;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  // Takes in a file (to an image) and uploads as new user profile image using the DB helper
  // (in GCS) and notifies listeners (notify is triggered by called method, so not done here)
  ////////////////////////////////////////////////////////////////////////////////////////////
  uploadAndSetNewUserProfileImage(File imageFile) async {
    // Convert file to image and set (which notifies listeners) to local profile picture
    userImage = FileImage(imageFile);

    // Upload image to Google Cloud Storage
    await DBUserProfile.uploadNewUserProfileImage(imageFile, this);
  }
}
