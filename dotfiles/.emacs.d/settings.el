;;; settings.el --- Settings file for Emacs -*- lexical-binding: t -*-
;;; Commentary:
;; Emacs Settings File --- for adding Emacs settings
;;; Code:

;; --- Color/Theme Settings ---
;; ANSI color configuration for terminal output
(setq ansi-color-faces-vector
      [default default default italic underline success warning error])
(setq ansi-color-names-vector
      ["#2e3436" "#a40000" "#4e9a06" "#c4a000" "#204a87" "#5c3566" "#729fcf" "#eeeeec"])

;; Theme customization
(setq custom-enabled-themes '(manoj-dark))

;; --- File/Backup Settings ---
;; Store backup files in a dedicated directory
(setq backup-directory-alist '(("." . "~/.emacs.d/emacssaves")))
;; Don't create lock files
(setq create-lockfiles nil)

;; --- Indentation Settings ---
;; Use spaces instead of tabs
(setq indent-tabs-mode nil)

;; --- UI Display Settings ---
;; Show column numbers in modeline
(setq column-number-mode t)
;; Don't show startup screen
(setq inhibit-startup-screen t)
;; Use visual line movement
(setq line-move-visual nil)
;; Hide toolbar
(setq tool-bar-mode nil)
;; Use visible bell instead of beeping
(setq visible-bell t)
;; Line length indicator
(setq whitespace-line-column 100)

;; --- Scrolling Behavior ---
;; Scroll by one line at a time
(setq scroll-conservatively 10000)
(setq scroll-step 1)
;; Keep context when scrolling to next screen
(setq next-screen-context-lines 2)

;; --- Session/Desktop Settings ---
;; Load locked desktop sessions
(setq desktop-load-locked-desktop t)
;; Eagerly restore 10 buffers when loading desktop
(setq desktop-restore-eager 10)
;; Enable auto-revert mode globally
(setq global-auto-revert-mode t)

;; --- File Listing Settings ---
(setq list-directory-brief-switches "-aF")
(setq list-directory-verbose-switches "-alsig")

;; --- Search/Helm Settings ---
;; Auto-resize the helm minibuffer
(setq helm-autoresize-mode t)
;; Limit git grep candidates for performance
(setq helm-git-grep-candidate-number-limit 3000)

;; --- Buffer Management ---
;; Delete duplicate history entries
(setq history-delete-duplicates t)
;; Clean old buffers every 14 days
(setq clean-buffer-list-delay-general 14)
;; Run midnight mode (periodically clean buffers)
(setq midnight-mode t)

;; --- Navigation Settings ---
;; Allow windmove to wrap around edges
(setq windmove-wrap-around t)
;; Disable mouse support in xterm
(setq xterm-mouse-mode nil)

;; --- Face/Appearance Settings ---
;; Use terminal's background color instead of forcing one
(set-face-attribute 'default nil :background "unspecified-bg")

;;; settings.el ends here
