import '../../widgets/inputs/dropdown.dart';
import 'package:flutter/material.dart';
import '../../extension/context_extensions.dart';
import 'image_constant.dart';

class Countries {
  static const List<DropdownItem> list = [
    DropdownItem(value: 'vn', label: 'Vietnam'),
    DropdownItem(value: 'us', label: 'United States'),
    DropdownItem(value: 'uk', label: 'United Kingdom'),
    DropdownItem(value: 'ca', label: 'Canada'),
    DropdownItem(value: 'au', label: 'Australia'),
    DropdownItem(value: 'de', label: 'Germany'),
    DropdownItem(value: 'fr', label: 'France'),
    DropdownItem(value: 'jp', label: 'Japan'),
    DropdownItem(value: 'kr', label: 'South Korea'),
    DropdownItem(value: 'cn', label: 'China'),
    DropdownItem(value: 'in', label: 'India'),
    DropdownItem(value: 'br', label: 'Brazil'),
    DropdownItem(value: 'mx', label: 'Mexico'),
    DropdownItem(value: 'sg', label: 'Singapore'),
    DropdownItem(value: 'my', label: 'Malaysia'),
    DropdownItem(value: 'th', label: 'Thailand'),
    DropdownItem(value: 'ph', label: 'Philippines'),
    DropdownItem(value: 'id', label: 'Indonesia'),
    DropdownItem(value: 'tw', label: 'Taiwan'),
    DropdownItem(value: 'hk', label: 'Hong Kong'),
  ];
}

class Languages {
  static const List<DropdownItem> suggested = [
    DropdownItem(value: 'en_us', label: 'English (US)'),
    DropdownItem(value: 'vi_vn', label: 'Tiếng Việt'),
  ];

  static const List<DropdownItem> others = [
    DropdownItem(value: 'ko_kr', label: '한국어 (Korean)'),
    DropdownItem(value: 'ja_jp', label: '日本語 (Japanese)'),
    DropdownItem(value: 'fr_fr', label: 'Français (French)'),
    DropdownItem(value: 'de_de', label: 'Deutsch (German)'),
    DropdownItem(value: 'zh_cn', label: '中文 (Simplified Chinese)'),
    DropdownItem(value: 'zh_tw', label: '中文 (Traditional Chinese)'),
    DropdownItem(value: 'es_es', label: 'Español (Spanish)'),
    DropdownItem(value: 'pt_br', label: 'Português (Brazilian)'),
    DropdownItem(value: 'id_id', label: 'Bahasa Indonesia'),
    DropdownItem(value: 'th_th', label: 'ภาษาไทย (Thai)'),
    DropdownItem(value: 'ms_my', label: 'Bahasa Melayu'),
    DropdownItem(value: 'hi_in', label: 'हिन्दी (Hindi)'),
  ];
}

class HelpCenterData {
  static List<FaqItem> faqs(BuildContext context) {
    final faq = context.i18n.profile.helpCenter.faq;
    return [
      FaqItem(
        category: HelpCenterCategory.general,
        question: faq.general.whatIsNozie.question,
        answer: faq.general.whatIsNozie.answer,
      ),
      FaqItem(
        category: HelpCenterCategory.service,
        question: faq.service.purchaseEbook.question,
        answer: faq.service.purchaseEbook.answer,
      ),
      FaqItem(
        category: HelpCenterCategory.account,
        question: faq.account.addPaymentMethod.question,
        answer: faq.account.addPaymentMethod.answer,
      ),
      FaqItem(
        category: HelpCenterCategory.account,
        question: faq.account.resetPassword.question,
        answer: faq.account.resetPassword.answer,
      ),
      FaqItem(
        category: HelpCenterCategory.ebook,
        question: faq.ebook.downloadOffline.question,
        answer: faq.ebook.downloadOffline.answer,
      ),
      FaqItem(
        category: HelpCenterCategory.account,
        question: faq.account.changeLanguage.question,
        answer: faq.account.changeLanguage.answer,
      ),
      FaqItem(
        category: HelpCenterCategory.service,
        question: faq.service.audiobookNotPlaying.question,
        answer: faq.service.audiobookNotPlaying.answer,
      ),
      FaqItem(
        category: HelpCenterCategory.service,
        question: faq.service.manageNotifications.question,
        answer: faq.service.manageNotifications.answer,
      ),
      FaqItem(
        category: HelpCenterCategory.service,
        question: faq.service.requestRefund.question,
        answer: faq.service.requestRefund.answer,
      ),
      FaqItem(
        category: HelpCenterCategory.account,
        question: faq.account.deleteAccount.question,
        answer: faq.account.deleteAccount.answer,
      ),
      FaqItem(
        category: HelpCenterCategory.general,
        question: faq.general.syncProgress.question,
        answer: faq.general.syncProgress.answer,
      ),
      FaqItem(
        category: HelpCenterCategory.general,
        question: faq.general.formatsSupport.question,
        answer: faq.general.formatsSupport.answer,
      ),
      FaqItem(
        category: HelpCenterCategory.service,
        question: faq.service.purchaseEbookIssue.question,
        answer: faq.service.purchaseEbookIssue.answer,
      ),
      FaqItem(
        category: HelpCenterCategory.service,
        question: faq.service.downloadEbookIssue.question,
        answer: faq.service.downloadEbookIssue.answer,
      ),
      FaqItem(
        category: HelpCenterCategory.account,
        question: faq.account.addPaymentMethodIssue.question,
        answer: faq.account.addPaymentMethodIssue.answer,
      ),
      FaqItem(
        category: HelpCenterCategory.movies,
        question: faq.movies.closeErabookAccount.question,
        answer: faq.movies.closeErabookAccount.answer,
      ),
    ];
  }

