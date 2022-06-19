class ApiResponse<T> {
  T data;
  bool isError;
  String errorMessage;

  ApiResponse({this.data, this.isError, this.errorMessage});
}