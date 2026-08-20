{ pkgs, ... }:
{
  home.packages = with pkgs; [ typst ];
  programs.pandoc = {
    enable = true;
    defaults = {
      citeproc = true;
      metadata.author = "Thierry Delafontaine";
      pdf-engine = "typst";
      standalone = true;
      variables = {
        mainfont = "Libertinus Serif";
        mathfont = "New Computer Math";
      };
    };
  };
}
