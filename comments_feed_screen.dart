import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CommentsScreen extends StatefulWidget {
  final String authToken;
  final int courseId;
  final int sectionId;
  final int postId;

  const CommentsScreen({
    Key? key,
    required this.authToken,
    required this.courseId,
    required this.sectionId,
    required this.postId,
  }) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  List<dynamic> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments'),
        headers: {'Authorization': widget.authToken},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _comments = data['comments'].map((comment) {
            comment['liked'] = comment['liked'] ?? false;
            comment['likes_count'] = comment['likes_count'] ?? 0;
            return comment;
          }).toList();
          _isLoading = false;
          _comments
              .sort((a, b) => b['date_posted'].compareTo(a['date_posted']));
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Error: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Exception: $e');
    }
  }

  Future<void> toggleLike(int commentId) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/$commentId/like'),
        headers: {'Authorization': widget.authToken},
      );

      if (response.statusCode == 200) {
        setState(() {
          _comments = _comments.map((comment) {
            if (comment['id'] == commentId) {
              comment['liked'] = !comment['liked'];
              comment['likes_count'] = comment['liked']
                  ? comment['likes_count'] + 1
                  : comment['likes_count'] - 1;
            }
            return comment;
          }).toList();
        });
        _showSnackbar('تم تغيير حالة الإعجاب.');
      } else {
        _showSnackbar('خطأ في تغيير حالة الإعجاب.');
      }
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء تغيير حالة الإعجاب.');
    }
  }

  Future<void> addComment(String commentContent) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments'),
        headers: {
          'Authorization': widget.authToken,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'body': commentContent}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _comments.add({
            'id': data['comment_id'],
            'body': commentContent,
            'date_posted': DateTime.now().toString(),
            'author': 'أنا', // يجب تحديثه باسم المستخدم الفعلي
            'liked': false,
            'likes_count': 0,
          });
          _comments
              .sort((a, b) => b['date_posted'].compareTo(a['date_posted']));
        });
        _showSnackbar('تم إضافة تعليق جديد.');
      } else {
        _showSnackbar('خطأ في إضافة التعليق.');
      }
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء إضافة التعليق.');
    }
  }

  Future<void> updateComment(int commentId, String updatedContent) async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/$commentId'),
        headers: {
          'Authorization': widget.authToken,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'body': updatedContent}),
      );

      if (response.statusCode == 200) {
        setState(() {
          for (var comment in _comments) {
            if (comment['id'] == commentId) {
              comment['body'] = updatedContent;
              break;
            }
          }
        });
        _showSnackbar('تم تحديث التعليق.');
      } else {
        _showSnackbar('خطأ في تحديث التعليق.');
      }
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء تحديث التعليق.');
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/$commentId'),
        headers: {'Authorization': widget.authToken},
      );

      if (response.statusCode == 200) {
        setState(() {
          _comments.removeWhere((comment) => comment['id'] == commentId);
        });
        _showSnackbar('تم حذف التعليق.');
      } else {
        _showSnackbar('خطأ في حذف التعليق.');
      }
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء حذف التعليق.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  void _showCommentActions(Map<String, dynamic> comment) {
    final TextEditingController _commentController = TextEditingController();
    _commentController.text = comment['body'];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('تعديل التعليق'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditCommentDialog(comment['id'], _commentController);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('حذف التعليق'),
                onTap: () {
                  Navigator.pop(context);
                  deleteComment(comment['id']);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditCommentDialog(
      int commentId, TextEditingController _commentController) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل التعليق'),
          content: TextField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: 'نص التعليق'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                updateComment(commentId, _commentController.text.trim());
              },
              child: const Text('تحديث'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التعليقات')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _comments.isEmpty
              ? const Center(child: Text('لا توجد تعليقات متاحة.'))
              : ListView.builder(
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    return ListTile(
                      title: Text(comment['body']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('تاريخ النشر: ${comment['date_posted']}'),
                          Text('عدد الإعجابات: ${comment['likes_count']}'),
                          Text('اسم المستخدم: ${comment['author']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          comment['liked']
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: comment['liked'] ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => toggleLike(comment['id']),
                      ),
                      onLongPress: () => _showCommentActions(comment),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCommentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCommentDialog() {
    final TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('أضف تعليقًا جديدًا'),
          content: TextField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: 'نص التعليق'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                addComment(_commentController.text.trim());
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }
}