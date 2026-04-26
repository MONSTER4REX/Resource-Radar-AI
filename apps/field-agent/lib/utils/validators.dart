/// Form field validators for the signal submission form.
class Validators {
  /// Validate ward/area ID.
  static String? validateWardId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ward/Area ID is required';
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid ward/area identifier';
    }
    return null;
  }

  /// Validate people count.
  static String? validatePeopleCount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'People count is required';
    }
    final count = int.tryParse(value);
    if (count == null || count < 1) {
      return 'Enter a number ≥ 1';
    }
    if (count > 99999) {
      return 'Please verify — count seems very high';
    }
    return null;
  }

  /// Validate notes (optional field).
  static String? validateNotes(String? value) {
    if (value != null && value.length > 2000) {
      return 'Notes must be under 2000 characters';
    }
    return null;
  }
}
