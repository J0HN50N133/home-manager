{ config, ... }:
{
  age = {
    identityPaths = [ "${config.home.homeDirectory}/.ssh/age" ];
    secrets = {
      deepseek = {
        file = secrets/deepseek.age;
      };
      glm = {
        file = secrets/glm.age;
      };
      kimi = {
        file = secrets/kimi.age;
      };
      gemini = {
        file = secrets/gemini.age;
      };
    };
  };
}
