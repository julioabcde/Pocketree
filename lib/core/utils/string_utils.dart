String nameToInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
  return (parts[0][0] + parts[1][0]).toUpperCase();
}
