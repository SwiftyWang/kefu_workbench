class UploadSecretModel {
  String secret;
  String host;
  int mode;

  UploadSecretModel({this.secret, this.host, this.mode});

  UploadSecretModel.fromJson(Map<String, dynamic> json) {
    this.secret = json['secret'];
    this.host = json['host'];
    this.mode = json['mode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['secret'] = this.secret;
    data['host'] = this.host;
    data['mode'] = this.mode;
    return data;
  }
}
