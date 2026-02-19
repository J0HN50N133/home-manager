let
  publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8I8RjfkUTHwmmoEcDDx18s1qX/y9kjK9lGVsOd3fJJ johnsonlee@LAPTOP-EJLDPLBO";
in {
  "deepseek.age".publicKeys = [ publicKey ];
  "glm.age".publicKeys = [ publicKey ];
  "kimi.age".publicKeys = [ publicKey ];
  "gemini.age".publicKeys = [ publicKey ];
  "aiberm.com.age".publicKeys = [ publicKey ];
  "minimaxi.age".publicKeys = [ publicKey ];
}
