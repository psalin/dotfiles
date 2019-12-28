;;; init.el --- Initialization file for Emacs

;;; Commentary:
;; Emacs Startup File --- initialization for Emacs

;;; Code:

;;; Functions

(eval-and-compile
  (defun emacs-path (path)
    (expand-file-name path user-emacs-directory)))

;;; Bootstrap

(package-initialize)
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Download packages outside of repositories
(make-directory (emacs-path "lisp") :parents)

(unless (file-exists-p (emacs-path "lisp/robot-mode.el"))
  (url-copy-file "https://raw.githubusercontent.com/sakari/robot-mode/master/robot-mode.el" (emacs-path "lisp/robot-mode.el") t))

(unless (file-exists-p (emacs-path "lisp/ttcn3.el"))
  (url-copy-file "https://raw.githubusercontent.com/dholm/ttcn-el/master/ttcn3.el" (emacs-path "lisp/ttcn3.el") t))

;;; Environment

(eval-and-compile
  (setq load-path
        (append (delete-dups load-path)
                '("~/.emacs.d/lisp")))

  (require 'use-package)

  (if init-file-debug
      (setq use-package-verbose t
            use-package-expand-minimally nil
            use-package-compute-statistics t
            debug-on-error t)
    (setq use-package-verbose nil
          use-package-expand-minimally t)))

;;; Settings

(eval-and-compile
  (load (emacs-path "settings")))

(desktop-save-mode t)

(global-set-key (kbd "C-x f") #'nil)
(global-set-key [(shift left)]  'bs-cycle-previous)
(global-set-key [(shift up)]    'windmove-up)
(global-set-key [(shift right)] 'bs-cycle-next)
(global-set-key [(shift down)]  'windmove-down)

;;; Libraries
(use-package diminish
  :ensure t
  :demand t)

;;; Packages

(use-package anaconda-mode
  :ensure t
  :defer t
  :commands anaconda-mode
  :hook ((python-mode . anaconda-mode)
         (python-mode . anaconda-eldoc-mode)))

(use-package avy
  :ensure t
  :bind* ("C-c SPC" . avy-goto-char-timer)
  :config
  (avy-setup-default))

(use-package cc-mode
  :defer t
  :hook (c-mode-common . (lambda () (add-to-list 'write-file-functions 'delete-trailing-whitespace))))

(use-package company
  :ensure t
  :defer t
  :hook ((c++-mode . company-mode)
         (c-mode . company-mode)))

(use-package company-anaconda
  :ensure t
  :after (anaconda-mode company)
  :init
  (add-to-list 'company-backends 'company-anaconda))

(use-package company-irony
  :ensure t
  :after (irony company)
  :init
  (add-to-list 'company-backends 'company-irony))

(use-package diff-hl
  :ensure t
  :hook ((dired-mode . diff-hl-dired-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (global-diff-hl-mode t)
  (unless (display-graphic-p) (diff-hl-margin-mode)))

(use-package irony
  :ensure t
  :config
  (defun my-irony-mode-on ()
  ;; avoid enabling irony-mode in modes that inherits c-mode, e.g: php-mode
  (when (member major-mode irony-supported-major-modes)
    (irony-mode 1)))
  :hook ((c++-mode . my-irony-mode-on)
         (c-mode . my-irony-mode-on)
         (irony-mode . irony-cdb-autosetup-compile-options)))

(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode)
  :config
  (flycheck-add-next-checker 'c/c++-clang 'c/c++-cppcheck))

(use-package flycheck-yamllint
  :ensure t
  :defer t
  :requires flycheck
  :hook (flycheck-mode . flycheck-yamllint-setup))

(use-package groovy-mode
  :ensure t
  :defer t)

(use-package helm
  :ensure t
  :init
  (setq helm-command-prefix-key "C-c h")
  :bind (("M-x"     . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("M-y"     . helm-show-kill-ring)
         ("C-x b"   . helm-mini)
         ("M-i"     . helm-semantic-or-imenu)
         (:map helm-map
               ("<tab>" . helm-execute-persistent-action)
               ("C-i"   . helm-execute-persistent-action)
               ("C-z"   . helm-select-action))
         (:map helm-command-map
               ("o" . helm-occur)))
  :config
  (require 'helm-config)
  (when (executable-find "curl")
    (setq helm-google-suggest-use-curl-p t))

  (setq helm-split-window-inside-p            t  ; open helm in current window instead of other
        helm-move-to-line-cycle-in-source     t  ; wrap around when reaching to or bottom
        helm-ff-search-library-in-sexp        t  ; search for lib in 'require' and 'declare-function'
        helm-scroll-amount                    8  ; scroll 8 lines when using M-<next/prev>
        helm-ff-file-name-history-use-recentf t) ; use recentf-list in ff
  (helm-autoresize-mode t)
  (helm-mode 1))

(use-package helm-company
  :ensure t
  :defer t
  :bind ((:map company-mode-map
               ("M-,Av(B" . helm-company))
         (:map company-active-map
              ("M-,Av(B" . helm-company))))

(use-package helm-git-grep
  :ensure t
  :defer t)

(use-package helm-gtags
  :when (executable-find "global")
  :ensure t
  :defer t
  :hook ((dired-mode . helm-gtags-mode)
         (eshell-mode . helm-gtags-mode)
         (c-mode . helm-gtags-mode)
         (c++-mode . helm-gtags-mode)
         (asm-mode . helm-gtags-mode)
         (objc-mode . helm-gtags-mode))
  :bind (:map helm-gtags-mode-map
              ("C-c g a" . 'helm-gtags-tags-in-this-function)
              ("C-j"     . 'helm-gtags-select)
              ("M-."     . 'helm-gtags-dwim)
              ("M-,"     . 'helm-gtags-pop-stack)
              ("C-c <"   . 'helm-gtags-previous-history)
              ("C-c >"   . 'helm-gtags-next-history))
  :config
  (setq helm-gtags-ignore-case t
        helm-gtags-auto-update t
        helm-gtags-use-input-at-cursor t
        helm-gtags-pulse-at-cursor t
        helm-gtags-prefix-key "\C-cg"
        helm-gtags-suggested-key-mapping t))

(use-package helm-projectile
  :ensure t
  :defer t
  :after helm-projectile
  :config
  (setq projectile-completion-system 'helm)
  (helm-projectile-on))

(use-package helm-swoop
  :ensure t
  :bind (("M-m" . helm-swoop)
	 ("M-M" . helm-swoop-back-to-last-point)
         (:map isearch-mode-map
               ("M-m" . helm-swoop-from-isearch))
         (:map helm-swoop-map
               ("C-r" . helm-previous-line)
               ("C-s" . helm-next-line))
         (:map helm-multi-swoop-map
               ("C-r" . helm-previous-line)
               ("C-s" . helm-next-line))))

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

(use-package projectile
  :ensure t
  :defer t
  :bind-keymap ("C-c p" . projectile-command-map)
  :config
  (projectile-mode))

(use-package robot-mode
  :load-path "lisp"
  :commands robot-mode
  :init
  (add-to-list 'auto-mode-alist '("\\.robot\\'" . robot-mode)))

;; Jump between CamelCased words
(use-package subword
   :init (global-subword-mode t)
   :diminish subword-mode)

(use-package ttcn3
  :load-path "lisp"
  :init
  (add-to-list 'auto-mode-alist '("\\.ttcn\\'" . ttcn-3-mode)))

(use-package yaml-mode
  :ensure t
  :defer t)

(use-package yasnippet
  :ensure t
  :commands (yas-minor-mode)
  :hook (prog-mode . yas-minor-mode)
  :config
  (use-package yasnippet-snippets
    :ensure t)
  (yas-reload-all))

;;; Load external config
(when (file-exists-p (emacs-path "extra_init.el"))
  (load (emacs-path "extra_init")))

;;; init.el ends here
