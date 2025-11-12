import 'package:flutter/material.dart';

class NewNotePage extends StatefulWidget {
  final String? existingTitle;
  final String? existingContent;
  final Function(String)? onTitleChanged;
  final Function(String)? onContentChanged;

  const NewNotePage({
    super.key,
    this.existingTitle,
    this.existingContent,
    this.onTitleChanged,
    this.onContentChanged,
  });

  @override
  State<NewNotePage> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingTitle ?? "");
    _contentController =
        TextEditingController(text: widget.existingContent ?? "");

    _titleController.addListener(() {
      widget.onTitleChanged?.call(_titleController.text);
    });

    _contentController.addListener(() {
      widget.onContentChanged?.call(_contentController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[300],
                hintText: "Title",
                border: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[300],
                  hintText: "Write your message...",
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
