{
  description = "CS 110L Spring 2020 - Rust 开发环境";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        # Rust 工具链（使用 nixpkgs 内置包，从 Nix 缓存获取而非 rust-lang.org）
        rustToolchain = with pkgs; [
          rustc
          cargo
          clippy
          rustfmt
          rust-analyzer
          rustPlatform.rustcSrc
        ];

        # 系统依赖列表（为所有子项目的原生 crate 提供构建支持）
        nativeBuildInputs = with pkgs; [
          # 基础构建工具
          gcc
          cmake
          pkg-config
          makeWrapper

          # 调试与性能分析
          gdb
          lldb
          strace
          ltrace
          valgrind
          linuxPackages.perf

          # 项目管理工具
          cargo-edit # cargo add / rm / upgrade
          cargo-audit # 安全检查
          cargo-outdated # 依赖版本检查

          # 编辑器/开发工具
          nil # Nix LSP (可选)

          # 通用工具
          which
          file
          xxd
          jq
        ];

        # 构建时依赖（库链接等）
        buildInputs =
          with pkgs;
          [
            # nix crate (0.17.0) 需要这些系统库
            nix
            libxml2
            libffi

            # addr2line / backtrace 需要
            elfutils
            zlib

            # openssl（某些 crate 间接依赖）
            openssl

            # libc 相关
            glibc
            glibc.static

            # 文件系统 / 内存映射相关
            liburing
          ]
          ++ lib.optionals stdenv.isLinux [
            # Linux 特有
            util-linux
            procps
          ];

      in
      {
        # 开发 Shell
        devShells.default = pkgs.mkShell {
          buildInputs = buildInputs;
          nativeBuildInputs = nativeBuildInputs ++ rustToolchain;

          # 环境变量
          RUST_BACKTRACE = "1";
          CARGO_INCREMENTAL = "1";
          RUST_LOG = "info";
        };
      }
    );
}
