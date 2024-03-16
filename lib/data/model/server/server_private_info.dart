import 'package:hive_flutter/hive_flutter.dart';
import 'package:toolbox/data/model/server/server.dart';
import 'package:toolbox/data/res/provider.dart';

import '../app/error.dart';

part 'server_private_info.g.dart';

@HiveType(typeId: 3)
class ServerPrivateInfo {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String ip;
  @HiveField(2)
  final int port;
  @HiveField(3)
  final String user;
  @HiveField(4)
  final String? pwd;

  /// [id] of private key
  @HiveField(5)
  final String? keyId;
  @HiveField(6)
  final List<String>? tags;
  @HiveField(7)
  final String? alterUrl;
  @HiveField(8)
  final bool? autoConnect;

  /// [id] of the jump server
  @HiveField(9)
  final String? jumpId;

  final String id;

  const ServerPrivateInfo({
    required this.name,
    required this.ip,
    required this.port,
    required this.user,
    required this.pwd,
    this.keyId,
    this.tags,
    this.alterUrl,
    this.autoConnect,
    this.jumpId,
  }) : id = '$user@$ip:$port';

  static ServerPrivateInfo fromJson(Map<String, dynamic> json) {
    final ip = json["ip"] as String? ?? '';
    final port = json["port"] as int? ?? 22;
    final user = json["user"] as String? ?? 'root';
    final name = json["name"] as String? ?? '';
    final pwd = json["authorization"] as String?;
    final keyId = json["pubKeyId"] as String?;
    final tags = (json["tags"] as List?)?.cast<String>();
    final alterUrl = json["alterUrl"] as String?;
    final autoConnect = json["autoConnect"] as bool?;
    final jumpId = json["jumpId"] as String?;

    return ServerPrivateInfo(
      name: name,
      ip: ip,
      port: port,
      user: user,
      pwd: pwd,
      keyId: keyId,
      tags: tags,
      alterUrl: alterUrl,
      autoConnect: autoConnect,
      jumpId: jumpId,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["name"] = name;
    data["ip"] = ip;
    data["port"] = port;
    data["user"] = user;
    data["authorization"] = pwd;
    data["pubKeyId"] = keyId;
    data["tags"] = tags;
    data["alterUrl"] = alterUrl;
    data["autoConnect"] = autoConnect;
    data["jumpId"] = jumpId;
    return data;
  }

  Server? get server => Pros.server.pick(spi: this);
  Server? get jumpServer => Pros.server.pick(id: jumpId);

  bool shouldReconnect(ServerPrivateInfo old) {
    return id != old.id ||
        pwd != old.pwd ||
        keyId != old.keyId ||
        alterUrl != old.alterUrl ||
        jumpId != old.jumpId;
  }

  _IpPort fromStringUrl() {
    if (alterUrl == null) {
      throw SSHErr(type: SSHErrType.connect, message: 'alterUrl is null');
    }
    final splited = alterUrl!.split('@');
    if (splited.length != 2) {
      throw SSHErr(type: SSHErrType.connect, message: 'alterUrl no @');
    }
    final splited2 = splited[1].split(':');
    if (splited2.length != 2) {
      throw SSHErr(type: SSHErrType.connect, message: 'alterUrl no :');
    }
    final ip_ = splited2[0];
    final port_ = int.tryParse(splited2[1]) ?? 22;
    if (port <= 0 || port > 65535) {
      throw SSHErr(type: SSHErrType.connect, message: 'alterUrl port error');
    }
    return _IpPort(ip_, port_);
  }

  @override
  String toString() {
    return id;
  }
}

class _IpPort {
  final String ip;
  final int port;

  _IpPort(this.ip, this.port);
}
