import 'package:flutter/material.dart';

class ForumScreen extends StatelessWidget {
  // Dummy posts data for display
  final List<Map<String, dynamic>> posts = [
    {
      'username': 'Alice',
      'time': '2 hours ago',
      'content': 'This is my first post in this forum! Excited to share my ideas.',
      'likes': 12,
      'dislikes': 2,
      'comments': 3,
    },
    {
      'username': 'Bob',
      'time': '5 hours ago',
      'content': 'I love Flutter—anyone else here?',
      'likes': 24,
      'dislikes': 1,
      'comments': 5,
    },
    {
      'username': 'Charlie',
      'time': '1 day ago',
      'content': 'Any suggestions for best coding practices?',
      'likes': 30,
      'dislikes': 0,
      'comments': 10,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forums'),
        backgroundColor: Color(0xFF562634),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Future: Navigate to a new post creation screen.
        },
        backgroundColor: Color(0xFF562634),
        child: Icon(Icons.add),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: posts.length + 1, // First element is the "new post" input.
          itemBuilder: (context, index) {
            if (index == 0) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Post',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Share your thoughts...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF562634),
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Post'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            final post = posts[index - 1];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post header: avatar, username and time.
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFF562634),
                          child: Text(
                            post['username'][0],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['username'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              post['time'],
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Post content.
                    Text(
                      post['content'],
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 12),
                    // Post actions: like, dislike, comment.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.thumb_up, size: 18, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(post['likes'].toString()),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.thumb_down, size: 18, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(post['dislikes'].toString()),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.comment, size: 18, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(post['comments'].toString()),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
