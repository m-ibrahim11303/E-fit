import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ForumScreen extends StatefulWidget {
  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final TextEditingController _postContentController = TextEditingController();
  final TextEditingController _commentContentController = TextEditingController();
  final String currentUserEmail = "muiz@gmail.com";

  // State for Posts
  List<dynamic> _posts = [];
  bool _isLoadingPosts = true;
  String? _postsError;

  // State for Comments
  String? _expandedPostId;
  Map<String, List<dynamic>> _fetchedComments = {};
  Map<String, bool> _loadingComments = {};
  bool _isPostingComment = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _postContentController.dispose();
    _commentContentController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts({ bool showLoading = true }) async {
    if (showLoading && mounted) {
      setState(() { _isLoadingPosts = true; _postsError = null; });
    }
    try {
      final response = await http.get(Uri.parse('https://e-fit-backend.onrender.com/post'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        // Decode and immediately reverse the list before setting state
        List<dynamic> fetchedPosts = jsonDecode(response.body);
        setState(() {
          _posts = fetchedPosts.reversed.toList(); // Reverse here
          _isLoadingPosts = false;
        });
      } else {
        throw Exception('Failed to load posts. Status: ${response.statusCode}');
      }
    } catch (e) {
       print("Error fetching posts: $e");
       if(mounted) {
          setState(() {
             _postsError = 'Failed to load posts: $e';
             _isLoadingPosts = false;
          });
       }
    }
  }

  Future<List<dynamic>> fetchComments(String postId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _loadingComments[postId] == true && !_fetchedComments.containsKey(postId)) return [];
    if (!forceRefresh && _fetchedComments.containsKey(postId)) return _fetchedComments[postId]!;

    if (mounted) setState(() { _loadingComments[postId] = true; });

    try {
      final uri = Uri.parse('https://e-fit-backend.onrender.com/comment/$postId');
      final response = await http.get(uri);
      if (!mounted) return _fetchedComments[postId] ?? [];
      if (response.statusCode == 200) {
        final List<dynamic> comments = jsonDecode(response.body);
        if (mounted) setState(() { _fetchedComments[postId] = comments; });
        return comments;
      } else {
         print('Failed load comments ${postId}. Status: ${response.statusCode}');
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed load comments: ${response.reasonPhrase}')));
         return _fetchedComments[postId] ?? [];
      }
    } catch (e) {
      if (!mounted) return _fetchedComments[postId] ?? [];
      print("Error fetching comments ${postId}: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading comments: $e')));
      return _fetchedComments[postId] ?? [];
    } finally {
      if (mounted && _loadingComments.containsKey(postId)) {
        setState(() { _loadingComments.remove(postId); });
      }
    }
  }

  Future<void> _createPost(BuildContext context) async {
    if (_postContentController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter content')));
      return;
    }
    try {
      final response = await http.post(Uri.parse('https://e-fit-backend.onrender.com/post'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': currentUserEmail, 'content': _postContentController.text}));
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        _postContentController.clear();
        await _loadPosts(showLoading: false); // Reload posts (will be reversed again)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post created!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed create post: ${response.body}')));
      }
    } catch (e) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating post: $e')));
    }
  }

  Future<void> _postComment(String postId) async {
    final content = _commentContentController.text.trim();
    if (content.isEmpty) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter comment')));
       return;
    }
     if (!mounted) return;
     setState(() => _isPostingComment = true );
     try {
       final response = await http.post(Uri.parse('https://e-fit-backend.onrender.com/comment'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email': currentUserEmail, 'postId': postId, 'content': content}));
       if (!mounted) return;
       if (response.statusCode == 200 || response.statusCode == 201) {
         _commentContentController.clear();
         await fetchComments(postId, forceRefresh: true); // Refresh comments
       } else {
         print('Failed post comment. Status: ${response.statusCode}, Body: ${response.body}');
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed post comment: ${response.reasonPhrase ?? response.body}')));
       }
     } catch (e) {
       if (!mounted) return;
       print("Error posting comment: $e");
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error posting comment: $e')));
     } finally {
        if(mounted) setState(() => _isPostingComment = false);
     }
   }

  Future<void> _handlePostLike(String postId) async {
    final postIndex = _posts.indexWhere((p) => p['_id'] == postId);
    if (postIndex == -1 || !mounted) return;

    final originalLikes = _posts[postIndex]['likes'] ?? 0;
    setState(() { _posts[postIndex]['likes'] = originalLikes + 1; });

    try {
      final response = await http.post(Uri.parse('https://e-fit-backend.onrender.com/post/$postId/like'));
      if (!mounted) return;
      if (response.statusCode != 200 && response.statusCode != 201) {
         if(mounted) setState(() { _posts[postIndex]['likes'] = originalLikes; });
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to like post: ${response.body}')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _posts[postIndex]['likes'] = originalLikes; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error liking post: $e')));
    }
  }

  Future<void> _handlePostDislike(String postId) async {
    final postIndex = _posts.indexWhere((p) => p['_id'] == postId);
    if (postIndex == -1 || !mounted) return;

    final originalDislikes = _posts[postIndex]['dislikes'] ?? 0;
    setState(() { _posts[postIndex]['dislikes'] = originalDislikes + 1; });

    try {
      final response = await http.post(Uri.parse('https://e-fit-backend.onrender.com/post/$postId/dislike'));
      if (!mounted) return;
      if (response.statusCode != 200 && response.statusCode != 201) {
         if(mounted) setState(() { _posts[postIndex]['dislikes'] = originalDislikes; });
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to dislike post: ${response.body}')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _posts[postIndex]['dislikes'] = originalDislikes; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error disliking post: $e')));
    }
  }

  Future<void> _handleCommentLike(String commentId, String postId) async {
     try {
       final response = await http.post(Uri.parse('https://e-fit-backend.onrender.com/comment/$commentId/like'));
       if (!mounted) return;
       if (response.statusCode == 200 || response.statusCode == 201) {
         await fetchComments(postId, forceRefresh: true); // Refresh comments
       } else {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed like comment: ${response.body}')));
       }
     } catch (e) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error liking comment: $e')));
     }
   }

   Future<void> _handleCommentDislike(String commentId, String postId) async {
     try {
       final response = await http.post(Uri.parse('https://e-fit-backend.onrender.com/comment/$commentId/dislike'));
       if (!mounted) return;
       if (response.statusCode == 200 || response.statusCode == 201) {
         await fetchComments(postId, forceRefresh: true); // Refresh comments
       } else {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed dislike comment: ${response.body}')));
       }
     } catch (e) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error disliking comment: $e')));
     }
   }

  void _toggleComments(String postId) {
    final currentlyExpanded = _expandedPostId;
    setState(() {
      if (currentlyExpanded == postId) {
        _expandedPostId = null; _commentContentController.clear();
      } else {
        _expandedPostId = postId; _commentContentController.clear();
        if (!_fetchedComments.containsKey(postId) && _loadingComments[postId] != true) {
          fetchComments(postId);
        }
      }
    });
  }

  String formatTime(String timestamp) {
    try {
      DateTime time = DateTime.parse(timestamp).toLocal();
      Duration diff = DateTime.now().difference(time);
      if (diff.inDays > 0) return '${diff.inDays}d'; if (diff.inHours > 0) return '${diff.inHours}h';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m'; if (diff.inSeconds > 10) return '${diff.inSeconds}s';
      return 'now';
    } catch (_) { return '?'; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forums'), backgroundColor: Color(0xFF562634), foregroundColor: Colors.white),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
     if (_isLoadingPosts) return Center(child: CircularProgressIndicator(color: Color(0xFF562634)));
     if (_postsError != null) return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_postsError!, textAlign: TextAlign.center)));
     return RefreshIndicator(
        onRefresh: () => _loadPosts(showLoading: false),
        child: _buildPostList(context), // Pass context only
      );
  }

  // Removed posts parameter as it uses the state `_posts`
  Widget _buildPostList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _posts.length + 1, // Use state list length
      itemBuilder: (context, index) {
        if (index == 0) { // Create Post Card
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 3, margin: EdgeInsets.only(bottom: 16),
            child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Create New Post', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(height: 12),
                TextField(controller: _postContentController, decoration: InputDecoration(hintText: 'Share your thoughts...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.grey[100]), maxLines: 3), SizedBox(height: 12),
                Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: () => _createPost(context), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF562634), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12)), child: Text('Post'))),
              ])),
          );
        }

        // Access post using index adjusted for the create card
        final postIndex = index - 1;
        if (postIndex < 0 || postIndex >= _posts.length) return SizedBox.shrink();
        final post = _posts[postIndex]; // Use state list

        final String userFirstName = post['userFirstName'] as String? ?? 'User';
        final String content = post['content'] as String? ?? 'No content';
        final String timestamp = post['timestamp'] as String? ?? DateTime.now().toIso8601String();
        final int likes = post['likes'] as int? ?? 0;
        final int dislikes = post['dislikes'] as int? ?? 0;
        final List<dynamic> commentMeta = (post['comments'] is List) ? post['comments'] : [];
        final String postId = post['_id'] as String? ?? '';
        if (postId.isEmpty) return SizedBox.shrink();

        final bool isExpanded = _expandedPostId == postId;
        final bool isLoadingComments = _loadingComments[postId] == true;
        final List<dynamic>? currentComments = _fetchedComments[postId];

        return Card(
          key: ValueKey(postId),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 2, margin: EdgeInsets.only(bottom: 16),
          child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [ // Post Header
                CircleAvatar(backgroundColor: Color(0xFF562634), child: Text(userFirstName.isNotEmpty ? userFirstName[0].toUpperCase() : '?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(userFirstName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(height: 2), Text(formatTime(timestamp), style: TextStyle(color: Colors.grey.shade600, fontSize: 12))]),
              ]),
              SizedBox(height: 12), Text(content, style: TextStyle(fontSize: 15, height: 1.4)), SizedBox(height: 16), // Post Content
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ // Post Interactions
                _buildInteractionButton(icon: Icons.thumb_up_outlined, count: likes, onTap: () => _handlePostLike(postId)),
                _buildInteractionButton(icon: Icons.thumb_down_outlined, count: dislikes, onTap: () => _handlePostDislike(postId)),
                _buildInteractionButton(icon: isExpanded ? Icons.mode_comment : Icons.mode_comment_outlined, count: currentComments?.length ?? commentMeta.length, onTap: () => _toggleComments(postId), isLoading: isLoadingComments && currentComments == null),
              ]),
              if (isExpanded) _buildCommentsSection(postId, currentComments, isLoadingComments), // Comments Section
            ])),
        );
      },
    );
  }

  Widget _buildCommentsSection(String postId, List<dynamic>? comments, bool isLoading) {
     return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Divider(height: 1, thickness: 1, color: Colors.grey.shade300), SizedBox(height: 12),
            Text("Comments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade700)), SizedBox(height: 8),
            if (isLoading && comments == null) Center(child: Padding(padding: const EdgeInsets.all(8.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))),
            if (!isLoading && comments == null && _fetchedComments.containsKey(postId)) Center(child: Text("Could not load comments.", style: TextStyle(color: Colors.red.shade800))),
            if (comments != null && comments.isEmpty) Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text("No comments yet.", style: TextStyle(color: Colors.grey.shade600)))),
            if (comments != null && comments.isNotEmpty)
              ListView.separated(
                shrinkWrap: true, physics: NeverScrollableScrollPhysics(), itemCount: comments.length,
                itemBuilder: (context, index) => _buildCommentItem(comments[index], postId),
                separatorBuilder: (context, index) => Divider(height: 1, indent: 42, endIndent: 10, color: Colors.grey.shade200),
              ),
            SizedBox(height: 12), _buildCommentInputField(postId),
          ]),
     );
  }

  Widget _buildCommentItem(dynamic comment, String postId) {
    final String userFirstName = comment['userFirstName'] as String? ?? 'User';
    final String content = comment['content'] as String? ?? '...';
    final String timestamp = comment['timestamp'] as String? ?? DateTime.now().toIso8601String();
    final String commentId = comment['_id'] as String? ?? '';
    final int likes = comment['likes'] as int? ?? 0;
    final int dislikes = comment['dislikes'] as int? ?? 0;
    if (commentId.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(radius: 16, backgroundColor: Colors.deepPurple.shade100, child: Text(userFirstName.isNotEmpty ? userFirstName[0].toUpperCase() : '?', style: TextStyle(color: Color(0xFF562634), fontSize: 12, fontWeight: FontWeight.bold))), SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Text(userFirstName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), SizedBox(width: 8), Text(formatTime(timestamp), style: TextStyle(color: Colors.grey.shade600, fontSize: 11))]), SizedBox(height: 4),
                Text(content, style: TextStyle(fontSize: 14, color: Colors.black87)),
              ])),
          ]),
          SizedBox(height: 8),
          Padding(padding: const EdgeInsets.only(left: 42.0), child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                _buildInteractionButton(icon: Icons.thumb_up_outlined, count: likes, onTap: () => _handleCommentLike(commentId, postId), iconSize: 16, countSize: 12), SizedBox(width: 16),
                _buildInteractionButton(icon: Icons.thumb_down_outlined, count: dislikes, onTap: () => _handleCommentDislike(commentId, postId), iconSize: 16, countSize: 12),
              ])),
        ]),
    );
  }

  Widget _buildCommentInputField(String postId) {
    return Row(children: [
        Expanded(child: TextField(
            controller: _commentContentController,
            decoration: InputDecoration(hintText: "Add a comment...", isDense: true, filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            textInputAction: TextInputAction.send, onSubmitted: (_) => _isPostingComment ? null : _postComment(postId),
        )),
        SizedBox(width: 8),
        IconButton(icon: _isPostingComment ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.send, color: Color(0xFF562634)), onPressed: _isPostingComment ? null : () => _postComment(postId), tooltip: 'Post Comment'),
    ]);
  }

 Widget _buildInteractionButton({ required IconData icon, required int count, required VoidCallback onTap, bool isLoading = false, double iconSize = 20, double countSize = 14 }) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              isLoading ? SizedBox(width: iconSize, height: iconSize, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(icon, size: iconSize, color: Colors.grey.shade700),
              SizedBox(width: 4),
              Text(count.toString(), style: TextStyle(fontSize: countSize, color: isLoading ? Colors.grey.shade400 : Colors.grey.shade800)),
            ]),
          ),
        ),
      );
  }
}
