class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Email invalide';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
    if (value.length < 8) return 'Le mot de passe doit contenir au moins 8 caractères';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
    if (value != original) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName est obligatoire' : 'Ce champ est obligatoire';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
    final phoneRegex = RegExp(r'^[+]?[\d\s\-\(\)]{8,15}$');
    if (!phoneRegex.hasMatch(value)) return 'Numéro de téléphone invalide';
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value)) return 'URL invalide';
    return null;
  }

  static bool isSupportedProductUrl(String url) {
    final u = url.toLowerCase();
    return u.contains('aliexpress.com') ||
        u.contains('alibaba.com') ||
        u.contains('amazon.') ||
        u.contains('temu.com') ||
        u.contains('shein.com') ||
        u.contains('noon.com') ||
        u.contains('iherb.com') ||
        u.contains('jumia.com') ||
        u.contains('ebay.com') ||
        u.contains('etsy.com');
  }

  static String detectPlatform(String url) {
    final u = url.toLowerCase();
    if (u.contains('aliexpress.com')) return 'aliexpress';
    if (u.contains('alibaba.com')) return 'alibaba';
    if (u.contains('amazon.')) return 'amazon';
    if (u.contains('temu.com')) return 'temu';
    if (u.contains('shein.com')) return 'shein';
    if (u.contains('noon.com')) return 'noon';
    if (u.contains('iherb.com')) return 'iherb';
    if (u.contains('jumia.com')) return 'jumia';
    if (u.contains('ebay.com')) return 'ebay';
    if (u.contains('etsy.com')) return 'etsy';
    return 'other';
  }
}
