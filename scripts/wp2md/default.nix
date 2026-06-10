{ pkgs }:

pkgs.buildNpmPackage rec {
  pname = "wordpress-export-to-markdown";
  version = "3.0.5";

  src = pkgs.fetchFromGitHub {
    owner = "lonekorean";
    repo = "wordpress-export-to-markdown";
    rev = "v${version}";
    hash = "sha256-IwhZaAXsbxaXSIa+2JM8q4HnciW+FBVH0UtWI+UgHc8=";
  };

  npmDepsHash = "sha256-t+WsKFEfbTK6/ypQRfpczrL2QU/By505jAHQ/lBzAQY=";

  dontNpmBuild = true;

  meta = with pkgs.lib; {
    description = "Convert WordPress export XML files to Markdown";
    homepage = "https://github.com/lonekorean/wordpress-export-to-markdown";
    license = licenses.mit;
    mainProgram = "wordpress-export-to-markdown";
  };
}