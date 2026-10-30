import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  bool _isPublishing = false;
  int _charCount = 0;

  final List<String> _quickHashtags = [
    '#لانگ_دیستنس',
    '#دلتنگی',
    '#عاشقانه',
    '#فاصله',
    '#احساسات',
    '#شعر',
    '#امید',
  ];

  @override
  void initState() {
    super.initState();
    _contentController.addListener(() {
      setState(() {
        _charCount = _contentController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _publishPost() async {
    final text = _contentController.text.trim();
    if (text.isEmpty) {
      _showToast('متن پست نمی‌تواند خالی باشد', isError: true);
      return;
    }

    if (text.length > 1000) {
      _showToast('متن پست نمی‌تواند بیشتر از ۱۰۰۰ کاراکتر باشد', isError: true);
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final res = await ApiClient.post(
        ApiEndpoints.createPost,
        body: {'content': text},
      );

      if (res['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ پست شما با موفقیت منتشر شد', textAlign: TextAlign.right),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        _showToast(res['error'] ?? 'خطا در ثبت پست', isError: true);
      }
    } catch (e) {
      _showToast(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.right),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _insertHashtag(String tag) {
    final current = _contentController.text;
    final separator = current.isEmpty || current.endsWith(' ') || current.endsWith('\n') ? '' : ' ';
    _contentController.text = '$current$separator$tag ';
    _contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _contentController.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('انتشار دل‌نوشته'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ElevatedButton(
                onPressed: _isPublishing ? null : _publishPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isPublishing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('انتشار ✨', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(fontSize: 15.5, height: 1.7, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'از فاصله‌ها، احساساتت یا خاطراتت بگو...\nاینجا دل‌ها به هم وصل می‌شن.',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
              ),

              // Bottom toolbar with hashtags and character count
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.cardBorder)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hashtag Suggestions
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _quickHashtags.map((tag) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ActionChip(
                              label: Text(tag),
                              labelStyle: const TextStyle(color: AppColors.primaryLight, fontSize: 12),
                              backgroundColor: AppColors.surfaceLight,
                              side: const BorderSide(color: AppColors.cardBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              onPressed: () => _insertHashtag(tag),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${1000 - _charCount} کاراکتر باقی‌مانده',
                          style: TextStyle(
                            color: _charCount > 1000 ? AppColors.danger : AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const Text(
                          '💜 لانگ‌دیستنس',
                          style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
