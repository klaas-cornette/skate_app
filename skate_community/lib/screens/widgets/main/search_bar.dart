import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onSearch;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchBar({
    super.key,
    required this.hintText,
    required this.onSearch,
    this.onChanged,
    this.controller,
  });

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _searchController.dispose();
    }
    super.dispose();
  }

  void _handleSearch() {
    widget.onSearch(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF0C1033)),
            onPressed: _handleSearch,
          ),
        ],
      ),
    );
  }
}
