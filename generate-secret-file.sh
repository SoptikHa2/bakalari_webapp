#!/bin/sh

# REQUIRES sha256sum
if ! [ -x $(command -v sha256sum) ]; then
	>&2 echo "FAILURE: sha256sum is required!"
	exit 1
fi
# REQUIRES base64
if ! [ -x $(command -v base64) ]; then
	>&2 echo "FAILURE: base64 is required!"
	exit 1
fi



# Generate random alphanumeric 64-character string
ipsalt=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 64)
purge_url=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 128)
update_url=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 128)
admin_hash_salt=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 64)

echo "Input 2fa secret key. You can get one online, for example at https://www.xanxys.net/totp/. 2fa secret key generation in this script is at TODO phase."
read totp_key
# Strip all spaces from totp_key
totp_key=$(echo "$totp_key" | sed "s/ //g" -)

echo "Input admin username"
read username
echo "Input admin password"
read -s password

admin_hash=$(echo "$(echo "$password$username$admin_hash_salt" | sha256sum)" | base64)

rm web/webapp/secret.dart -f
mkdir -p web/webapp
touch secret.dart

# I'm sorry for this part
echo "class Secret {" >> web/webapp/secret.dart
echo "  /// Salt that is used while hashing IP addresses, so it's not possible to retrieve" >> web/webapp/secret.dart
echo "  /// IP addresses without this hash." >> web/webapp/secret.dart
echo "  static const String ipAddressSalt = \"$ipsalt\";" >> web/webapp/secret.dart
echo "  /// Send GET request to this URL to purge old userdata. This will remove user records" >> web/webapp/secret.dart
echo "  /// older than a week and old logs. Use this with CRON without the need to store your password" >> web/webapp/secret.dart
echo "  /// in plaintext. Don't worry about HTTP exit code." >> web/webapp/secret.dart
echo "  static const String purgeConfigUrl = \"/admin/purge/$purge_url\";" >> web/webapp/secret.dart
echo "  /// Send GET request to this URL to update school names and URLs. Use this with CRON without" >> web/webapp/secret.dart
echo "  /// the need to store your password in plaintext. Don't worry about HTTP exit code." >> web/webapp/secret.dart
echo "  static const String updateSchoolUrl = \"/admin/update/$update_url\";" >> web/webapp/secret.dart
echo "  /// Your two FA key. This is used to auth admin via TOTP." >> web/webapp/secret.dart
echo "  static const String twoFaKey = \"$totp_key\";" >> web/webapp/secret.dart
echo "  /// Admin username+password result hash." >> web/webapp/secret.dart
echo "  static const String adminHash = \"$admin_hash\";" >> web/webapp/secret.dart
echo "  /// Admin hash salt" >> web/webapp/secret.dart
echo "  static const String sha256salt = \"$admin_hash_salt\";" >> web/webapp/secret.dart
echo "}" >> web/webapp/secret.dart
