;;; doxy-graph-mode.el --- Support for doxygen graph documentation called from source code.

;; Copiright (C) 2020 Gustavo Puche

;; Author: Gustavo Puche <gustavo.puche@gmail.com>
;; Created: 18 June 2020
;; Version: 0.2
;; Keywords: languages all
;; Package-Requires: 

;;; Code:

;; Latex path to concat to graph filename.
(defvar doxy-graph--latex-path nil)

;; Constans
(defvar doxy-graph--graph-suffix "_cgraph")

(defvar doxy-graph--inverted-graph-suffix "_icgraph")

;; Sets doxygen latex path
(defun doxy-graph-set-latex-path ()
	(interactive)
	(setq doxy-graph--latex-path (read-directory-name "Please choose doxygen latex folder:"))
	)

;; Gets doxygen latex path
(defun doxy-graph-get-latex-path ()
	(if (not (null doxy-graph--latex-path))
			doxy-graph--latex-path
		(doxy-graph-set-latex-path)
			)
	)

;; Help of doxy-graph minor mode.
(defun doxy-graph-help ()
  (interactive)
  (setq foo-count (1+ foo-count))
  (insert "doxy-graph help keymap"))	

;; Gets word at cursor point
(defun doxy-graph-get-word-at-point ()
	(interactive)
	(thing-at-point 'word 'no-properties)
	)

;; Gets file name without folder nor extension.
(defun doxy-graph-file-name-base ()
	(interactive)
	(file-name-base buffer-file-name)
	)

;; Gets file name extension.
(defun doxy-graph-file-name-extension ()
	(interactive)
	(file-name-extension buffer-file-name)
	)

;; Gets tex file.
(defun doxy-graph-latex-file ()
	(interactive)
	(concat (doxy-graph-file-name-base) "_8" (doxy-graph-file-name-extension) ".tex")
	)

;; Opens new buffer with pdf call graph.
(defun doxy-graph-open-call-graph ()
	(interactive)	
	(find-file-other-window (concat (doxy-graph-get-latex-path) (doxy-graph-filename (thing-at-point 'word 'no-properties) "_cgraph") ".pdf"))
	)

;; Opens new buffer with pdf inverted call graph.
(defun doxy-graph-open-inverted-call-graph ()
	(interactive)	
	(find-file-other-window (concat (doxy-graph-get-latex-path) (doxy-graph-filename (thing-at-point 'word 'no-properties) "_icgraph") ".pdf"))
	)

;; Parses latex file to obtain pdf call graph.
(defun doxy-graph-get-pdf-filename (latex-file function-name graph-type)
	(with-temp-buffer
		(insert-file-contents latex-file)
		(search-forward (concat "{" function-name "()}"))
		(search-forward "includegraphics")
		(let
				((end-pos (search-forward graph-type))
				 (begin-pos (search-backward "{"))
				 )
			(buffer-substring (+ begin-pos 1) end-pos)
			)
		)
	)

;; Calls doxy-graph-gets-pdf-filename (latex-file function-name)
(defun doxy-graph-filename (function-name graph-type)
	(interactive)
	(doxy-graph-get-pdf-filename (concat (doxy-graph-get-latex-path) (doxy-graph-latex-file)) function-name graph-type)
	)

;; Keymap.
(defvar doxy-graph-mode-map (make-sparse-keymap))

;;;###autoload
(define-minor-mode doxy-graph-mode
  "Get your foos in the right places."
  :lighter " doxy-graph"
  :keymap  doxy-graph-mode-map
	(define-key doxy-graph-mode-map (kbd "<C-f1>") 'doxy-graph-help)
	(define-key doxy-graph-mode-map (kbd "<C-f2>") 'doxy-graph-get-word-at-point)
	(define-key doxy-graph-mode-map (kbd "<C-f3>") 'doxy-graph-file-name-base)
	(define-key doxy-graph-mode-map (kbd "C-c c") 'doxy-graph-open-call-graph)
	(define-key doxy-graph-mode-map (kbd "C-c i") 'doxy-graph-open-inverted-call-graph)
	)

;;;###autoload
(add-hook 'c-mode-hook 'doxy-graph-mode)

;;;###autoload
(add-hook 'c++-mode-hook 'doxy-graph-mode)

(provide 'doxy-graph-mode)
