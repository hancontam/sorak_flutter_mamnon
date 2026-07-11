String normalizeVietnamese(String input) {
  var value = input.toLowerCase().trim();
  const replacements = <String, String>{
    'àáạảãâầấậẩẫăằắặẳẵ': 'a',
    'èéẹẻẽêềếệểễ': 'e',
    'ìíịỉĩ': 'i',
    'òóọỏõôồốộổỗơờớợởỡ': 'o',
    'ùúụủũưừứựửữ': 'u',
    'ỳýỵỷỹ': 'y',
    'đ': 'd',
  };

  for (final entry in replacements.entries) {
    for (final character in entry.key.split('')) {
      value = value.replaceAll(character, entry.value);
    }
  }

  return value;
}
