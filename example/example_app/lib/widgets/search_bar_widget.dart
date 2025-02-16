import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final Function(String) onSubmitted;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: SearchBar(
        controller: controller,
        hintText: 'Search Wikipedia topics...',
        trailing: [
          if (isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: onClear,
            ),
        ],
        onSubmitted: onSubmitted,
        padding:
            const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
        elevation: const WidgetStatePropertyAll(3),
      ),
    );
  }
}
