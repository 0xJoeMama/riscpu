{
  description = "RISC-V CPU is VHDL";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      system = system;
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        coreboot-toolchain.riscv
        yosys
        netlistsvg
        haskellPackages.sv2v
        gnumake
      ];
    };
  };
}
