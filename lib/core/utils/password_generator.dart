String generateSecurePassword(String fullName) {
  // Frase común (puedes rotar entre varias si deseas)
  const phrase = 'A quien madruga dios le ayuda';
  const specialChar = r'$';
  const date = '06081825'; // Fundación de Bolivia (ejemplo institucional)

  // Obtener iniciales del nombre
  final initialsName = fullName
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase())
      .join();

  // Iniciales de la frase
  final initialsPhrase = phrase
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase())
      .join();

  // Construcción final
  return '$specialChar$initialsName$initialsPhrase$date$specialChar';
}
