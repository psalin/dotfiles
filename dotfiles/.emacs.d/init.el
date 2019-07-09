
;;; Functions

(eval-and-compile
  (defun emacs-path (path)
    (expand-file-name path user-emacs-directory))

  (defvar saved-window-configuration nil)

  (defun push-window-configuration ()
    (interactive)
    (push (current-window-configuration) saved-window-configuration))

  (defun pop-window-configuration ()
    (interactive)
    (let ((config (pop saved-window-configuration)))
      (if config
          (set-window-configuration config)
        (if (> (length (window-list)) 1)
            (delete-window)
          (bury-buffer))))))

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

;;; Libraries

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

(use-package helm-gtags
  :when (executable-find "global")
  :ensure t
  :defer t
  :init
  (add-hook 'dired-mode-hook 'helm-gtags-mode)
  (add-hook 'eshell-mode-hook 'helm-gtags-mode)
  (add-hook 'c-mode-hook 'helm-gtags-mode)
  (add-hook 'c++-mode-hook 'helm-gtags-mode)
  (add-hook 'asm-mode-hook 'helm-gtags-mode)
  (add-hook 'objc-mode-hook 'helm-gtags-mode)
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

(use-package projectile
  :ensure t
  :defer t
  :config
  (projectile-global-mode)
  (setq projectile-completion-system 'helm)
  (helm-projectile-on))

(use-package robot-mode
  :load-path "lisp"
  :commands robot-mode
  :init
  (add-to-list 'auto-mode-alist '("\\.robot\\'" . robot-mode)))

(use-package ttcn3
  :init
  (add-to-list 'auto-mode-alist '("\\.ttcn\\'" . ttcn-3-mode)))

(use-package yaml-mode
  :ensure t
  :defer t)

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(use-package flycheck-yamllint
  :ensure t
  :defer t
  :requires flycheck
  :hook (flycheck-mode . flycheck-yamllint-setup))

;;(setenv "GOPATH" "/home/esalipe/work/go")

;; (add-hook 'yaml-mode-hook 'flymake-yaml-load)

;; (load "robot-mode")
;; ;; ;;(load-file "~/.emacs.d/robot-mode.el")
;; (add-to-list 'auto-mode-alist '("\\.robot\\'" . robot-mode))

;; ;;
;; ;; Robot
;; ;;
;; ;; (defun my-robot-mode-hook ()
;; ;;   (local-set-key (kbd "M-.") 'robot-mode-find-kw))
;; ;; (add-hook 'robot-mode-hook 'my-robot-mode-hook)

;; ;;
;; ;; Go stuff
;; ;;
;; ;; (require 'go-guru)

;; ;; (defun my-go-mode-hook ()
;; ;;   ;; Call goimports before saving
;; ;;   (setq gofmt-command "goimports")
;; ;;   (add-hook 'before-save-hook 'gofmt-before-save)
;; ;;   ;; 'Go to definition' key binding
;; ;;   ;;(local-set-key (kbd "M-.") 'godef-jump))
;; ;;   (local-set-key (kbd "M-.") 'go-guru-definition) ;; Use go-guru def instead of godef

;; ;;   (setq compile-command "go build -v && go vet && golint")
;; ;;   (auto-complete-mode t)
;; ;;   (subword-mode 1))
;; ;; (add-hook 'go-mode-hook 'my-go-mode-hook)

;; ;; (add-hook 'go-mode-hook 'go-eldoc-setup)

;; ;; (with-eval-after-load 'go-mode
;; ;;    (require 'go-autocomplete))

;; ;;(require 'neotree)
;; (global-set-key [f8] 'project-explorer-toggle)

;; ;; HELM config
;; (require 'helm)
;; (require 'helm-config)

;; ;; faster grep
;; (global-set-key (kbd "<f3>")                 'helm-ag)
;; ;;(global-set-key (kbd "<f4>")                 'occur)
;; ;;(setq ag-highlight-search t)
;; ;;(setq ag-reuse-buffers t)

;; ;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; ;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; ;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
;; (global-set-key (kbd "C-c h") 'helm-command-prefix)
;; (global-unset-key (kbd "C-x c"))

;; (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
;; (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
;; (define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

;; (when (executable-find "curl")
;;   (setq helm-google-suggest-use-curl-p t))

;; (setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
;;       helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
;;       helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
;;       helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
;;       helm-autoresize-mode                  t
;;       helm-ff-file-name-history-use-recentf t)

;; (global-set-key (kbd "M-x") 'helm-M-x)
;; (global-set-key (kbd "C-x C-f") 'helm-find-files)
;; (global-set-key (kbd "M-y") 'helm-show-kill-ring)
;; (global-set-key (kbd "C-x b") 'helm-mini)
;; (global-set-key (kbd "C-c h o") 'helm-occur)
;; (global-set-key (kbd "M-i") 'helm-semantic-or-imenu)
;; (global-set-key (kbd "C-c C-v") 'ff-find-other-file)

;; (helm-mode 1)

;; ;; HELM gtags
;; (setq
;;  helm-gtags-ignore-case t
;;  helm-gtags-auto-update t
;;  helm-gtags-use-input-at-cursor t
;;  helm-gtags-pulse-at-cursor t
;;  helm-gtags-prefix-key "\C-cg"
;;  helm-gtags-suggested-key-mapping t
;;  )

;; (require 'helm-gtags)
;; ;; Enable helm-gtags-mode
;; (add-hook 'dired-mode-hook 'helm-gtags-mode)
;; (add-hook 'eshell-mode-hook 'helm-gtags-mode)
;; (add-hook 'c-mode-hook 'helm-gtags-mode)
;; (add-hook 'c++-mode-hook 'helm-gtags-mode)
;; (add-hook 'asm-mode-hook 'helm-gtags-mode)

;; (define-key helm-gtags-mode-map (kbd "C-c g a") 'helm-gtags-tags-in-this-function)
;; (define-key helm-gtags-mode-map (kbd "C-j") 'helm-gtags-select)
;; (define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-dwim)
;; (define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)
;; (define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
;; (define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history)

;; ;; Projectile
;; (projectile-global-mode)
;; (setq projectile-completion-system 'helm)
;; (helm-projectile-on)

;; (desktop-save-mode 1)

;; ;; Use bash in emacs shell
;; (setq explicit-shell-file-name "/bin/bash")
;; (setq shell-file-name "bash")
;; (setenv "SHELL" shell-file-name)

;; (setq scroll-step            1
;;       scroll-conservatively  10000)

;; (require 'whitespace)
;; (setq whitespace-line-column 100) ;; limit line length
;; (setq whitespace-style '(face lines-tail trailing tabs))

;; (add-hook 'c-mode-common-hook
;;           (lambda () (add-to-list 'write-file-functions 'delete-trailing-whitespace)))

;; ;; TTCN3
;; (load "ttcn3")

;; ;; Tide
;; ;; (defun setup-tide-mode ()
;; ;;   (interactive)
;; ;;   (tide-setup)
;; ;;   (flycheck-mode +1)
;; ;;   (setq flycheck-check-syntax-automatically '(save mode-enabled))
;; ;;   (setq create-lockfiles nil)
;; ;;   (eldoc-mode +1)
;; ;;   (subword-mode 1)

;; ;;   ;; company is an optional dependency. You have to
;; ;;   ;; install it separately via package-install
;; ;;   ;; `M-x package-install [ret] company`
;; ;;   (company-mode +1))

;; ;; ;; aligns annotation to the right hand side
;; ;; (setq company-tooltip-align-annotations t)

;; ;; ;; formats the buffer before saving
;; ;; ;;(add-hook 'before-save-hook 'tide-format-before-save)

;; ;; (add-hook 'typescript-mode-hook #'setup-tide-mode)

;; ;; ;; format options
;; ;; (setq tide-format-options '(:insertSpaceAfterFunctionKeywordForAnonymousFunctions t :placeOpenBraceOnNewLineForFunctions nil))

;; ;; Elpy
;; (elpy-enable)


;; (define-key global-map "\C-xf" 'nil)

;; (defun terminal-init-screen ()
;;   "Terminal initialization function for GNU screen."
;;   (when (boundp 'input-decode-map)
;;     (define-key input-decode-map "[1;5C" [(control right)])
;;     (define-key input-decode-map "[1;5D" [(control left)])))


;; (global-set-key [dead-tilde] 'insert-tilde )
;; (global-set-key [(shift left)]  'bs-cycle-previous)
;; (global-set-key [(shift up)]    'windmove-up)
;; (global-set-key [(shift right)] 'bs-cycle-next)
;; (global-set-key [(shift down)]  'windmove-down)

;; (setq backup-directory-alist `(("." . "~/.emacssaves")))

;; ;; Enable tilde
;; (defun insert-tilde ()
;;   "mg: inserts ~ at cursorposition"
;;   (interactive)
;;   (insert "~")
;;   )

;; (defun kill-other-buffers ()
;;   "Kill all other buffers."
;;   (interactive)
;;   (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))
