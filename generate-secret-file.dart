// Run this file with dart.
// This will prompt for password and
// generate secret file.

// You may need to run "pub get" before running this to download all packages.

// Redirect output from this file to web/webapp/secret.dart
// For example:
// $ dart generate-secret-file.dart > web/webapp/secret.dart
// Instructions (for example provide username, password)
// as well as all results (for example 2FA TOTP keys)
// will be printed to STDERR.

import "dart:math";
import 'dart:io';
import 'dart:convert';

import 'package:pointycastle/api.dart';

main(List<String> args) {
  Random rnd = Random.secure();

  /// Generate ip address salt randomly
  String ipsalt = randomAlphanumericString(64, rnd);

  /// Generate purge url randomly
  String purge_url = randomAlphanumericString(128, rnd);

  /// Generate update school url randomly
  String update_url = randomAlphanumericString(128, rnd);

  /// 2fa key generation doesn't work so far
  /// TODO: Implement 2fa key generation in generate secret
  stderr.writeln("Input 2fa secret key. You can get one online, for example at https://www.xanxys.net/totp/");
  String totp_key = stdin.readLineSync().trim().replaceAll(" ", "");

  /// Ask for admin username and password
  stderr.writeln("Input admin username:");
  String username = stdin.readLineSync();
  stderr.writeln("Input admin password:");
  stdin.echoMode = false;
  String password = stdin.readLineSync();
  stdin.echoMode = true;
  String admin_hash_salt = randomAlphanumericString(64, rnd);

  final Digest _sha256 = Digest("SHA-256");
  String admin_hash = base64.encode(
      _sha256.process(utf8.encode(password + username + admin_hash_salt)));

  String result = """

// This file should be in web/webapp/secret.dart


class Secret {
  /// Salt that is used while hashing IP addresses, so it's not possible to retrieve
  /// IP addresses without this hash.
  static const String ipAddressSalt = "$ipsalt";
  /// Send GET request to this URL to purge old userdata. This will remove user records
  /// older than a week and old logs. Use this with CRON without the need to store your password
  /// in plaintext. Don't worry about HTTP exit code.
  static const String purgeConfigUrl = "/admin/purge/$purge_url";
  /// Send GET request to this URL to update school names and URLs. Use this with CRON without
  /// the need to store your password in plaintext. Don't worry about HTTP exit code.
  static const String updateSchoolUrl = "/admin/update/$update_url";
  /// Your two FA key. This is used to auth admin via TOTP.
  static const String twoFaKey = "$totp_key";
  /// Admin username+password result hash.
  static const String adminHash = "$admin_hash";
  /// Admin hash salt
  static const String sha256salt = "$admin_hash_salt";
}
""";

  stdout.writeln(result);

  stderr.writeln(
      "Ouput was successfully sent to stdout. Here are important strings you should save:");
  stderr.writeln(
      "You should add totp secret into your 2fa application. It wil generate 2fa keys.");
  stderr.writeln(
      "PURGEDATA is url that upon accessing deletes all old user data. This can be used with cron.");
  stderr.writeln(
      "UPDATESCHL is url that upon accessing updates the school name : url table. This should be called immediatelly for the first time and than with cron every month or so.");
  stderr.writeln("\n\n");
  stderr.writeln(
      "All these codes can be found in stdout (which you probably redirected to a file).");
  stderr.writeln("TOTPSECRET  ${formatStringWithSpaces(totp_key, 4)}");
  stderr.writeln("PURGEDATA   $purge_url");
  stderr.writeln("UPDATESCHL  $update_url");
}

int randBetween(int from, int to, Random randInstance) {
  if (from > to)
    throw new Exception("Rand between: from ($from) is < than to ($to)");
  return from + randInstance.nextInt(to - from);
}

String randomAlphanumericString(int length, Random randInstance) {
  return String.fromCharCodes(List.generate(
      length,
      (_) => randBetween(0, 2, randInstance) == 0
          ? randBetween(97, 123, randInstance)
          : randBetween(48, 58, randInstance)));
}

/// Return string that is formatted into blocks with N letters in each block.
/// Each block is separated by a space.
///
/// Example:
/// abcdefghijklmnopqrstuvxyz
/// letters in block := 4
/// ==>
/// abcd efgh ijkl mnop qrst uvxy z
String formatStringWithSpaces(String string, int lettersInBlock) {
  int idx = 0;
  String result = "";
  for (var i = 1; i <= string.length + (string.length ~/ (lettersInBlock+1)); i++) {
    if (i % (lettersInBlock + 1) != 0) {
      result += string[idx++];
    } else {
      result += " ";
    }
  }
  return result;
}
