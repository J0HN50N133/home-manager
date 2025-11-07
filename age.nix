{ config, ... }: {
  age = {
    identityPaths = [ "${config.home.homeDirectory}/.ssh/age" ];
    secrets = {
      deepseek = { file = secrets/deepseek.age; };
      glm = { file = secrets/glm.age; };
    };
  };
}
