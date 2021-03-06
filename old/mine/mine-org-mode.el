(add-path "site-lisp/org-mode/lisp")
(require 'org)
(add-to-list 'org-modules 'org-habit)
(add-to-list 'org-modules 'org-protocol)
(add-to-list 'org-modules 'org-timer)
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

;; configuration
(setq org-custom-el "~/org/org-custom.el")
(if (file-exists-p org-custom-el)
 (load org-custom-el))

;; automatically save org buffers
(run-at-time t 300 'org-save-all-org-buffers)

;; display configuration
(setq org-completion-use-ido t
      org-hide-leading-stars t
      org-odd-levels-only t
      org-tags-column -92
      org-blank-before-new-entry nil
      org-startup-folded 'content
      org-columns-default-format "%75ITEM %TODO %Effort{+} %TAGS")

(setq org-use-property-inheritance t)

;; no extra line at the end
(add-hook 'org-mode-hook 'mine-leave-whitespace-in-buffer)

;; allow yasnippet
(add-hook 'org-mode-hook
          '(lambda ()
             (org-set-local 'yas/trigger-key [tab])
             (define-key yas/minor-mode-map [tab] 'yas/expand)))

;; todo configuration
(setq org-enforce-todo-dependencies t
      org-todo-keywords '((sequence "TODO(t)" "WAIT(w!)" "INPROGRESS(i!)" "WATCH(a)" "REVIEW(r!)" "DELEGATED(l!)" "|" "DONE(d!)" "CANCELED(c)"))
      org-use-fast-todo-selection t
      org-default-priority 85)

;; logging configuration
(setq org-log-into-drawer "LOGBOOK"
      org-log-done 'time)


(add-hook 'org-mode-hook
          '(lambda ()
             (toggle-truncate-lines nil)))

;; link configuration
(setq org-confirm-shell-link-function 'y-or-n-p)

;; refiling configuration
(setq org-refile-use-outline-path nil)

;; agenda configuraion
(setq org-agenda-search-headline-for-time nil
      org-agenda-dim-blocked-tasks 'invisible
      org-agenda-ndays 1
      org-agenda-skip-scheduled-if-done t
      org-agenda-skip-deadline-if-done t
      org-agenda-todo-ignore-scheduled 'future
      org-agenda-todo-ignore-deadlines nil
      org-deadline-warning-days 3
      org-agenda-tags-todo-honor-ignore-options t
      org-agenda-sorting-strategy '(tag-up time-up todo-state-down priority-down)
      org-agenda-compact-blocks t
      org-agenda-tags-column -92
      org-habit-show-habits-only-for-today nil
      org-habit-preceding-days 20
      org-habit-following-days 3
      org-habit-graph-column 55
      org-agenda-repeating-timestamp-show-all nil)

(setq org-file-apps
      (append org-file-apps '((directory . emacs))))


(autoload 'org-mobile-push "org-mobile" "Push the state of the org files to org-mobile-directory" t)
(autoload 'org-mobile-pull "org-mobile" "Pull the contents of org-mobile-capture-file" t)

(defadvice org-agenda-todo (before back-to-beginning)
  (beginning-of-line-or-back-to-indention))
(ad-activate 'org-agenda-todo)

;; org-timer pomodoro stuff
(defun org-timer-pomodoro-message-notify (msg)
  (case system-type
    ('darwin
     (growl-message msg))
    ('gnu/linux
     (start-process "pomodoro"
                    nil
                    "/usr/bin/notify-send"
                    msg))))

(defun org-timer-pomodoro-message-with-buffer (msg)
  (let ((pomodoro-buffer (get-buffer-create "*Pomodoro*")))
    (switch-to-buffer pomodoro-buffer)
    (delete-other-windows)
    (toggle-read-only -1)
    (erase-buffer)
    (insert msg)
    (toggle-read-only t)))

(defun org-timer-pomodoro-message-all (msg)
  (org-timer-pomodoro-notify-message msg)
  (org-timer-pomodoro-message-with-buffer msg))

(setq org-timer-default-timer 25)

(add-hook 'org-timer-set-hook '(lambda () (org-timer-pomodoro-message-notify "Starting pomodoro")))
(add-hook 'org-timer-done-hook
          '(lambda ()
             (org-timer-pomodoro-message-all "End of pomodoro: take a break")
             (org-clock-out t)))
(add-hook 'org-timer-cancel-hook '(lambda () (org-timer-pomodoro-message-notify "Canceling pomodoro")))

(add-hook 'org-clock-in-hook '(lambda () (if (not org-timer-current-timer)
                                             (org-timer-set-timer))))
(add-hook 'org-clock-out-hook '(lambda () (if org-timer-current-timer
                                              (org-timer-cancel-timer))))


;; org-mode presentation helpers
(defun mine-org-preso-next-subtree ()
  (interactive)
  (widen)
  (org-forward-same-level 1)
  (org-narrow-to-subtree))

(defun mine-org-preso-previous-subtree ()
  (interactive)
  (widen)
  (org-backward-same-level 1)
  (org-narrow-to-subtree))

(defun mine-org-preso-down-subtree ()
  (interactive)
  (next-line)
  (org-narrow-to-subtree))

(defun mine-org-preso-up-subtree ()
  (interactive)
  (widen)
  (outline-up-heading 1)
  (org-narrow-to-subtree))

;; navagation helpers
(defun gtd-agenda ()
  (interactive)
  (if (and (equal (buffer-name (current-buffer))
                  "*Org Agenda*"))
      (switch-to-buffer (other-buffer))
    (if (get-buffer "*Org Agenda*")
        (switch-to-buffer "*Org Agenda*")
      (progn
        (org-agenda nil "g")
        (delete-other-windows)))))

(defun gtd-find-inbox ()
  (interactive)
  (if (equal (buffer-name (current-buffer))
             "inbox.org")
      (switch-to-buffer (other-buffer))
    (switch-to-buffer "inbox.org")))

(defun gtd-someday-maybe ()
  (interactive)
  (if (equal (buffer-name (current-buffer))
             "someday-maybe.org")
      (switch-to-buffer (other-buffer))
    (find-file (concat org-directory "/someday-maybe.org"))))


;; key bindings
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cj" 'org-clock-goto)
(global-set-key "\C-cl" 'org-store-link)

(global-set-key (kbd "C-c g g") 'gtd-agenda)
(global-set-key (kbd "C-c g a") 'gtd-switch-to-agenda)
(global-set-key (kbd "C-c g i") 'gtd-find-inbox)
(global-set-key (kbd "C-c g s") 'gtd-someday-maybe)

(define-key org-mode-map (kbd "C-c C-,") 'org-priority)

;; for presentations
(define-key org-mode-map (kbd "<f5>") 'mine-org-preso-previous-subtree)
(define-key org-mode-map (kbd "<f6>") 'mine-org-preso-next-subtree)
(define-key org-mode-map (kbd "<f7>") 'mine-org-preso-up-subtree)
(define-key org-mode-map (kbd "<f8>") 'mine-org-preso-down-subtree)

;; Colors

(custom-set-faces
 '(outline-1 ((t (:foreground "#D6B163" :bold t))))
 '(outline-2 ((t (:foreground "#A5F26E" :bold t))))
 '(outline-3 ((t (:foreground "#B150E7" :bold nil))))
 '(outline-4 ((t (:foreground "#529DB0" :bold nil))))
 '(outline-5 ((t (:foreground "#CC7832" :bold nil))))
 '(org-level-1 ((t (:inherit outline-1))))
 '(org-level-2 ((t (:inherit outline-2))))
 '(org-level-3 ((t (:inherit outline-3))))
 '(org-level-4 ((t (:inherit outline-4))))
 '(org-level-5 ((t (:inherit outline-5))))
 '(org-agenda-date ((t (:inherit font-lock-type-face))))
 '(org-agenda-date-weekend ((t (:inherit org-agenda-date))))
 '(org-scheduled-today ((t (:foreground "#ff6ab9" :italic t))))
 '(org-scheduled-previously ((t (:foreground "#d74b4b"))))
 '(org-upcoming-deadline ((t (:foreground "#d6ff9c"))))
 '(org-warning ((t (:foreground "#8f6aff" :italic t))))
 '(org-date ((t (:inherit font-lock-constant-face))))
 '(org-tag ((t (:inherit font-lock-comment-delimiter-face))))
 '(org-hide ((t (:foreground "#191919"))))
 '(org-todo ((t (:background "DarkRed" :foreground "white" :box (:line-width 1 :style released-button)))))
 '(org-done ((t (:background "DarkGreen" :foreground "white" :box (:line-width 1 :style released-button)))))
 '(org-column ((t (:background "#222222"))))
 '(org-column-title ((t (:background "DarkGreen" :foreground "white" :bold t :box (:line-width 1 :style released-button))))))

(provide 'mine-org-mode)
