import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/resources/color_manager.dart';

class DoctorNotesView extends StatefulWidget {
  const DoctorNotesView({super.key});

  @override
  State<DoctorNotesView> createState() => _DoctorNotesViewState();
}

class _DoctorNotesViewState extends State<DoctorNotesView> {
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getStringList('doctor_notes') ?? [];
    setState(() {
      _notes = notesString.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      _isLoading = false;
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = _notes.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('doctor_notes', notesString);
  }

  void _addOrEditNote({Map<String, dynamic>? existingNote, int? index}) {
    final titleController = TextEditingController(text: existingNote?['title'] ?? '');
    final contentController = TextEditingController(text: existingNote?['content'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          existingNote == null ? 'New Note' : 'Edit Note',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (titleController.text.trim().isEmpty && contentController.text.trim().isEmpty) {
                Navigator.pop(context);
                return;
              }
              setState(() {
                final note = {
                  'id': existingNote?['id'] ?? DateTime.now().toIso8601String(),
                  'title': titleController.text.trim(),
                  'content': contentController.text.trim(),
                  'date': DateTime.now().toIso8601String(),
                };
                if (index != null) {
                  _notes[index] = note;
                } else {
                  _notes.insert(0, note);
                }
              });
              _saveNotes();
              Navigator.pop(context);
            },
            child: Text('Save', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
    _saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'My Notes',
          style: GoogleFonts.cairo(color: ColorManager.headlineText, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorManager.headlineText),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_note_rounded, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No notes yet',
                        style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add a new note.',
                        style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    final date = DateTime.parse(note['date']);
                    final formattedDate = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 1,
                      shadowColor: Colors.black12,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          note['title']?.isNotEmpty == true ? note['title'] : 'Untitled',
                          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              note['content'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formattedDate,
                              style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteNote(index),
                        ),
                        onTap: () => _addOrEditNote(existingNote: note, index: index),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorManager.primary,
        onPressed: () => _addOrEditNote(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
