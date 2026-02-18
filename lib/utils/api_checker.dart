
class ApiChecker {
  static String getErrorMsg(dynamic body) {
    String errorMessage = "An error occurred";
    try {
      if (body is List && body.isNotEmpty) {
        // Handle list of errors: [{"message": "..."}]
        if (body[0] is Map && body[0].containsKey('message')) {
          errorMessage = body[0]['message'];
        } else if (body[0] is String) {
          errorMessage = body[0];
        }
      } else if (body is Map) {
        // Handle map error: {"message": "..."} or {"error": "..."}
        if (body.containsKey('message')) {
          errorMessage = body['message'];
        } else if (body.containsKey('error')) {
          errorMessage = body['error'];
        }
      } else if (body is String) {
        errorMessage = body;
      }
    } catch (e) {
      print("Error parsing API error message: $e");
    }
    return errorMessage;
  }
}
