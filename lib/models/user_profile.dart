class UserProfile {
  ////////////////////////////////////////////////////////////////
  // Instance variables
  ////////////////////////////////////////////////////////////////
  String _firstName = "";
  String _lastName = "";
  String _email = "";
  String _defaultRoomId = "";
  String _currentRoomId = "";
  String _organizationId = "";
  bool _isAdmin = false;

  ////////////////////////////////////////////////////////////////
  // CONSTRUCTORS
  ////////////////////////////////////////////////////////////////
  // Positional Constructor
  UserProfile(this._firstName, this._lastName, this._email, this._defaultRoomId,
      this._currentRoomId, this._organizationId, this._isAdmin);

  // Named Constructor
  UserProfile.empty() {
    _lastName = "";
    _firstName = "";
    _email = "";
    _defaultRoomId = "";
    _currentRoomId = "";
    _organizationId = "";
    _isAdmin = false;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  // Named Constructor: Creates a new User profile and populates using the JSON object and
  // email passed in as parameters.
  ////////////////////////////////////////////////////////////////////////////////////////////
  UserProfile.fromJsonDbObject(Map<String, dynamic> data, String fbAuthenticatedEmail) {
    _firstName = data["general"]["firstName"] ?? "";
    _lastName = data["general"]["lastName"] ?? "";
    _email = fbAuthenticatedEmail;
    _defaultRoomId = data["general"]["defaultRoomId"] ?? "";
    _currentRoomId = data["general"]["currentRoomId"] ?? "";
    _organizationId = data["general"]["organizationId"] ?? "";
    _isAdmin = data["admin"]["isAdmin"] ?? false;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  // SETTERS
  ////////////////////////////////////////////////////////////////////////////////////////////
  set firstName(String value) {
    _firstName = value;
  }

  set lastName(String value) {
    _lastName = value;
  }

  set email(String value) {
    _email = value;
  }

  set defaultRoomId(String value) {
    _defaultRoomId = value;
  }

  set currentRoomId(String value) {
    _currentRoomId = value;
  }

  set organizationId(String value) {
    _organizationId = value;
  }

  set isAdmin(bool value) {
    _isAdmin = value;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  // GETTERS
  ////////////////////////////////////////////////////////////////////////////////////////////
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get defaultRoomId => _defaultRoomId;
  String get currentRoomId => _currentRoomId;
  String get organizationId => _organizationId;
  bool get isAdmin => _isAdmin;

  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////
  /// UTILITY METHODS
  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////
  // Method checks to see if the user profile has been initialized
  // by checking if key data items exist
  ////////////////////////////////////////////////////////////////
  bool isMissingKeyData() {
    return (firstName.isEmpty || lastName.isEmpty || email.isEmpty);
  }

  ////////////////////////////////////////////////////////////////
  // Converts to JSON for saving to noSQL database
  ////////////////////////////////////////////////////////////////
  Map<String, dynamic> toJsonForDb() {
    // Create empty map
    Map<String, dynamic> jsonObject = {};
    Map<String, dynamic> jsonGeneral = {};
    Map<String, dynamic> jsonAdmin = {};
    jsonObject["general"] = jsonGeneral;
    jsonObject["admin"] = jsonAdmin;

    // Add all fields to the json map
    jsonObject["general"]["firstName"] = firstName;
    jsonObject["general"]["lastName"] = lastName;
    jsonObject["general"]["email"] = email;
    jsonObject["general"]["defaultRoomId"] = defaultRoomId;
    jsonObject["general"]["currentRoomId"] = currentRoomId;
    jsonObject["general"]["organizationId"] = organizationId;
    jsonObject["admin"]["isAdmin"] = isAdmin;

    // Return the JSON object
    return jsonObject;
  }
}
