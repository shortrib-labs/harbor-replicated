{ pkgs ? import <nixpkgs> {}}:
with pkgs;
mkShell {
  buildInputs = [
    bash
    git
    curl
    gnumake
    kubectl
    kubernetes-helm
  ];
}

