import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSearch;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Zoek nieuwe vrienden...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF0C1033),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF9AC4F5),
                  width: 2,
                ),
              ),
              suffixIcon: const Icon(Icons.search, color: Color(0xFF0C1033)),
            ),
            onSubmitted: (_) => onSearch(),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: isLoading ? null : onSearch,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0C1033),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Zoek'),
        ),
      ],
    );
  }
}
