import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// ---------------------------------------------------------------------------
// AppLocalizations — manual implementation (no code generation required)
// Supports: French (fr) · Arabic (ar) · English (en)
// ---------------------------------------------------------------------------

class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(Locale('fr'));
  }

  static const delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('fr'),
    Locale('ar'),
    Locale('en'),
  ];

  String _t({required String fr, String? ar, String? en}) {
    switch (locale.languageCode) {
      case 'ar':
        return ar ?? fr;
      case 'en':
        return en ?? fr;
      default:
        return fr;
    }
  }

  // ── App ────────────────────────────────────────────────────────────────────
  String get appName => _t(fr: 'Wagaf', ar: 'وگاف', en: 'Wagaf');
  String get appSlogan => _t(
        fr: 'Wagaf vous accompagne partout. Avec Wagaf, tout devient plus simple.',
        ar: 'وگافك ف كل أرض ، مع وگاف كلشي ايصح',
        en: 'Wagaf goes wherever you go. With Wagaf, everything becomes easier.',
      );
  String get appTagline => _t(
        fr: 'Votre passerelle vers le shopping mondial',
        ar: 'بوابتك للتسوق العالمي',
        en: 'Your gateway to global shopping',
      );

  // ── Auth ───────────────────────────────────────────────────────────────────
  String get loginTitle => _t(fr: 'Connexion', ar: 'تسجيل الدخول', en: 'Login');
  String get loginSubtitle => _t(
        fr: 'Accédez à votre espace Wagaf',
        ar: 'ادخل إلى مساحة وگاف',
        en: 'Access your Wagaf space',
      );
  String get registerTitle =>
      _t(fr: "S'inscrire", ar: 'إنشاء حساب', en: 'Sign Up');
  String get registerSubtitle => _t(
        fr: 'Rejoignez Wagaf et commandez depuis le monde entier',
        ar: 'انضم إلى وگاف واطلب من أي مكان في العالم',
        en: 'Join Wagaf and order from anywhere in the world',
      );
  String get logout =>
      _t(fr: 'Déconnexion', ar: 'تسجيل الخروج', en: 'Logout');
  String get email =>
      _t(fr: 'Email', ar: 'البريد الإلكتروني', en: 'Email');
  String get password =>
      _t(fr: 'Mot de passe', ar: 'كلمة المرور', en: 'Password');
  String get confirmPassword => _t(
        fr: 'Confirmer le mot de passe',
        ar: 'تأكيد كلمة المرور',
        en: 'Confirm Password',
      );
  String get forgotPassword => _t(
        fr: 'Mot de passe oublié ?',
        ar: 'نسيت كلمة المرور؟',
        en: 'Forgot Password?',
      );
  String get resetPassword => _t(
        fr: 'Réinitialiser le mot de passe',
        ar: 'إعادة تعيين كلمة المرور',
        en: 'Reset Password',
      );
  String get fullName =>
      _t(fr: 'Nom complet', ar: 'الاسم الكامل', en: 'Full Name');
  String get phone => _t(fr: 'Téléphone', ar: 'الهاتف', en: 'Phone');
  String get city => _t(fr: 'Ville', ar: 'المدينة', en: 'City');
  String get noAccount => _t(
        fr: 'Pas encore de compte ? ',
        ar: 'ليس لديك حساب؟ ',
        en: 'No account yet? ',
      );
  String get hasAccount => _t(
        fr: 'Déjà un compte ? ',
        ar: 'لديك حساب بالفعل؟ ',
        en: 'Already have an account? ',
      );
  String get signIn =>
      _t(fr: 'Se connecter', ar: 'تسجيل الدخول', en: 'Sign In');
  String get signUp =>
      _t(fr: 'Créer un compte', ar: 'إنشاء حساب', en: 'Create Account');
  String get welcomeBack =>
      _t(fr: 'Bon retour !', ar: 'مرحباً بعودتك!', en: 'Welcome back!');
  String get createAccount => _t(
        fr: 'Créer votre compte',
        ar: 'أنشئ حسابك',
        en: 'Create your account',
      );
  String get sendResetLink => _t(
        fr: 'Envoyer le lien',
        ar: 'إرسال الرابط',
        en: 'Send Reset Link',
      );

  // ── Home ───────────────────────────────────────────────────────────────────
  String greetingUser(String name) => _t(
        fr: 'Salam $name 👋',
        ar: 'السلام عليكم $name 👋',
        en: 'Hello $name 👋',
      );
  String get homeSubtitle => _t(
        fr: "Que souhaitez-vous commander aujourd'hui ?",
        ar: 'ماذا تريد أن تطلب اليوم؟',
        en: 'What would you like to order today?',
      );
  String get pasteLinkHint => _t(
        fr: 'Collez le lien de votre produit ici...',
        ar: 'الصق رابط منتجك هنا...',
        en: 'Paste your product link here...',
      );
  String get analyzeLink =>
      _t(fr: 'Analyser le lien', ar: 'تحليل الرابط', en: 'Analyze Link');
  String get popularProducts => _t(
        fr: 'Produits populaires',
        ar: 'المنتجات الشائعة',
        en: 'Popular Products',
      );
  String get seeAll => _t(fr: 'Voir tout', ar: 'عرض الكل', en: 'See all');
  String get importProduct => _t(
        fr: 'Importer un produit',
        ar: 'استيراد منتج',
        en: 'Import a product',
      );
  String get howItWorks => _t(
        fr: 'Comment\nça marche',
        ar: 'كيف\nيعمل؟',
        en: 'How it\nworks',
      );
  String get orderWorldwide => _t(
        fr: 'Commandez\npartout dans\nle monde',
        ar: 'اطلب\nمن أي مكان\nفي العالم',
        en: 'Order from\nanywhere in\nthe world',
      );
  String get heroSubtitle => _t(
        fr: 'AliExpress, Amazon, Temu, SHEIN\net plus encore livrés en Mauritanie.',
        ar: 'AliExpress وAmazon وTemu وSHEIN\nوأكثر تُسلَّم في موريتانيا.',
        en: 'AliExpress, Amazon, Temu, SHEIN\nand more delivered to Mauritania.',
      );

  // ── Product ────────────────────────────────────────────────────────────────
  String get productDetails => _t(
        fr: 'Détails du produit',
        ar: 'تفاصيل المنتج',
        en: 'Product Details',
      );
  String get productPrice =>
      _t(fr: 'Prix produit', ar: 'سعر المنتج', en: 'Product Price');
  String get shippingFees =>
      _t(fr: 'Frais de transport', ar: 'رسوم الشحن', en: 'Shipping Fees');
  String get serviceFees =>
      _t(fr: 'Frais de service', ar: 'رسوم الخدمة', en: 'Service Fees');
  String get total => _t(fr: 'Total', ar: 'المجموع', en: 'Total');
  String get addToCart =>
      _t(fr: 'Ajouter au panier', ar: 'أضف إلى السلة', en: 'Add to Cart');
  String get orderNow =>
      _t(fr: 'Commander maintenant', ar: 'اطلب الآن', en: 'Order Now');
  String get quantity =>
      _t(fr: 'Quantité', ar: 'الكمية', en: 'Quantity');

  // ── Cart ───────────────────────────────────────────────────────────────────
  String get cart => _t(fr: 'Panier', ar: 'سلة التسوق', en: 'Cart');
  String get cartEmpty => _t(
        fr: 'Votre panier est vide',
        ar: 'سلتك فارغة',
        en: 'Your cart is empty',
      );
  String get checkout =>
      _t(fr: 'Passer la commande', ar: 'إتمام الطلب', en: 'Checkout');

  // ── Orders ─────────────────────────────────────────────────────────────────
  String get myOrders =>
      _t(fr: 'Mes commandes', ar: 'طلباتي', en: 'My Orders');
  String get orderDetails =>
      _t(fr: 'Détails commande', ar: 'تفاصيل الطلب', en: 'Order Details');
  String get noOrders => _t(
        fr: "Aucune commande pour l'instant",
        ar: 'لا توجد طلبات بعد',
        en: 'No orders yet',
      );
  String get orderNumber =>
      _t(fr: 'Commande #', ar: 'طلب #', en: 'Order #');
  String get orderedOn =>
      _t(fr: 'Commandé le', ar: 'تاريخ الطلب', en: 'Ordered on');

  // ── Order Status ───────────────────────────────────────────────────────────
  String get statusPending =>
      _t(fr: 'En attente', ar: 'في الانتظار', en: 'Pending');
  String get statusPaymentValidated =>
      _t(fr: 'Paiement validé', ar: 'الدفع مؤكد', en: 'Payment Validated');
  String get statusPurchased =>
      _t(fr: 'Produit acheté', ar: 'تم الشراء', en: 'Product Purchased');
  String get statusInTransit =>
      _t(fr: 'En transit', ar: 'في الطريق', en: 'In Transit');
  String get statusArrivedMR => _t(
        fr: 'Arrivé en Mauritanie',
        ar: 'وصل إلى موريتانيا',
        en: 'Arrived in Mauritania',
      );
  String get statusDelivered =>
      _t(fr: 'Livré', ar: 'تم التوصيل', en: 'Delivered');
  String get statusCancelled =>
      _t(fr: 'Annulé', ar: 'ملغي', en: 'Cancelled');

  // ── Tracking ───────────────────────────────────────────────────────────────
  String get tracking =>
      _t(fr: 'Suivi de commande', ar: 'تتبع الطلب', en: 'Order Tracking');
  String get trackOrder =>
      _t(fr: 'Suivre ma commande', ar: 'تتبع طلبي', en: 'Track My Order');

  // ── Profile ────────────────────────────────────────────────────────────────
  String get profile =>
      _t(fr: 'Profil', ar: 'الملف الشخصي', en: 'Profile');
  String get editProfile => _t(
        fr: 'Modifier le profil',
        ar: 'تعديل الملف الشخصي',
        en: 'Edit Profile',
      );
  String get orderHistory => _t(
        fr: 'Mes commandes',
        ar: 'طلباتي',
        en: 'My Orders',
      );
  String get notifications =>
      _t(fr: 'Notifications', ar: 'الإشعارات', en: 'Notifications');
  String get settings =>
      _t(fr: 'Paramètres', ar: 'الإعدادات', en: 'Settings');
  String get help =>
      _t(fr: 'Aide & Support', ar: 'المساعدة والدعم', en: 'Help & Support');
  String get about => _t(
        fr: 'À propos de Wagaf',
        ar: 'حول وگاف',
        en: 'About Wagaf',
      );
  String get language => _t(fr: 'Langue', ar: 'اللغة', en: 'Language');
  String get changeLanguage => _t(
        fr: 'Changer la langue',
        ar: 'تغيير اللغة',
        en: 'Change Language',
      );
  String get signOut =>
      _t(fr: 'Se déconnecter', ar: 'تسجيل الخروج', en: 'Sign Out');
  String get inTransit =>
      _t(fr: 'En transit', ar: 'في الطريق', en: 'In Transit');
  String get delivered =>
      _t(fr: 'Livrés', ar: 'مُسلَّم', en: 'Delivered');
  String get totalSpent =>
      _t(fr: 'Total dépensé', ar: 'الإجمالي المنفق', en: 'Total Spent');
  String get information =>
      _t(fr: 'Informations', ar: 'المعلومات', en: 'Information');
  String get address => _t(fr: 'Adresse', ar: 'العنوان', en: 'Address');
  String get deliveryAddress => _t(
        fr: 'Adresse de livraison',
        ar: 'عنوان التوصيل',
        en: 'Delivery Address',
      );
  String get administration =>
      _t(fr: 'Administration', ar: 'الإدارة', en: 'Administration');
  String get adminDashboard =>
      _t(fr: 'Dashboard Admin', ar: 'لوحة التحكم', en: 'Admin Dashboard');
  String get loyaltyWelcome =>
      _t(fr: 'Bienvenue chez Wagaf !', ar: 'مرحباً بك في وگاف!', en: 'Welcome to Wagaf!');
  String get loyalty =>
      _t(fr: 'Fidélité', ar: 'الولاء', en: 'Loyalty');
  String get save => _t(fr: 'Enregistrer', ar: 'حفظ', en: 'Save');
  String get profileUpdated => _t(
        fr: 'Profil mis à jour avec succès',
        ar: 'تم تحديث الملف الشخصي بنجاح',
        en: 'Profile updated successfully',
      );
  String get profileUpdateError => _t(
        fr: 'Erreur lors de la mise à jour',
        ar: 'خطأ في التحديث',
        en: 'Error updating profile',
      );

  // ── Payment ────────────────────────────────────────────────────────────────
  String get payment => _t(fr: 'Paiement', ar: 'الدفع', en: 'Payment');
  String get paymentMethod => _t(
        fr: 'Méthode de paiement',
        ar: 'طريقة الدفع',
        en: 'Payment Method',
      );
  String get paymentPending => _t(
        fr: 'En attente de paiement',
        ar: 'في انتظار الدفع',
        en: 'Pending Payment',
      );
  String get paymentValidated =>
      _t(fr: 'Paiement validé', ar: 'الدفع مؤكد', en: 'Payment Validated');
  String get paymentRejected =>
      _t(fr: 'Paiement refusé', ar: 'الدفع مرفوض', en: 'Payment Rejected');

  // ── Admin ──────────────────────────────────────────────────────────────────
  String get adminDashboardTitle =>
      _t(fr: 'Tableau de bord', ar: 'لوحة التحكم', en: 'Dashboard');
  String get totalUsers =>
      _t(fr: 'Utilisateurs', ar: 'المستخدمون', en: 'Users');
  String get totalOrders =>
      _t(fr: 'Commandes', ar: 'الطلبات', en: 'Orders');
  String get totalRevenue =>
      _t(fr: 'Revenus', ar: 'الإيرادات', en: 'Revenue');
  String get manageOrders => _t(
        fr: 'Gérer les commandes',
        ar: 'إدارة الطلبات',
        en: 'Manage Orders',
      );
  String get manageUsers => _t(
        fr: 'Gérer les utilisateurs',
        ar: 'إدارة المستخدمين',
        en: 'Manage Users',
      );

  // ── Errors ─────────────────────────────────────────────────────────────────
  String get errorGeneral => _t(
        fr: 'Une erreur est survenue',
        ar: 'حدث خطأ',
        en: 'An error occurred',
      );
  String get errorNetwork => _t(
        fr: 'Vérifiez votre connexion internet',
        ar: 'تحقق من اتصالك بالإنترنت',
        en: 'Check your internet connection',
      );
  String get errorInvalidUrl => _t(
        fr: 'URL invalide ou non supportée',
        ar: 'رابط غير صالح أو غير مدعوم',
        en: 'Invalid or unsupported URL',
      );
  String get errorEmailInvalid =>
      _t(fr: 'Email invalide', ar: 'بريد إلكتروني غير صالح', en: 'Invalid email');
  String get errorPasswordTooShort => _t(
        fr: 'Le mot de passe doit contenir au moins 8 caractères',
        ar: 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل',
        en: 'Password must be at least 8 characters',
      );
  String get errorPasswordMismatch => _t(
        fr: 'Les mots de passe ne correspondent pas',
        ar: 'كلمتا المرور غير متطابقتين',
        en: 'Passwords do not match',
      );
  String get errorFieldRequired => _t(
        fr: 'Ce champ est obligatoire',
        ar: 'هذا الحقل مطلوب',
        en: 'This field is required',
      );

  // ── Success ────────────────────────────────────────────────────────────────
  String get successOrderPlaced => _t(
        fr: 'Commande passée avec succès !',
        ar: 'تم تقديم الطلب بنجاح!',
        en: 'Order placed successfully!',
      );
  String get successProfileUpdated =>
      _t(fr: 'Profil mis à jour', ar: 'تم تحديث الملف الشخصي', en: 'Profile updated');
  String get successPasswordReset => _t(
        fr: 'Email de réinitialisation envoyé',
        ar: 'تم إرسال بريد إعادة التعيين',
        en: 'Reset email sent',
      );

  // ── Loading ────────────────────────────────────────────────────────────────
  String get loading =>
      _t(fr: 'Chargement...', ar: 'جاري التحميل...', en: 'Loading...');
  String get retry => _t(fr: 'Réessayer', ar: 'إعادة المحاولة', en: 'Retry');
  String get cancel => _t(fr: 'Annuler', ar: 'إلغاء', en: 'Cancel');
  String get confirm => _t(fr: 'Confirmer', ar: 'تأكيد', en: 'Confirm');
  String get close => _t(fr: 'Fermer', ar: 'إغلاق', en: 'Close');
  String get back => _t(fr: 'Retour', ar: 'رجوع', en: 'Back');

  // ── Onboarding ─────────────────────────────────────────────────────────────
  String get onboarding1Title => appName;
  String get onboarding1Body => _t(
        fr: 'Commandez partout dans le monde depuis votre téléphone.',
        ar: 'اطلب من أي مكان في العالم من هاتفك.',
        en: 'Order from anywhere in the world from your phone.',
      );
  String get onboarding2Title =>
      _t(fr: 'Copiez simplement un lien', ar: 'انسخ ببساطة رابطاً', en: 'Simply copy a link');
  String get onboarding2Body => _t(
        fr: "Collez un lien AliExpress, Alibaba, Amazon ou Temu et nous nous occupons du reste.",
        ar: 'الصق رابطاً من AliExpress أو Alibaba أو Amazon أو Temu وسنهتم بالباقي.',
        en: "Paste an AliExpress, Alibaba, Amazon or Temu link and we'll handle the rest.",
      );
  String get onboarding3Title => _t(
        fr: "Livraison jusqu'en Mauritanie",
        ar: 'التوصيل إلى موريتانيا',
        en: 'Delivery to Mauritania',
      );
  String get onboarding3Body => _t(
        fr: 'Nous importons vos produits et les livrons directement chez vous.',
        ar: 'نستورد منتجاتك ونوصلها إليك مباشرة.',
        en: 'We import your products and deliver them directly to you.',
      );
  String get onboarding4Title => _t(
        fr: 'Suivez vos commandes en temps réel',
        ar: 'تتبع طلباتك في الوقت الفعلي',
        en: 'Track your orders in real time',
      );
  String get onboarding4Body => _t(
        fr: 'Recevez des notifications et suivez chaque étape de votre commande.',
        ar: 'تلقَّ إشعارات وتتبع كل خطوة من طلبك.',
        en: 'Receive notifications and track every step of your order.',
      );
  String get getStarted =>
      _t(fr: 'Commencer', ar: 'ابدأ', en: 'Get Started');
  String get skip => _t(fr: 'Passer', ar: 'تخطي', en: 'Skip');
  String get next => _t(fr: 'Suivant', ar: 'التالي', en: 'Next');
  String get selectLanguage =>
      _t(fr: 'Choisir la langue', ar: 'اختر اللغة', en: 'Choose language');
}

// ---------------------------------------------------------------------------
// Extension for convenient access
// ---------------------------------------------------------------------------

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

// ---------------------------------------------------------------------------
// Delegate
// ---------------------------------------------------------------------------

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['fr', 'ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
