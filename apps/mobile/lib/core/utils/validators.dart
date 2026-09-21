class Validators {
  static String? phone(String? val) {
    if (val == null || val.isEmpty) return 'Phone is required';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(val)) return 'Invalid phone number';
    return null;
  }
  static String? email(String? val) {
    if (val == null || val.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) return 'Invalid email';
    return null;
  }
  static String? required(String? val) {
    if (val == null || val.isEmpty) return 'This field is required';
    return null;
  }
  static String? minLength(String? val, int min) {
    if (val == null || val.length < min) return 'Minimum length is $min';
    return null;
  }
  static String? password(String? val) {
    if (val == null || val.isEmpty) return 'Password is required';
    if (val.length < 6) return 'Password too short';
    return null;
  }
}
