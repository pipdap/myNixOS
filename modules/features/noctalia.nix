{ self, inputs, ... }: {
  perSystem = { pkgs, lib, self', ... }: {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings = {
        bars = [];
        launcher = { enabled = true; search = true; };
        widgets = [];
      };
    };
  };
}