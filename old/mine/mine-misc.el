;; ido-mode
(require 'ido)
(ido-mode t)
(ido-everywhere t)
(setq ido-default-file-method 'selected-window
      ido-default-buffer-method 'selected-window)
;; ido setup
(setq ido-enable-prefix nil
      ido-enable-flex-matching t
      ido-create-new-buffer 'always
      ido-use-filename-at-point t
      ido-max-prospects 10
      ido-show-dot-for-dired nil)

;; use uniquify
(require 'uniquify)
(setq
  uniquify-buffer-name-style 'post-forward
  uniquify-separator ":")

(require 'recentf)
(recentf-mode t)
(setq recentf-max-saved-items 50)

(require 'undo-tree)
(global-undo-tree-mode)

(winner-mode t)

;; Setup Environmental Variables
(setq default-major-mode 'text-mode)
(setq inhibit-startup-message t)

;; Auto revert files
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

(fset 'yes-or-no-p 'y-or-n-p)

(setq enable-recursive-minibuffers t)
(minibuffer-depth-indicate-mode t)

;; Buffer selection setup
(setq bs-configurations
      '(("all" nil nil nil nil nil)
        ("files" nil nil nil bs-visits-non-file bs-sort-buffer-interns-are-last)
        ("dired" nil nil nil
         (lambda (buf)
           (with-current-buffer buf
             (not (eq major-mode 'dired-mode)))) nil)
        ("magit" nil nil nil
         (lambda (buf)
           (with-current-buffer buf
             (not (eq major-mode 'magit-mode)))) nil)
        ("ensime" nil nil nil
         (lambda (buf)
           (with-current-buffer buf
             (not (string-prefix-p "*inferior-ensime" (buffer-name buf))))) nil)
        ("sql" nil nil nil
         (lambda (buf)
           (with-current-buffer buf
             (and
              (not (eq major-mode 'sql-mode))
              (not (eq major-mode 'sql-interactive-mode))))) nil)))

(setq bs-mode-font-lock-keywords
  (list
   ; Headers
   (list "^[ ]+\\([-M].*\\)$" 1 font-lock-keyword-face)
   ; Boring buffers
   (list "^\\(.*\\*.*\\*.*\\)$" 1 font-lock-comment-face)
   ; Dired buffers
   '("^[ .*%]+\\(Dired.*\\)$" 1 font-lock-type-face)
   ; Modified buffers
   '("^[ .]+\\(\\*\\)" 1 font-lock-warning-face)
   ; Read-only buffers
   '("^[ .*]+\\(\\%\\)" 1 font-lock-variable-name-face)))

(require 'switch-window)

;; edit server for chrome
(require 'edit-server)
(setq edit-server-new-frame t)
(edit-server-start)

;; Always use subwords to to move around
(if (fboundp 'subword-mode)
    (subword-mode t)
  (c-subword-mode t))

(add-hook 'dired-load-hook
          (lambda ()
            (load "dired-x")
            (define-key dired-mode-map (kbd "M-RET") 'dired-external-open)
            ;; Set dired-x global variables here.  For example:
            ;; (setq dired-guess-shell-gnutar "gtar")
            ;; (setq dired-x-hands-off-my-keys nil)
            ))


;; multi-shell
(setq multi-shell-command "/bin/zsh")
(setq multi-shell-revert-window-after-complete nil)
(autoload 'multi-shell-new "multi-shell" nil t)
(autoload 'multi-shell-next "multi-shell" nil t)

;; Tramp Optimizations
(setq tramp-default-method "ssh")

(defun mine-multi-shell-next ()
  (interactive)
  (let ((buf (buffer-name)))
    (multi-shell-next)
    (if (eq (buffer-name) buf)
        (switch-to-other-buffer))))

(defun mine-multi-shell-switch-dir ()
  (interactive)
  (let ((dir default-directory))
    (mine-multi-shell-next)
    (comint-send-string (current-buffer) (concat "cd " dir "\n"))
    (cd dir)))

(add-hook 'term-mode-hook '(lambda ()
                             (local-set-key (kbd "C-c C-j") 'term-line-mode)
                             (local-set-key (kbd "C-c C-k") 'term-char-mode)))



;; Use soft tabs
(setq-default indent-tabs-mode nil)

(autoload 'scratch "scratch" nil t)

;; Don't make backups
(setq make-backup-files nil)
(setq version-control nil)

;; Allow to be able to select text and start typing or delete
(delete-selection-mode t)

;; delete trailing whitespace on save
(setq mine-delete-trailing-whitespace t)
(defun mine-leave-whitespace-in-buffer ()
  (interactive)
  (make-variable-buffer-local 'mine-leave-whitespace)
  (setq mine-delete-trailing-whitespace nil))
(add-hook 'before-save-hook '(lambda () (if mine-delete-trailing-whitespace (delete-trailing-whitespace))))
;; (add-hook 'snippet-mode-hook 'mine-leave-whitespace-in-buffer)

;; auto indentation of yanked/pasted text
(setq major-modes-to-auto-indent-yanked-text '(emacs-lisp-mode
                                               clojure-mode
                                               c-mode
                                               c++-mode
                                               objc-mode
                                               ruby-mode))

(defun yank-and-indent ()
  (interactive)
  (yank)
  (call-interactively 'indent-region))

;; Misc Aliases
(defalias 'qrr 'query-replace-regexp)

;; Midnight mode to clean up old buffers
(require 'midnight)

;; Miscallaneous Things
(if (fboundp 'mouse-wheel-mode) (mouse-wheel-mode t))
(setq visible-bell t)

;; Protobuf files are like c
(add-to-list 'auto-mode-alist '("\\.proto\\'" . c-mode))

(provide 'mine-misc)
