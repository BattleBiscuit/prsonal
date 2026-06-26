/// Thrown when a requested resource does not exist in the database.
class NotFoundException implements Exception {
  const NotFoundException([this.message]);

  final String? message;

  @override
  String toString() {
    if (message != null) return 'NotFoundException: $message';
    return 'NotFoundException';
  }
}
