import 'package:flutter/material.dart';
import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/i18n/translations.g.dart';

import '../../../core/utils/data/data.dart';
import 'help_center/widgets/faq.dart';
import 'help_center/widgets/contact.dart';
import 'help_center/widgets/help_center_tabs.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  static const _tabKeys = ['faq', 'contact'];
  static const _categoryKeys = ['all', 'general', 'account', 'service', 'movies'];

  int _activeTab = 0;
  int _activeCategory = 0;
  final Set<int> _expandedFaqs = {0};
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _activeFilter = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final t = context.i18n;
    final tabs = _tabKeys.map((key) => _tabLabel(t, key)).toList();
    final categories = _categoryKeys.map((key) => _categoryLabel(t, key)).toList();
    final faqs = HelpCenterData.faqs(context);
    final contacts = HelpCenterData.contacts(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          t.profile.helpCenter.title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: ContentWrappers.page(
        context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HelpCenterTabs(
              tabs: tabs,
              activeIndex: _activeTab,
              onTabSelected: (index) => setState(() => _activeTab = index),
            ),
            const SizedBox(height: 24),
            if (_activeTab == 0)
              ..._buildFaqSection(
                context: context,
                categories: categories,
                faqs: faqs,
              )
            else
              HelpCenterContactSection(options: contacts),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFaqSection({
    required BuildContext context,
    required List<String> categories,
    required List<FaqItem> faqs,
  }) {
    final t = context.i18n;
    return [
      HelpCenterCategoryTags(
        categories: categories,
        activeIndex: _activeCategory,
        onSelected: (index) => setState(() {
          _activeCategory = index;
          _activeFilter = '';
          _expandedFaqs.clear();
          _searchController.clear();
          _searchFocusNode.unfocus();
        }),
      ),
      const SizedBox(height: 24),
      HelpCenterSearchBar(
        controller: _searchController,
        focusNode: _searchFocusNode,
        hintText: t.common.search,
        onQueryChanged: (value) {
          setState(() {
            final trimmed = value.trim();
            if (trimmed.isEmpty && _activeFilter.isNotEmpty) {
              _activeFilter = '';
              _expandedFaqs.clear();
            }
          });
        },
      ),
      if (_searchController.text.trim().isNotEmpty) ...[
        const SizedBox(height: 16),
        HelpCenterSuggestionList(
          query: _searchController.text.trim(),
          faqs: faqs,
          onSelected: (faq) {
            _searchController
              ..text = faq.question
              ..selection = TextSelection.collapsed(
                offset: faq.question.length,
              );
            _searchFocusNode.unfocus();
            setState(() {
              _activeFilter = faq.question;
              _expandedFaqs
                ..clear()
                ..add(faqs.indexOf(faq));
            });
          },
        ),
        const SizedBox(height: 24),
      ] else ...[
        const SizedBox(height: 16),
        if (_activeFilter.isNotEmpty) ...[
          HelpCenterFilterBanner(
            label: _activeFilter,
            clearLabel: t.profile.helpCenter.filter.clear,
            onClear: () {
              setState(() {
                _activeFilter = '';
                _searchController.clear();
                _expandedFaqs.clear();
              });
            },
          ),
          const SizedBox(height: 24),
        ],
        const SizedBox(height: 24),
      ],
      ..._buildFaqList(context, faqs),
    ];
  }

  List<Widget> _buildFaqList(BuildContext context, List<FaqItem> faqs) {
    final t = context.i18n;
    Iterable<FaqItem> items = faqs;

    final selectedCategoryKey = _categoryKeys[_activeCategory];
    if (selectedCategoryKey != 'all') {
      final category = _categoryFromKey(selectedCategoryKey);
      if (category != null) {
        items = items.where((faq) => faq.category == category);
      }
    }

    if (_activeFilter.isNotEmpty) {
      items = items.where((faq) => faq.question == _activeFilter);
    }

    final itemList = items.toList();

    if (itemList.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              t.profile.helpCenter.search.noResults,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.getTextSecondary(context),
              ),
            ),
          ),
        ),
      ];
    }

    return [
      for (var i = 0; i < itemList.length; i++) ...[
        _buildFaqTile(faqs, itemList[i]),
        if (i != itemList.length - 1) const SizedBox(height: 16),
      ],
      const SizedBox(height: 24),
    ];
  }

  Widget _buildFaqTile(List<FaqItem> faqs, FaqItem faq) {
    final originalIndex = faqs.indexOf(faq);
    return HelpCenterFaqTile(
      faq: faq,
      isExpanded: _expandedFaqs.contains(originalIndex),
      onPressed: () {
        setState(() {
          if (_expandedFaqs.contains(originalIndex)) {
            _expandedFaqs.remove(originalIndex);
          } else {
            _expandedFaqs.add(originalIndex);
          }
        });
      },
    );
  }
}

String _tabLabel(Translations t, String key) {
  switch (key) {
    case 'faq':
      return t.profile.helpCenter.tabs.faq;
    case 'contact':
      return t.profile.helpCenter.tabs.contact;
  }
  return key;
}

String _categoryLabel(Translations t, String key) {
  switch (key) {
    case 'all':
      return t.profile.helpCenter.categories.all;
    case 'general':
      return t.profile.helpCenter.categories.general;
    case 'account':
      return t.profile.helpCenter.categories.account;
    case 'service':
      return t.profile.helpCenter.categories.service;
    case 'movies':
      return t.profile.helpCenter.categories.movies;
    case 'ebook':
      return t.profile.helpCenter.categories.ebook;
  }
  return key;
}

HelpCenterCategory? _categoryFromKey(String key) {
  switch (key) {
    case 'general':
      return HelpCenterCategory.general;
    case 'account':
      return HelpCenterCategory.account;
    case 'service':
      return HelpCenterCategory.service;
    case 'movies':
      return HelpCenterCategory.movies;
    case 'ebook':
      return HelpCenterCategory.ebook;
    default:
      return null;
  }
}
