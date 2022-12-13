class RegistrationRequest {
  String serialKey;

  RegistrationRequest({this.serialKey});

  RegistrationRequest.fromJson(Map<String, dynamic> json) {
    serialKey = json['SerialKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SerialKey'] = this.serialKey;
    return data;
  }
}
