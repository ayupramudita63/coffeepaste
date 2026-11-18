import 'package:flutter/material.dart';

import '../../../shared/widgets/ios_search_field.dart';

class HomeSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String initialValue;

  const HomeSearchBar({
    super.key,
    required this.onChanged,
    this.initialValue = '',
  });

  @override
  Widget build(BuildContext context) {
    return IosSearchField(
      hint: 'Cari kopi atau minuman favoritmu...',
      onChanged: onChanged,
      initialValue: initialValue,
    );
  }
}
