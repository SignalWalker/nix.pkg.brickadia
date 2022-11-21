{
  description = "A NixOS module for Brickadia servers.";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
    alejandra = {
      url = github:kamadorueda/alejandra;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }:
    with builtins; let
      std = nixpkgs.lib;
	  systems = [ "x86_64-linux" ];
	  nixpkgsFor = std.genAttrs systems (system: import nixpkgs {
	  	localSystem = builtins.currentSystem or system;
		crossSystem = system;
		overlays = [];
	  });
    in {
      formatter = std.mapAttrs (system: pkgs: pkgs.default) inputs.alejandra.packages;
	  packages."x86_64-linux" = let pkgs = nixpkgsFor."x86_64-linux"; in {
	  	brickadia-launcher = let
			version = {
				semver = "1.5";
				hash = "sha256-drEFLH5/4qNpwG4R3UNdw97imeG/7QRIo6Mgqibk7oo=";
			};
		in pkgs.gccStdenv.mkDerivation {
			pname = "brickadia-launcher";
			version = version.semver;
			src = pkgs.fetchurl {
				url = "https://static.brickadia.com/launcher/${version.semver}/brickadia-launcher.tar.xz";
				inherit (version) hash;
			};
			nativeBuildInputs = with pkgs; [];
			buildInputs = with pkgs; [];
			installPhase = ''
				install -Dm555 -T main-brickadia-launcher $out/bin/$pname
				install -Dm444 -t $out/usr/share/licenses/$pname licenses/*
				install -Dm555 -t $out/lib *.so*
				install -Dm555 -t $out/lib/platforms platforms/*
			'';
		};
	  };
    };
}
