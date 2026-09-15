{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, installShellFiles
}:

let
  version = "0.1.42";
  sources = {
    aarch64-linux = {
      url = "https://storage.googleapis.com/jules-cli/v${version}/jules_external_v${version}_linux_arm64.tar.gz";
      hash = "sha256-cB0Eo25xUC3G6p/Jc0U7IsoIVQatLLqmwLZzkX7N+/w=";
    };
    x86_64-linux = {
      url = "https://storage.googleapis.com/jules-cli/v${version}/jules_external_v${version}_linux_amd64.tar.gz";
      hash = "sha256-c869LI+Jubsk703MuM15Q8y2npmzfeJnwvV5Mjen0QM=";
    };
    aarch64-darwin = {
      url = "https://storage.googleapis.com/jules-cli/v${version}/jules_external_v${version}_darwin_arm64.tar.gz";
      hash = "sha256-iedh0tQC3dLObgY0Xf5HPfwCSxqYp2OZCQ9xPuKuklQ=";
    };
    x86_64-darwin = {
      url = "https://storage.googleapis.com/jules-cli/v${version}/jules_external_v${version}_darwin_amd64.tar.gz";
      hash = "sha256-CYqHk6+o1pMJmM9rQvr4+/RKjTZS7jBcAzWltybhFnQ=";
    };
  };
in
stdenv.mkDerivation {
  pname = "jules-cli";
  inherit version;

  src = fetchurl (sources.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}"));

  nativeBuildInputs = [
    installShellFiles
  ] ++ lib.optionals stdenv.isLinux [
    autoPatchelfHook
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -m755 -D jules $out/bin/jules

    # Attempt to generate shell completions if the binary can run in this environment
    HOME=$TMPDIR $out/bin/jules completion zsh 2>/dev/null | sed -n '/#compdef/,$p' > _jules || true
    if [ -s _jules ]; then
      installShellCompletion --zsh _jules
    fi

    HOME=$TMPDIR $out/bin/jules completion bash 2>/dev/null | sed -n '/# bash completion/,$p' > jules.bash || true
    if [ -s jules.bash ]; then
      installShellCompletion --bash jules.bash
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Jules, the asynchronous coding agent from Google, in the terminal";
    homepage = "https://jules.google";
    mainProgram = "jules";
    platforms = [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
  };
}
