import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ppufeedsapp/comments_feed_screen.dart';

class PostsScreen extends StatefulWidget {
  final String authToken;
  final int courseId;
  final int sectionId;

  const PostsScreen(
      {super.key,
      required this.authToken,
      required this.courseId,
      required this.sectionId});

  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<dynamic> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts'),
        headers: {'Authorization': widget.authToken},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _posts = data['posts'];
          _isLoading = false;
          _posts.sort((a, b) => b['date_posted']
              .compareTo(a['date_posted'])); // ترتيب المنشورات بالأحدث أولاً
        });
        await fetchCommentsCount(); // جلب عدد التعليقات بعد جلب المنشورات
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

  Future<void> fetchCommentsCount() async {
    try {
      for (var post in _posts) {
        final response = await http.get(
          Uri.parse(
              'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${post['id']}/comments'),
          headers: {'Authorization': widget.authToken},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            post['no_of_comments'] = data['comments'].length;
          });
        } else {
          print('Error fetching comments: ${response.body}');
        }
      }
    } catch (e) {
      print('Exception fetching comments: $e');
    }
  }

  Future<void> addPost(String postContent) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts'),
        headers: {
          'Authorization': widget.authToken,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'body': postContent}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _posts.add({
            'id': data['post_id'],
            'body': postContent,
            'date_posted': DateTime.now().toString(),
            'author': 'أنا', // يجب تحديثه باسم المستخدم الفعلي
          });
          _posts.sort((a, b) => b['date_posted'].compareTo(a['date_posted']));
        });
        _showSnackbar('تم إضافة منشور جديد.');
      } else {
        _showSnackbar('خطأ في إضافة المنشور.');
      }
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء إضافة المنشور.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  void _showAddPostDialog() {
    final TextEditingController _postController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('أضف منشورًا جديدًا'),
          content: TextField(
            controller: _postController,
            decoration: const InputDecoration(labelText: 'نص المنشور'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                addPost(_postController.text.trim());
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المنشورات')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? const Center(child: Text('لا توجد منشورات متاحة'))
              : ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    final noOfComments = post['no_of_comments'] ?? 'غير متاح';
                    return ListTile(
                      title: Text(post['body']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('تاريخ النشر: ${post['date_posted']}'),
                          Text('اسم المحاضر: ${post['author']}'),
                          Text('عدد التعليقات: $noOfComments'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                              authToken: widget.authToken,
                              courseId: widget.courseId,
                              sectionId: widget.sectionId,
                              postId: post['id'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPostDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