  static List<ContactOption> contacts(BuildContext context) {
    final contacts = context.i18n.profile.helpCenter.contacts;
    return [
      ContactOption(
        title: contacts.customerService.title,
        subtitle: contacts.customerService.subtitle,
        iconAsset: ImageConstant.contactSupportIcon,
      ),
      ContactOption(
        title: contacts.whatsapp.title,
        subtitle: contacts.whatsapp.subtitle,
        iconAsset: ImageConstant.contactChatIcon,
      ),
      ContactOption(
        title: contacts.website.title,
        subtitle: contacts.website.subtitle,
        iconAsset: ImageConstant.contactWebsiteIcon,
      ),
      ContactOption(
        title: contacts.facebook.title,
        subtitle: contacts.facebook.subtitle,
        iconAsset: ImageConstant.contactFacebookIcon,
      ),
      ContactOption(
        title: contacts.twitter.title,
        subtitle: contacts.twitter.subtitle,
        iconAsset: ImageConstant.contactTwitterIcon,
      ),
      ContactOption(
        title: contacts.instagram.title,
        subtitle: contacts.instagram.subtitle,
        iconAsset: ImageConstant.contactInstagramIcon,
      ),
    ];
  }
}

enum HelpCenterCategory { general, account, service, movies, ebook }

class FaqItem {
  final HelpCenterCategory category;
  final String question;
  final String answer;

  FaqItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}

class ContactOption {
  final String title;
  final String subtitle;
  final String iconAsset;

  ContactOption({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
  });
}

class Genres {
  static Map<String, String> getOptions(BuildContext context) {
    final t = context.i18n;
    return {
      'am-nhac': t.auth.register.steps.genres.list.amNhac,
      'bi-an': t.auth.register.steps.genres.list.biAn,
      'chien-tranh': t.auth.register.steps.genres.list.chienTranh,
      'chinh-kich': t.auth.register.steps.genres.list.chinhKich,
      'co-trang': t.auth.register.steps.genres.list.coTrang,
      'gia-dinh': t.auth.register.steps.genres.list.giaDinh,
      'hai-huoc': t.auth.register.steps.genres.list.haiHuoc,
      'hanh-dong': t.auth.register.steps.genres.list.hanhDong,
      'hinh-su': t.auth.register.steps.genres.list.hinhSu,
      'hoc-duong': t.auth.register.steps.genres.list.hocDuong,
      'khoa-hoc': t.auth.register.steps.genres.list.khoaHoc,
      'kinh-di': t.auth.register.steps.genres.list.kinhDi,
      'kinh-dien': t.auth.register.steps.genres.list.kinhDien,
      'phieu-luu': t.auth.register.steps.genres.list.phieuLuu,
      'phim-18': t.auth.register.steps.genres.list.phim18,
      'short-drama': t.auth.register.steps.genres.list.shortDrama,
      'tai-lieu': t.auth.register.steps.genres.list.taiLieu,
      'tam-ly': t.auth.register.steps.genres.list.tamLy,
      'than-thoai': t.auth.register.steps.genres.list.thanThoai,
      'the-thao': t.auth.register.steps.genres.list.theThao,
      'tinh-cam': t.auth.register.steps.genres.list.tinhCam,
      'vien-tuong': t.auth.register.steps.genres.list.vienTuong,
      'vo-thuat': t.auth.register.steps.genres.list.voThuat,
    };
  }
}

class Genders {
  static Map<String, String> getOptions(BuildContext context) {
    final t = context.i18n;
    return {
      'male': t.auth.register.steps.gender.choices.iAmMale,
      'female': t.auth.register.steps.gender.choices.iAmFemale,
      'other': t.auth.register.steps.gender.choices.ratherNotToSay,
    };
  }
}

class Ages {
  static Map<String, String> getOptions(BuildContext context) {
    final t = context.i18n;
    return {
      '14-17': t.auth.register.steps.age.ranges.age14to17,
      '18-24': t.auth.register.steps.age.ranges.age18to24,
      '25-29': t.auth.register.steps.age.ranges.age25to29,
      '30-34': t.auth.register.steps.age.ranges.age30to34,
      '35-39': t.auth.register.steps.age.ranges.age35to39,
      '40-44': t.auth.register.steps.age.ranges.age40to44,
      '45-49': t.auth.register.steps.age.ranges.age45to49,
      '50': t.auth.register.steps.age.ranges.age50plus,
    };
  }
}
