with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    boost
    dpdk
    netdata
  ];
}
