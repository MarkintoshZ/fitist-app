String usernameValidator(String str) {
  str = str.trim();
  if (str.length < 2) return 'Username cannot be shorter than 2 characters';
  if (str.length > 20) return 'Username cannot be longer than 20 characters';
  if (!RegExp(r'^[a-zA-Z0-9]{0,20}$').hasMatch(str))
    return 'Username cannot contain special characters';
  return null;
}

String emailValidator(String str) {
  str = str.trim();
  if (!RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(str)) {
    return 'Invalid email address';
  }
  return null;
}

String passwordValidator(String str) {
  str = str.trim();
  var errorString = '';
  if (str.length < 8) errorString += '\nMinimum of 8 characters ';
  if (!RegExp(r'^(?=.*?[0-9])').hasMatch(str))
    errorString += '\nAt least 1 number ';
  if (!RegExp(r'^(?=.*?[A-z])').hasMatch(str))
    errorString += '\nAt least 1 character ';
  if (errorString.length > 0) return errorString;
  return null;
}
