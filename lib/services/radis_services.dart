import 'package:redis/redis.dart';

class RedisService {
  final String host;
  final String username;
  final String password;
  final int port;

  RedisService({
    required this.host,
    required this.username,
    required this.password,
    required this.port,
  });

  late RedisConnection _connection;
  late Command _command;

  Future<bool> connect() async {
    try {
      _connection = RedisConnection();
      _command = await _connection.connect(host, port);

      // Authenticate if username and password are provided
      if (username.isNotEmpty && password.isNotEmpty) {
        var authResponse = await _command.send_object([
          "AUTH",
          username,
          password,
        ]);
        if (authResponse.toString().toUpperCase() != "OK") {
          throw Exception("Authentication failed");
        }
      }

      // Verify connection by sending a PING command
      var pingResponse = await _command.send_object(["PING"]);
      if (pingResponse.toString().toUpperCase() == "PONG") {
        print("Connected to Redis successfully.");
        return true;
      } else {
        print("Failed to connect to Redis.");
        return false;
      }
    } catch (e) {
      print("Connection error: $e");
      return false;
    }
  }

  Future<dynamic> getValue(String key) async {
    try {
      final response = await _command.get(key);
      print("Redis GET $key → $response");
      return response;
    } catch (e, stack) {
      print("Error while reading Redis key: $key");
      print("Exception → $e");
      print(stack);
      return null; // safe fallback
    }
  }

  Future<void> setValue(String key, String value) async {
    await _command.set(key, value);
  }

  Future<void> disconnect() async {
    await _connection.close();
  }
}
