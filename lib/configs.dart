class Configs {
  /// 开发模式
  static const bool DEBUG = true;

  /// APP名称
  static const APP_NAME = "WAN客服系统";

  /// 测试环境api
  static const String API_HOST_DEV = "http://kf.aissz.com:666/v1";

  /// 生产环境api
  static const String API_HOST_RELEASE = "http://kf.aissz.com:666/v1";

  /// 根据实际环境返回
  static const String HOST = DEBUG ? API_HOST_DEV : API_HOST_RELEASE;

  /// 小米消息云
  static const String MIMC_APP_ID = "2882303761518282099";
  static const String MIMC_APP_KEY = "5521828290099";
  static const String MIMC_APP_SECRET = "516JCA60FdP9bHQUdpXK+Q==";

}
