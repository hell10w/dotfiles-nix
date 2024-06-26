{ callPackage, stdenv, pkgs, parinfer-rust }:

# let emacs = pkgs.emacsPgtkNativeComp; in
let emacs = pkgs.emacsPgtk; in

# (pkgs.emacsPackagesFor emacs).emacsWithPackages (epkgs: [
# ])

(pkgs.emacsPackagesFor emacs).emacsWithPackages (epkgs: ((with epkgs.melpaPackages; [
  use-package
  dash # https://github.com/magnars/dash.el
  f # https://github.com/rejeep/f.el
  s # https://github.com/magnars/s.el
  ht # https://github.com/Wilfred/ht.el
  gruvbox-theme
  evil evil-collection
  which-key smex
  ido-vertical-mode ido-yes-or-no
  vterm
  magit
  origami
  # lsp-mode company-lsp
  clojure-mode inf-clojure # cider
  erlang
  nix-mode
  hy-mode
  rust-mode
]) ++ (with epkgs.melpaStablePackages; [
  # fzf
]) ++ (with epkgs.elpaPackages; [
  company
  undo-tree
]) ++ [
  (callPackage ./parinfer-rust-mode { })
  (pkgs.runCommand "emacs-config" {} ''
    mkdir -p $out/share/emacs/
    cp -r ${./site-lisp} $out/share/emacs/site-lisp
  '')
]))
