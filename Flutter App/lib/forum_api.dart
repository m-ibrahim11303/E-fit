part of 'forum_screen.dart';

extension ForumApi on _ForumScreenState {
  Future<void> _loadPosts({bool showLoading = true}) async {
    if (!_isLoadingEmail && _currentUserEmail == null) {
      print("Skipping post load: User email not available.");
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
        });
      }
      return;
    }

    if (showLoading && mounted) {
      setState(() {
        _isLoadingPosts = true;
        _postsError = null;
      });
    }
    try {
      final response =
          await http.get(Uri.parse('https://e-fit-backend.onrender.com/post'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        List<dynamic> fetchedPosts = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          _posts = fetchedPosts;
          _isLoadingPosts = false;
        });
      } else {
        if (!mounted) return;
        throw Exception('Failed to load posts. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching posts: $e");
      if (mounted) {
        setState(() {
          _postsError = 'Failed to load posts: $e';
          _isLoadingPosts = false;
        });
      }
    }
  }

  Future<List<dynamic>> fetchComments(String postId,
      {bool forceRefresh = false}) async {
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
      if (!mounted) return _fetchedComments[postId] ?? [];
      if (response.statusCode == 200) {
        final List<dynamic> comments = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _fetchedComments[postId] = comments;
          });
        }
        return comments;
      } else {
        print('Failed load comments ${postId}. Status: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed load comments: ${response.reasonPhrase}')));
        }
        return _fetchedComments[postId] ?? [];
      }
    } catch (e) {
      if (!mounted) return _fetchedComments[postId] ?? [];
      print("Error fetching comments ${postId}: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading comments: $e')));
      return _fetchedComments[postId] ?? [];
    } finally {
      if (mounted && _loadingComments.containsKey(postId)) {
        setState(() {
          _loadingComments.remove(postId);
        });
      }
    }
  }

  Future<void> _createPost(BuildContext context) async {
    if (_currentUserEmail == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot create post: User info not loaded.')));
      return;
    }

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
                'email': _currentUserEmail,
                'content': _postContentController.text
              }));
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        _postContentController.clear();
        await _loadPosts(showLoading: false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Post created!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed create post: ${response.body}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error creating post: $e')));
    }
  }

  Future<void> _postComment(String postId) async {
    if (_currentUserEmail == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot comment: User info not loaded.')));
      return;
    }

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
            'email': _currentUserEmail,
            'postId': postId,
            'content': content
          }));
      print('Current user email: $_currentUserEmail');
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        _commentContentController.clear();
        await fetchComments(postId, forceRefresh: true);
      } else {
        print(
            'Failed post comment. Status: ${response.statusCode}, Body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Failed post comment: ${response.reasonPhrase ?? response.body}')));
      }
    } catch (e) {
      if (!mounted) return;
      print("Error posting comment: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error posting comment: $e')));
    } finally {
      if (mounted) {
        setState(() => _isPostingComment = false);
      }
    }
  }

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
            _posts[postIndex]['likes'] = originalLikes;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to like post: ${response.body}')));
      }
    } catch (e) {
      print("Error liking post ${postId}: $e");
      if (!mounted) return;
      setState(() {
        _posts[postIndex]['likes'] = originalLikes;
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
            _posts[postIndex]['dislikes'] = originalDislikes;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to dislike post: ${response.body}')));
      }
    } catch (e) {
      print("Error disliking post ${postId}: $e");
      if (!mounted) return;
      setState(() {
        _posts[postIndex]['dislikes'] = originalDislikes;
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
        await fetchComments(postId, forceRefresh: true);
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
        await fetchComments(postId, forceRefresh: true);
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
}