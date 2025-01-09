class NewsPost {
  final int? id;
  final String title;
  final String content;
  final String imageUrl;
  final String createdAt;
  final String adminId;
  final bool isPublished;

  NewsPost({
    this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
    required this.adminId,
    required this.isPublished,
  });

  factory NewsPost.fromJson(Map<String, dynamic> json) {
    return NewsPost(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'],
      adminId: json['adminId'],
      isPublished: json['isPublished'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'adminId': adminId,
      'isPublished': isPublished,
    };
  }
}