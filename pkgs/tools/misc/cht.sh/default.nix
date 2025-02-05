{ lib, stdenv
, fetchFromGitHub
, unstableGitUpdater
, makeWrapper
, curl
, ncurses
, rlwrap
, xsel
}:

stdenv.mkDerivation {
  pname = "cht.sh";
  version = "unstable-2021-11-13";

  nativeBuildInputs = [ makeWrapper ];

  src = fetchFromGitHub {
    owner = "chubin";
    repo = "cheat.sh";
    rev = "4bb7b14843c302695b7d47d4d814f38998da1a68";
    sha256 = "NbB+UGydk0zSkqTPYw5KOHR0mv1UHH2pXLYdMRdG8UE=";
  };

  # Fix ".cht.sh-wrapped" in the help message
  postPatch = "substituteInPlace share/cht.sh.txt --replace '\${0##*/}' cht.sh";

  installPhase = ''
    install -m755 -D share/cht.sh.txt "$out/bin/cht.sh"

    # install shell completion files
    mkdir -p $out/share/bash-completion/completions $out/share/zsh/site-functions
    mv share/bash_completion.txt $out/share/bash-completion/completions/cht.sh
    cp share/zsh.txt $out/share/zsh/site-functions/_cht

    wrapProgram "$out/bin/cht.sh" \
      --prefix PATH : "${lib.makeBinPath [ curl rlwrap ncurses xsel ]}"
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/chubin/cheat.sh.git";
  };

  meta = with lib; {
    description = "CLI client for cheat.sh, a community driven cheat sheet";
    license = licenses.mit;
    maintainers = with maintainers; [ fgaz evanjs ];
    homepage = "https://github.com/chubin/cheat.sh";
    mainProgram = "cht.sh";
  };
}
