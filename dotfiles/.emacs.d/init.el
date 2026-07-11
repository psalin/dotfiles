;;; init.el --- Initialization file for Emacs -*- lexical-binding: t -*-
;;; Commentary:
;; Emacs Startup File --- initialization for Emacs

;;; Code:

;;; Functions

(eval-and-compile
  (defun emacs-path (path)
    (expand-file-name path user-emacs-directory)))

;; Git grep in the entire project
(defun my-helm-git-grep (not-all)
  (interactive "P")
  (helm-grep-git-1 default-directory t))
(global-set-key (kbd "C-c g") 'my-helm-git-grep)

;;; Bootstrap

(package-initialize)
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

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

(which-key-mode t)
(global-set-key (kbd "C-x f") #'nil)
(global-set-key [(shift left)]  'bs-cycle-previous)
(global-set-key [(shift up)]    'windmove-up)
(global-set-key [(shift right)] 'bs-cycle-next)
(global-set-key [(shift down)]  'windmove-down)

;; Use desktop-save-mode but prevent saving until its fully loaded in
;; order to not lose buffers when quitting before lazy loading is done
(desktop-save-mode t)
(require 'desktop)
(advice-add 'desktop-save :around
            (lambda (fn &rest args)
              (if (null desktop-buffer-args-list)
                  (apply fn args)
                (message "Buffers still loading, desktop not saved"))))

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

(use-package company
  :ensure t
  :defer t
  :hook ((python-mode . company-mode)))

(use-package company-anaconda
  :ensure t
  :after (anaconda-mode company)
  :init
  (add-to-list 'company-backends 'company-anaconda))

(use-package diff-hl
  :ensure t
  :hook ((dired-mode . diff-hl-dired-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (global-diff-hl-mode t)
  (unless (display-graphic-p) (diff-hl-margin-mode)))

(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode))

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
               ("<tab>"   . helm-execute-persistent-action)
               ("<left>"  . helm-previous-source)
               ("<right>" . helm-next-source)
               ("C-i"     . helm-execute-persistent-action)
               ("C-z"     . helm-select-action))
         (:map helm-command-map
               ("o" . helm-occur)))
  :functions helm-autoresize-mode
  :config
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

(use-package helm-projectile
  :ensure t
  :after (projectile helm)
  :config
  (setq projectile-completion-system 'helm)
  (helm-projectile-on)
  (define-key projectile-command-map (kbd "f") #'helm-projectile-find-file))

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

(when (display-graphic-p)
  (use-package org-beautify-theme
    :ensure t))

(use-package projectile
  :ensure t
  :defer t
  :bind-keymap ("C-c p" . projectile-command-map)
  :config
  (projectile-mode))

;; Jump between CamelCased words
(use-package subword
   :init (global-subword-mode t)
   :diminish subword-mode)

;;; Load external config
(when (file-exists-p (emacs-path "extra_init.el"))
  (load (emacs-path "extra_init")))

;;; Load settings
(setq custom-file "~/.emacs.d/custom.el")
(eval-and-compile
  (load (emacs-path "settings"))
  (when (file-exists-p (emacs-path "extra_settings.el"))
    (load (emacs-path "extra_settings")))
  (when (file-exists-p (emacs-path "custom.el"))
    (load (emacs-path "custom"))))

;;; init.el ends here
