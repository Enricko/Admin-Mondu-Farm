extension StringExtension on String {
    String title() {
      return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
    }
}