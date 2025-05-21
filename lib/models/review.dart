class Review {
  final String id;
  final String userName;
  final String userImage;
  final double rating;
  final String comment;
  final DateTime date;
  
  Review({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.rating,
    required this.comment,
    required this.date,
  });
  
 
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userImage': userImage,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(), 
    };
  }
  
  // Creates a Review instance from a JSON Map.
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userName: json['userName'] as String,
      userImage: json['userImage'] as String,
      rating: (json['rating'] as num).toDouble(), 
      comment: json['comment'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
