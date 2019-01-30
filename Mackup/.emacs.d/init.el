(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

(package-initialize)

;; Download the ELPA archive description if needed.
(when (not package-archive-contents)
  (package-refresh-contents))

(when (not (package-installed-p 'use-package))
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(use-package better-defaults
  :ensure t)

(use-package exec-path-from-shell
  :ensure t
  :config
  (setq exec-path-from-shell-check-startup-files nil)
  (exec-path-from-shell-initialize))

(use-package evil
  :ensure t
  :config
  (evil-mode 1))

(use-package one-themes
  :ensure t
  :config
  ; Override background colour
  (setcdr
    (assoc 'background (cdr (assoc 'light one-themes-colors)))
    "#FFFFFF")
  (load-theme 'one-light t))

(use-package powerline
  :ensure t
  :custom
  (powerline-default-separator 'wave))

(use-package spaceline
  :ensure t
  :after powerline
  :config
  (require 'spaceline-config)
  (spaceline-spacemacs-theme)
  ; Colour-code Evil state marker
  (setq spaceline-highlight-face-func 'spaceline-highlight-face-evil-state))

(use-package paredit
  :ensure t)

(use-package clojure-mode
  :ensure t)

(use-package clojure-mode-extra-font-locking
  :ensure t)

(use-package cider
  :ensure t
  :pin melpa-stable)

;; allow ido usage in as many contexts as possible
(use-package ido-completing-read+
  :ensure t
  :config
  (ido-ubiquitous-mode 1))

;; Enhances M-x to allow easier execution of commands. Provides
;; a filterable list of possible commands in the minibuffer
(use-package smex
  :ensure t)

(use-package projectile
  :ensure t)

(use-package rainbow-delimiters
  :ensure t)

(use-package magit
  :ensure t)


(set-frame-font "Monaco 13" nil t)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq inhibit-startup-screen t)

;; No need for ~ files when editing
(setq create-lockfiles nil)

;; No cursor blinking
(blink-cursor-mode 0)

;; full path in title bar
(setq-default frame-title-format "%b (%f)")

(ido-everywhere 1)
