import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final isNotEmpty = _controller.text.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(153, 153, 153, 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardAppearance: Brightness.dark, // use dark keyboard
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(
                  color: Color.fromRGBO(60, 60, 67, 0.6),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color.fromRGBO(60, 60, 67, 0.6),
                ),
                suffixIcon: isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Color.fromRGBO(60, 60, 67, 0.6),
                        ),
                        onPressed: () {
                          _controller.clear();
                          // close keyboard when search is cleared/closed
                          _focusNode.unfocus();
                          setState(() {});
                        },
                      )
                    :
                    // Else speech icon
                    const Icon(
                      Icons.mic,
                      color: Color.fromRGBO(60, 60, 67, 0.6),
                    ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}