(global-font-lock-mode 1)

;
; Jump into python mode for SCons files.
;
(setq auto-mode-alist (cons '("SCons.*$" . python-mode) auto-mode-alist))

(setq auto-mode-alist (cons '(".*\.x$" . c-mode) auto-mode-alist))

(setq auto-mode-alist (cons '(".*\.proto$" . c-mode) auto-mode-alist))

(defun add-to-load-path (path)
  (setq load-path (cons (expand-file-name path) load-path)))

(add-to-load-path "~/emacs/lisp")

;;;   (require 'windmove) ;;;2009-09-19 windmove now part of emacs
(windmove-default-keybindings)
(setq windmove-wrap-around t)

;; Use Autodetection of c-mode
(require 'guess-offset)

(autoload 'cscope-bind-keys "cscope" "Run cscope." t)
(setq cscope-master-info-table
      '( (nil ("jscope" "-l"))))
(autoload 'c-mode "cc-mode" "C Editing Mode" t)
(add-hook 'c-mode-hook
      '(lambda ()
         (or (where-is-internal 'cscope-find-c-symbol (current-local-map))
             (progn (local-unset-key "\C-c\C-s") (cscope-bind-keys))
             (local-set-key "\M-\r" 'cscope-find-c-symbol)
         )
      )
  )
(add-hook 'asm-mode-hook
      '(lambda ()
         (or (where-is-internal 'cscope-find-c-symbol (current-local-map))
             (progn (local-unset-key "\C-c\C-s") (cscope-bind-keys))
             (local-set-key "\M-\r" 'cscope-find-c-symbol)
         )
      )
  )
(add-hook 'c++-mode-hook
      '(lambda ()
         (or (where-is-internal 'cscope-find-c-symbol (current-local-map))
             (progn (local-unset-key "\C-c\C-s") (cscope-bind-keys))
             (local-set-key "\M-\r" 'cscope-find-c-symbol)
         )
      )
  )

(setq column-number-mode t)
