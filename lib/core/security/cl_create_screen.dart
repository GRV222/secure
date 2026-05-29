import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'content_layer_service.dart';
import 'screen_security.dart';

// This screen is intentionally placed outside the normal features/ tree.
// Route: /cl/new — not linked from any UI element.
// Access only via private link sent through SECURE team DMs.

class CLCreateScreen extends StatefulWidget {
  const CLCreateScreen({super.key});

  @override
  State<CLCreateScreen> createState() => _CLCreateScreenState();
}

class _CLCreateScreenState extends State<CLCreateScreen> {
  final _coverCtrl = TextEditingController();
  final _originalCtrl = TextEditingController();
  final _trustedCtrl = TextEditingController();
  final _hashtagCtrl = TextEditingController();
  final _identityCtrl = TextEditingController();

  String _selectedCategory = 'traditional';
  List<String> _trustedUids = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    ScreenSecurity.enableMaxSecurity();
  }

  @override
  void dispose() {
    ScreenSecurity.disableScreenSecurity();
    _coverCtrl.dispose();
    _originalCtrl.dispose();
    _trustedCtrl.dispose();
    _hashtagCtrl.dispose();
    _identityCtrl.dispose();
    super.dispose();
  }

  void _addTrustedUid() {
    final uid = _trustedCtrl.text.trim();
    if (uid.isNotEmpty && !_trustedUids.contains(uid)) {
      setState(() {
        _trustedUids.add(uid);
        _trustedCtrl.clear();
      });
    }
  }

  Future<void> _submit() async {
    if (_coverCtrl.text.trim().isEmpty ||
        _originalCtrl.text.trim().isEmpty ||
        _trustedUids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill cover text, full text, and add at least one recipient'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    final postId = await ContentLayerService().createCLPost(
      creatorUid: uid,
      coverContent: _coverCtrl.text.trim(),
      coverMediaURL: '',
      originalContent: _originalCtrl.text.trim(),
      originalMediaURL: '',
      trustedUids: _trustedUids,
      hashtag: _hashtagCtrl.text.trim().toLowerCase(),
      category: _selectedCategory,
      identityHashtag: _identityCtrl.text.trim().toLowerCase(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (postId.isNotEmpty) {
      _coverCtrl.clear();
      _originalCtrl.clear();
      _trustedCtrl.clear();
      _hashtagCtrl.clear();
      _identityCtrl.clear();
      setState(() => _trustedUids = []);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posted successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover text (what everyone sees) ──────────────────────────────
            const Text('Post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            TextField(
              controller: _coverCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write your post…',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // ── Full version (what trusted circle sees) ───────────────────────
            const Text('Full version', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            const Text(
              'Only people you add below will see this.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _originalCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Complete content for your circle…',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // ── Hashtag ───────────────────────────────────────────────────────
            const Text('Hashtag', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            TextField(
              controller: _hashtagCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. painting',
                prefixText: '#',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ── Category ──────────────────────────────────────────────────────
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Row(
              children: ['traditional', 'digital'].map((cat) {
                final selected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? Colors.indigo : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? Colors.indigo : Colors.grey.shade400,
                        ),
                      ),
                      child: Text(
                        cat[0].toUpperCase() + cat.substring(1),
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // ── Identity hashtag ──────────────────────────────────────────────
            const Text('Identity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            TextField(
              controller: _identityCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. painter',
                prefixText: '#',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // ── Trusted recipients ────────────────────────────────────────────
            const Text('Share with', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            const Text(
              'Enter the user ID of each person who can see the full version.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _trustedCtrl,
                    decoration: const InputDecoration(
                      hintText: 'User ID',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTrustedUid(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTrustedUid,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_trustedUids.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _trustedUids.map((id) {
                  final label = id.length > 8 ? '${id.substring(0, 8)}…' : id;
                  return Chip(
                    label: Text(label),
                    onDeleted: () => setState(() => _trustedUids.remove(id)),
                  );
                }).toList(),
              ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Post'),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
