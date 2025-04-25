import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
// Corrected import path (remove space)
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ForumScreen extends StatefulWidget {
  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final TextEditingController _postContentController = TextEditingController();
  final TextEditingController _commentContentController =
      TextEditingController();
  // final String currentUserEmail = "muiz@gmail.com"; // REMOVED Hardcoded email

  // --- Add Secure Storage instance and state for email ---
  final storage = FlutterSecureStorage(); // Initialize storage
  String? _currentUserEmail; // State variable for the fetched email (nullable)
  bool _isLoadingEmail = true; // Track if email is being loaded
  // ---

  // State for Posts
  List<dynamic> _posts = [];
  bool _isLoadingPosts = true; // Keep this for posts loading
  String? _postsError;

  // State for Comments
  String? _expandedPostId;
  Map<String, List<dynamic>> _fetchedComments = {};
  Map<String, bool> _loadingComments = {};
  bool _isPostingComment = false;

  @override
  void initState() {
    super.initState();
    // Load email first, then posts
    _initializeScreen(); // Call the orchestrator method
  }

  // Helper method to load initial data sequentially
  Future<void> _initializeScreen() async {
    await _loadCurrentUserEmail(); // Wait for email to load

    // Check if the widget is still mounted after the async operation
    if (!mounted) return;

    if (_currentUserEmail != null) {
      // Only load posts if email was loaded successfully
      _loadPosts();
    } else {
      // Handle case where email couldn't be loaded
      setState(() {
        _isLoadingPosts = false; // Stop post loading indicator
        _postsError = "Could not retrieve user email. Please log in again.";
      });
    }
  }

  // --- New method to load email from Secure Storage ---
  Future<void> _loadCurrentUserEmail() async {
    // Set loading state only if mounted (might be called before build)
    if (mounted) {
      setState(() {
        _isLoadingEmail = true;
        _postsError = null; // Clear previous errors
      });
    } else {
      _isLoadingEmail = true; // Set directly if not mounted yet
      _postsError = null;
    }

    try {
      String? email = await storage.read(key: 'email');
      // Check mounted *again* before calling setState
      if (mounted) {
        setState(() {
          _currentUserEmail = email; // Store the fetched email (can be null)
          _isLoadingEmail = false; // Mark email loading as complete
        });
        if (email == null) {
          print("Error: Email not found in secure storage.");
          // Error message is handled in _initializeScreen and build
        }
      } else {
        // If not mounted, just store the value for initial build
        _currentUserEmail = email;
        _isLoadingEmail = false;
      }
    } catch (e) {
      print("Error reading email from storage: $e");
      // Check mounted *again* before calling setState
      if (mounted) {
        setState(() {
          _currentUserEmail = null; // Ensure email is null on error
          _isLoadingEmail =
              false; // Mark email loading as complete (with error)
          // Error message is handled in _initializeScreen and build
        });
      } else {
        _currentUserEmail = null;
        _isLoadingEmail = false;
      }
    }
  }
  // ---

  @override
  void dispose() {
    _postContentController.dispose();
    _commentContentController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts({bool showLoading = true}) async {
    // --- Add Check: Don't load posts if email fetch failed ---
    // Check if email loading is finished and the result is null
    if (!_isLoadingEmail && _currentUserEmail == null) {
      print("Skipping post load: User email not available.");
      // Error state should already be set by _initializeScreen
      if (mounted) {
        setState(() {
          _isLoadingPosts = false; // Ensure loading indicator stops
        });
      }
      return; // Exit the function
    }
    // ---

    if (showLoading && mounted) {
      setState(() {
        _isLoadingPosts = true;
        _postsError = null;
      });
    }
    try {
      final response =
          await http.get(Uri.parse('https://e-fit-backend.onrender.com/post'));
      if (!mounted) return; // Check mounted after await
      if (response.statusCode == 200) {
        List<dynamic> fetchedPosts = jsonDecode(response.body);
        // Check if mounted before calling setState after an async gap
        if (!mounted) return;
        setState(() {
          // Assign directly without reversing
          _posts = fetchedPosts;
          _isLoadingPosts = false;
        });
      } else {
        // If not mounted, we can't throw to the UI anyway
        if (!mounted) return;
        throw Exception('Failed to load posts. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching posts: $e");
      if (mounted) {
        // Check mounted before setState
        setState(() {
          _postsError = 'Failed to load posts: $e';
          _isLoadingPosts = false;
        });
      }
    }
  }

  Future<List<dynamic>> fetchComments(String postId,
      {bool forceRefresh = false}) async {
    // No email needed for fetching comments based on current implementation
    if (!forceRefresh &&
        _loadingComments[postId] == true &&
        !_fetchedComments.containsKey(postId)) return [];
    if (!forceRefresh && _fetchedComments.containsKey(postId))
      return _fetchedComments[postId]!;

    if (mounted) {
      setState(() {
        _loadingComments[postId] = true;
      });
    }

    try {
      final uri =
          Uri.parse('https://e-fit-backend.onrender.com/comment/$postId');
      final response = await http.get(uri);
      if (!mounted) return _fetchedComments[postId] ?? []; // Check mounted
      if (response.statusCode == 200) {
        final List<dynamic> comments = jsonDecode(response.body);
        if (mounted) {
          // Check mounted
          setState(() {
            _fetchedComments[postId] = comments;
          });
        }
        return comments;
      } else {
        print('Failed load comments ${postId}. Status: ${response.statusCode}');
        if (mounted) {
          // Check mounted
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed load comments: ${response.reasonPhrase}')));
        }
        return _fetchedComments[postId] ?? [];
      }
    } catch (e) {
      if (!mounted) return _fetchedComments[postId] ?? []; // Check mounted
      print("Error fetching comments ${postId}: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading comments: $e')));
      return _fetchedComments[postId] ?? [];
    } finally {
      // Use containsKey before accessing/removing to avoid potential errors
      if (mounted && _loadingComments.containsKey(postId)) {
        setState(() {
          _loadingComments.remove(postId); // Remove using remove method
        });
      }
    }
  }

  Future<void> _createPost(BuildContext context) async {
    // --- Check if email is loaded ---
    if (_currentUserEmail == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot create post: User info not loaded.')));
      return;
    }
    // ---

    if (_postContentController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter content')));
      return;
    }
    try {
      final response =
          await http.post(Uri.parse('https://e-fit-backend.onrender.com/post'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                // --- Use state variable for email ---
                'email': _currentUserEmail,
                // ---
                'content': _postContentController.text
              }));
      if (!mounted) return; // Check mounted after await
      if (response.statusCode == 200 || response.statusCode == 201) {
        _postContentController.clear();
        await _loadPosts(showLoading: false); // Refresh posts
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Post created!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed create post: ${response.body}')));
      }
    } catch (e) {
      if (!mounted) return; // Check mounted after await
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error creating post: $e')));
    }
  }

  Future<void> _postComment(String postId) async {
    // --- Check if email is loaded ---
    if (_currentUserEmail == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot comment: User info not loaded.')));
      return;
    }
    // ---

    final content = _commentContentController.text.trim();
    if (content.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter comment')));
      return;
    }

    if (!mounted) return;
    setState(() => _isPostingComment = true);

    try {
      final response = await http.post(
          Uri.parse('https://e-fit-backend.onrender.com/comment'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            // --- Use state variable for email ---
            'email': _currentUserEmail,
            // ---
            'postId': postId,
            'content': content
          }));
          print('Current user email: $_currentUserEmail');
      if (!mounted) return; // Check mounted after await
      if (response.statusCode == 200 || response.statusCode == 201) {
        _commentContentController.clear();
        // Refresh comments for this post
        await fetchComments(postId, forceRefresh: true);
      } else {
        print(
            'Failed post comment. Status: ${response.statusCode}, Body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Failed post comment: ${response.reasonPhrase ?? response.body}')));
      }
    } catch (e) {
      if (!mounted) return; // Check mounted after await
      print("Error posting comment: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error posting comment: $e')));
    } finally {
      if (mounted) {
        // Check mounted before setState
        setState(() => _isPostingComment = false);
      }
    }
  }

  // Like/Dislike methods remain unchanged as they don't need the user's email
  // in the request body according to the provided API structure.
  Future<void> _handlePostLike(String postId) async {
    final postIndex = _posts.indexWhere((p) => p['_id'] == postId);
    if (postIndex == -1 || !mounted) return;

    final originalLikes = _posts[postIndex]['likes'] ?? 0;
    setState(() {
      _posts[postIndex]['likes'] = originalLikes + 1;
    });

    try {
      final response = await http.post(
          Uri.parse('https://e-fit-backend.onrender.com/post/$postId/like'));
      if (!mounted) return;
      if (response.statusCode != 200 && response.statusCode != 201) {
        print(
            "Failed to like post ${postId}: ${response.statusCode} ${response.body}");
        if (mounted) {
          setState(() {
            _posts[postIndex]['likes'] = originalLikes; // Revert
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to like post: ${response.body}')));
      }
    } catch (e) {
      print("Error liking post ${postId}: $e");
      if (!mounted) return;
      setState(() {
        _posts[postIndex]['likes'] = originalLikes; // Revert
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error liking post: $e')));
    }
  }

  Future<void> _handlePostDislike(String postId) async {
    final postIndex = _posts.indexWhere((p) => p['_id'] == postId);
    if (postIndex == -1 || !mounted) return;

    final originalDislikes = _posts[postIndex]['dislikes'] ?? 0;
    setState(() {
      _posts[postIndex]['dislikes'] = originalDislikes + 1;
    });

    try {
      final response = await http.post(
          Uri.parse('https://e-fit-backend.onrender.com/post/$postId/dislike'));
      if (!mounted) return;
      if (response.statusCode != 200 && response.statusCode != 201) {
        print(
            "Failed to dislike post ${postId}: ${response.statusCode} ${response.body}");
        if (mounted) {
          setState(() {
            _posts[postIndex]['dislikes'] = originalDislikes; // Revert
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to dislike post: ${response.body}')));
      }
    } catch (e) {
      print("Error disliking post ${postId}: $e");
      if (!mounted) return;
      setState(() {
        _posts[postIndex]['dislikes'] = originalDislikes; // Revert
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error disliking post: $e')));
    }
  }

  Future<void> _handleCommentLike(String commentId, String postId) async {
    try {
      final response = await http.post(Uri.parse(
          'https://e-fit-backend.onrender.com/comment/$commentId/like'));
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchComments(postId, forceRefresh: true); // Refresh comments
      } else {
        print(
            "Failed to like comment ${commentId}: ${response.statusCode} ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed like comment: ${response.body}')));
      }
    } catch (e) {
      print("Error liking comment ${commentId}: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error liking comment: $e')));
    }
  }

  Future<void> _handleCommentDislike(String commentId, String postId) async {
    try {
      final response = await http.post(Uri.parse(
          'https://e-fit-backend.onrender.com/comment/$commentId/dislike'));
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchComments(postId, forceRefresh: true); // Refresh comments
      } else {
        print(
            "Failed to dislike comment ${commentId}: ${response.statusCode} ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed dislike comment: ${response.body}')));
      }
    } catch (e) {
      print("Error disliking comment ${commentId}: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error disliking comment: $e')));
    }
  }

  void _toggleComments(String postId) {
    final currentlyExpanded = _expandedPostId;
    setState(() {
      if (currentlyExpanded == postId) {
        _expandedPostId = null;
        _commentContentController.clear(); // Clear text when collapsing
      } else {
        _expandedPostId = postId;
        _commentContentController.clear(); // Clear text when expanding
        // Fetch if not already fetched and not currently loading
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
      return '?'; // Return a placeholder on error
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
        // Optional: Add a background gradient or color
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: _buildBody(), // Delegate body building
      ),
    );
  }

  // Helper method to build the body based on loading/error states
  Widget _buildBody() {
    // --- Updated Loading Check ---
    // Show loading indicator if either email is loading OR (posts are loading AND we don't have posts/errors yet)
    if (_isLoadingEmail ||
        (_isLoadingPosts && _posts.isEmpty && _postsError == null)) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF562634)));
    }

    // --- Updated Error Check ---
    // Show error if posts failed to load OR if the email fetch definitively failed
    if (_postsError != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_postsError!, // Display the specific error message
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade800)),
      ));
    }
    // --- Specific Check for Failed Email Load (after loading is done) ---
    if (!_isLoadingEmail && _currentUserEmail == null) {
      // This covers the case where _initializeScreen set the error or email was just null
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
              "Could not retrieve user information. Please try logging in again.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade800)),
        ),
      );
    }

    // If email is loaded and no errors, show the main content
    return RefreshIndicator(
      onRefresh: () => _loadPosts(showLoading: false), // Allow pull-to-refresh
      child: _buildPostList(context),
    );
  }

  Widget _buildPostList(BuildContext context) {
    // --- Determine if user can post based on email state ---
    bool canPost = _currentUserEmail != null;

    return ListView.builder(
      padding: EdgeInsets.all(16),
      // Add 1 for the "Create Post" card at the top
      itemCount: _posts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // --- Create Post Card ---
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create New Post',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  TextField(
                    controller: _postContentController,
                    enabled:
                        canPost, // --- Disable if user email isn't loaded ---
                    decoration: InputDecoration(
                      hintText: canPost
                          ? 'Share your thoughts...'
                          : 'Loading user info...', // --- Dynamic hint ---
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: canPost
                          ? Colors.grey[100]
                          : Colors.grey[200], // --- Visual cue for disabled ---
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      // --- Disable button if user cannot post ---
                      onPressed: canPost ? () => _createPost(context) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF562634),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors
                            .grey.shade400, // --- Style for disabled button ---
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text('Post'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // --- Existing Post Item Logic ---
        // Adjust index because the first item (index 0) is the create post card
        final postIndex = index - 1;
        // Basic bounds check
        if (postIndex < 0 || postIndex >= _posts.length)
          return SizedBox.shrink(); // Should not happen with itemCount logic

        final post = _posts[postIndex];

        // Safely extract data with null checks and defaults
        final String userFirstName = post['userFirstName'] as String? ?? 'User';
        final String content = post['content'] as String? ?? 'No content';
        final String timestamp =
            post['timestamp'] as String? ?? DateTime.now().toIso8601String();
        final int likes = post['likes'] as int? ?? 0;
        final int dislikes = post['dislikes'] as int? ?? 0;
        // Ensure comments metadata is treated as a list
        final List<dynamic> commentMeta =
            (post['comments'] is List) ? post['comments'] : [];
        final String postId = post['_id'] as String? ?? '';

        // Skip rendering if essential data like postId is missing
        if (postId.isEmpty) return SizedBox.shrink();

        final bool isExpanded = _expandedPostId == postId;
        final bool isLoadingComments = _loadingComments[postId] == true;
        final List<dynamic>? currentComments = _fetchedComments[postId];

        return Card(
          key: ValueKey(postId), // Use postId for stable keys
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post Header
                Row(
                  children: [
                    CircleAvatar(
                        backgroundColor: Color(0xFF562634),
                        child: Text(
                            userFirstName.isNotEmpty
                                ? userFirstName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    SizedBox(width: 10),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userFirstName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 2),
                          Text(formatTime(timestamp),
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                        ]),
                  ],
                ),
                SizedBox(height: 12),

                // Post Content
                Text(content, style: TextStyle(fontSize: 15, height: 1.4)),
                SizedBox(height: 16),

                // Post Interactions (Like, Dislike, Comment Button)
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInteractionButton(
                          icon: Icons.thumb_up_outlined,
                          count: likes,
                          onTap: () => _handlePostLike(postId)),
                      _buildInteractionButton(
                          icon: Icons.thumb_down_outlined,
                          count: dislikes,
                          onTap: () => _handlePostDislike(postId)),
                      _buildInteractionButton(
                          icon: isExpanded
                              ? Icons.mode_comment
                              : Icons.mode_comment_outlined,
                          // Show fetched count if available, else initial count
                          count: currentComments?.length ?? commentMeta.length,
                          onTap: () => _toggleComments(postId),
                          isLoading: isLoadingComments &&
                              currentComments ==
                                  null // Show loading only when fetching first time
                          ),
                    ]),

                // --- Comments Section (Conditional) ---
                if (isExpanded)
                  _buildCommentsSection(
                      postId, currentComments, isLoadingComments),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentsSection(
      String postId, List<dynamic>? comments, bool isLoading) {
    // --- Determine if user can comment ---
    bool canComment = _currentUserEmail != null;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
        SizedBox(height: 12),
        Text("Comments",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey.shade700)),
        SizedBox(height: 8),

        // Loading state for comments
        if (isLoading &&
            comments == null) // Show loading only when initially fetching
          Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)),
          )),

        // Error state (if loading finished but comments are still null) - check if key exists for certainty
        if (!isLoading &&
            comments == null &&
            _fetchedComments.containsKey(postId))
          Center(
              child: Text("Could not load comments.",
                  style: TextStyle(color: Colors.red.shade800))),

        // Empty state
        if (comments != null && comments.isEmpty)
          Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text("No comments yet.",
                style: TextStyle(color: Colors.grey.shade600)),
          )),

        // Comments List
        if (comments != null && comments.isNotEmpty)
          ListView.separated(
            shrinkWrap: true, // Important inside a Column
            physics:
                NeverScrollableScrollPhysics(), // List itself shouldn't scroll
            itemCount: comments.length,
            itemBuilder: (context, index) =>
                _buildCommentItem(comments[index], postId),
            separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 42,
                endIndent: 10,
                color: Colors.grey.shade200), // Indented separator
          ),

        SizedBox(height: 12),
        // --- Comment Input Field ---
        _buildCommentInputField(postId, canComment), // Pass canComment flag
      ]),
    );
  }

  Widget _buildCommentItem(dynamic comment, String postId) {
    // Safely extract comment data
    final String userFirstName = comment['commenterFirstName'] as String? ?? 'User';
    final String content = comment['content'] as String? ?? '...';
    final String timestamp =
        comment['timestamp'] as String? ?? DateTime.now().toIso8601String();
    final String commentId = comment['_id'] as String? ?? '';
    final int likes = comment['likes'] as int? ?? 0;
    final int dislikes = comment['dislikes'] as int? ?? 0;

    if (commentId.isEmpty) return SizedBox.shrink(); // Don't render if no ID

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align avatar and text block top
          children: [
            CircleAvatar(
                radius: 16,
                backgroundColor:
                    Colors.deepPurple.shade100, // Lighter color for comments
                child: Text(
                    userFirstName.isNotEmpty
                        ? userFirstName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        color: Color(0xFF562634),
                        fontSize: 12,
                        fontWeight: FontWeight.bold))),
            SizedBox(width: 10),
            Expanded(
              // Allow text to wrap
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(// User name and time on one line
                        children: [
                      Text(userFirstName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(width: 8),
                      Text(formatTime(timestamp),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 11)),
                    ]),
                    SizedBox(height: 4),
                    Text(content,
                        style: TextStyle(fontSize: 14, color: Colors.black87)),
                  ]),
            ),
          ],
        ),
        SizedBox(height: 8),
        // Comment Interactions (indented)
        Padding(
          padding: const EdgeInsets.only(
              left: 42.0), // Indent aligns with text block
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            _buildInteractionButton(
                icon: Icons.thumb_up_outlined,
                count: likes,
                onTap: () => _handleCommentLike(commentId, postId),
                iconSize: 16, // Smaller icons for comments
                countSize: 12),
            SizedBox(width: 16), // Space between buttons
            _buildInteractionButton(
                icon: Icons.thumb_down_outlined,
                count: dislikes,
                onTap: () => _handleCommentDislike(commentId, postId),
                iconSize: 16,
                countSize: 12),
          ]),
        ),
      ]),
    );
  }

  // --- Updated Comment Input Field to handle disabled state ---
  Widget _buildCommentInputField(String postId, bool canComment) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentContentController,
            enabled: canComment, // --- Disable based on flag ---
            decoration: InputDecoration(
              hintText: canComment
                  ? "Add a comment..."
                  : "Loading user info...", // --- Dynamic hint ---
              isDense: true, // More compact
              filled: true,
              fillColor: canComment
                  ? Colors.grey.shade100
                  : Colors.grey[200], // --- Visual cue for disabled ---
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20), // Rounded corners
                borderSide: BorderSide.none, // No border
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            textInputAction:
                TextInputAction.send, // Show send button on keyboard
            // --- Disable submission if cannot comment or already posting ---
            onSubmitted: (!canComment || _isPostingComment)
                ? null
                : (_) => _postComment(postId),
          ),
        ),
        SizedBox(width: 8),
        IconButton(
          icon: _isPostingComment
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2)) // Show loading in button
              : Icon(Icons.send, color: Color(0xFF562634)),
          // --- Disable button if cannot comment or already posting ---
          onPressed: (!canComment || _isPostingComment)
              ? null
              : () => _postComment(postId),
          tooltip: 'Post Comment',
        ),
      ],
    );
  }

  // Helper for interaction buttons (like, dislike, comment)
  Widget _buildInteractionButton(
      {required IconData icon,
      required int count,
      required VoidCallback onTap,
      bool isLoading = false, // Optional loading state for the button itself
      double iconSize = 20,
      double countSize = 14}) {
    return Material(
      color: Colors.transparent, // Needed for InkWell splash
      child: InkWell(
        onTap: isLoading ? null : onTap, // Disable tap when loading
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 4.0, vertical: 2.0), // Small padding
          child: Row(
            mainAxisSize: MainAxisSize.min, // Row takes minimum space
            children: [
              if (isLoading)
                SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(strokeWidth: 2))
              else
                Icon(icon, size: iconSize, color: Colors.grey.shade700),
              SizedBox(width: 4),
              Text(count.toString(),
                  style: TextStyle(
                      fontSize: countSize,
                      color: isLoading
                          ? Colors.grey.shade400
                          : Colors.grey.shade800 // Dim count if loading
                      )),
            ],
          ),
        ),
      ),
    );
  }
}
