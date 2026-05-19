{
  description = "CS 110L Spring 2020 - Rust 开发环境 (支持 Linux 和 macOS/nix-darwin)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";

    # nix-darwin: macOS 系统管理（可选，仅在 macOS 上使用）
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      darwin,
    }:
    # 开发 Shell — 所有默认系统 (x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin)
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

        # ---- 平台中立的系统依赖 ----
        nativeBuildInputsCommon = with pkgs; [
          # 基础构建工具
          gcc
          cmake
          pkg-config
          makeWrapper

          # 调试与性能分析
          lldb

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

        # ---- Linux 特有依赖 ----
        nativeBuildInputsLinux =
          with pkgs;
          lib.optionals stdenv.isLinux [
            gdb
            strace
            ltrace
            valgrind
            linuxPackages.perf
          ];

        # ---- macOS (nix-darwin) 特有依赖 ----
        nativeBuildInputsDarwin =
          with pkgs;
          lib.optionals stdenv.isDarwin [
            # macOS 命令行开发者工具（自带 lldb, nm, otool, dtruss 等）
            # 无需额外安装，系统自带
          ];

        # ---- 构建时依赖（库链接等） — 平台中立 ----
        buildInputsCommon = with pkgs; [
          # nix crate (0.17.0) 需要
          nix
          libxml2
          libffi

          # zlib（压缩）
          zlib

          # openssl（某些 crate 间接依赖）
          openssl

          # libiconv（编码转换，macOS 上尤其需要）
          libiconv
        ];

        # ---- Linux 特有构建依赖 ----
        buildInputsLinux =
          with pkgs;
          lib.optionals stdenv.isLinux [
            # addr2line / backtrace 需要
            elfutils

            # libc 相关
            glibc
            glibc.static

            # 文件系统 / 内存映射相关
            liburing

            # 其他 Linux 工具
            util-linux
            procps
          ];

        # ---- macOS 特有构建依赖 ----
        buildInputsDarwin =
          with pkgs;
          lib.optionals stdenv.isDarwin (
            with pkgs.darwin.apple_sdk.frameworks;
            [
              # 常见 Rust crate 需要的 macOS 框架
              Security
              SystemConfiguration
              CoreFoundation
              IOKit
            ]
          );

      in
      {
        # 开发 Shell
        devShells.default = pkgs.mkShell {
          buildInputs = buildInputsCommon ++ buildInputsLinux ++ buildInputsDarwin;
          nativeBuildInputs =
            nativeBuildInputsCommon ++ nativeBuildInputsLinux ++ nativeBuildInputsDarwin ++ rustToolchain;

          # 环境变量
          RUST_BACKTRACE = "1";
          CARGO_INCREMENTAL = "1";
          RUST_LOG = "info";

          # macOS SDK 相关环境变量（通过 shellHook 注入，确保 clang 能找到 SDK）
          shellHook =
            let
              inherit (pkgs.stdenv) isDarwin;
            in
            if isDarwin then
              ''
                # 确保 Rust 编译器能找到 macOS SDK
                export SDKROOT=$(xcrun --sdk macosx --show-sdk-path 2>/dev/null || echo "")
                echo "🍎 macOS (nix-darwin) 开发环境已就绪"
              ''
            else
              ''
                echo "🐧 Linux 开发环境已就绪"
              '';
        };
      }
    )
    # ---- nix-darwin 系统级模块（macOS 上可选使用） ----
    // {
      darwinConfigurations = {
        # 示例：若要通过 nix-darwin 管理 macOS 系统，可取消注释并调整以下配置
        # builder = darwin.lib.darwinSystem {
        #   system = "aarch64-darwin";   # 或 "x86_64-darwin"
        #   modules = [
        #     ./darwin.nix             # 自定义 nix-darwin 模块
        #   ];
        # };
      };
    };
}
