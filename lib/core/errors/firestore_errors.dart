abstract final class FirestoreErrors {
  static String messageFor(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to access this data.';
      case 'unavailable':
        return 'Cannot reach the server. Check your connection and try again.';
      case 'not-found':
        return 'This item no longer exists.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}