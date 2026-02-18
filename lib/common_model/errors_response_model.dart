class BadRequest {
  final int code;
  final String message;

  BadRequest({required this.code, required this.message});

  factory BadRequest.fromJson(Map<String, dynamic> json) {
    return BadRequest(
      code: json['code'] as int,
      message: json['message'] as String,
    );
  }
}