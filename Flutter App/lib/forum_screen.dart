import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:login_signup_1/style.dart';

part 'forum_api.dart';
part 'forum_ui.dart';

class ForumScreen extends StatefulWidget {
  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final TextEditingController _postContentController = TextEditingController();
  final TextEditingController _commentContentController = TextEditingController();
  final storage = FlutterSecureStorage();
  String? _currentUserEmail;
  bool _isLoadingEmail = true;

  List<dynamic> _posts = [];
  bool _isLoadingPosts = true;
  String? _postsError;

  String? _expandedPostId;
  Map<String, List<dynamic>> _fetchedComments = {};
  Map<String, bool> _loadingComments = {};
  bool _isPostingComment = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _postContentController.dispose();
    _commentContentController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    await _loadCurrentUserEmail();
    if (!mounted) return;
    if (_currentUserEmail != null) {
      _loadPosts();
    } else {
      setState(() {
        _isLoadingPosts = false;
        _postsError = "Could not retrieve user email. Please log in again.";
      });
    }
  }

  Future<void> _loadCurrentUserEmail() async {
    if (mounted) {
      setState(() {
        _isLoadingEmail = true;
        _postsError = null;
      });
    } else {
      _isLoadingEmail = true;
      _postsError = null;
    }

    try {
      String? email = await storage.read(key: 'email');
      if (mounted) {
        setState(() {
          _currentUserEmail = email;
          _isLoadingEmail = false;
        });
        if (email == null) {
          print("Error: Email not found in secure storage.");
        }
      } else {
        _currentUserEmail = email;
        _isLoadingEmail = false;
      }
    } catch (e) {
      print("Error reading email from storage: $e");
      if (mounted) {
        setState(() {
          _currentUserEmail = null;
          _isLoadingEmail = false;
        });
      } else {
        _currentUserEmail = null;
        _isLoadingEmail = false;
      }
    }
  }

   void _toggleComments(String postId) {
    final currentlyExpanded = _expandedPostId;
    setState(() {
      if (currentlyExpanded == postId) {
        _expandedPostId = null;
        _commentContentController.clear();
      } else {
        _expandedPostId = postId;
        _commentContentController.clear();
        if (!_fetchedComments.containsKey(postId) &&
            _loadingComments[postId] != true) {
          fetchComments(postId);
        }
      }
    });
  }

  String formatTime(String timestamp) {
    try {
      DateTime time = DateTime.parse(timestamp).toLocal();
      Duration diff = DateTime.now().difference(time);
      if (diff.inDays > 0) return '${diff.inDays}d';
      if (diff.inHours > 0) return '${diff.inHours}h';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m';
      if (diff.inSeconds > 10) return '${diff.inSeconds}s';
      return 'now';
    } catch (_) {
      return '?';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Forums'),
          backgroundColor: Color(0xFF562634),
          foregroundColor: Colors.white),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: _buildBody(),
      ),
    );
  }
}