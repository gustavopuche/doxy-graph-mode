;;; doxy-graph-mode.el --- Links source code editing with doxygen call graphs

;; Copiright (C) 2020 Gustavo Puche

;; Author: Gustavo Puche <gustavo.puche@gmail.com>
;; URL: https://github.com/gustavopuche/doxy-graph-mode
;; Created: 18 June 2020
;; Version: 0.6
;; Keywords: languages all
;; Package-Requires: ((emacs "26.3"))

;;; Commentary:

;; doxy-graph-mode links source code to doxygen call graphs.

;; It allows to interactively see the call graph or the inverted call
;; graph of a given function or method from source code.

;;; Code:

;; Latex path to concat to graph filename.
(defvar doxy-graph--latex-path nil
	"Directory name of doxygen latex documentation.")

;; Constans
(defvar doxy-graph--graph-suffix "_cgraph"
	"Added at the end of call graph filename.")

(defvar doxy-graph--inverted-graph-suffix "_icgraph"
	"Added at the end of inverted call graph filename.")

;; Sets doxygen latex path
(defun doxy-graph-set-latex-path ()
	"Opens a directory chooser and setup `doxy-graph--latex-path'."
	(interactive)
	(setq doxy-graph--latex-path (read-directory-name "Please choose doxygen latex folder:")))

;; Gets doxygen latex path
(defun doxy-graph-get-latex-path ()
	"Gets current doxygen latex path.

   If `doxy-graph--latex-path' is set returns it If not calls
   `doxy-graph-set-latex-path' to allow user choose project doxygen
   latex documentation folder."
	(if (not (null doxy-graph--latex-path))
			doxy-graph--latex-path
		(doxy-graph-set-latex-path)))

;; Gets word at cursor point
(defun doxy-graph-get-word-at-point ()
	"Gets word at cursor position."
	(interactive)
	(thing-at-point 'word 'no-properties))

;; Gets file name without folder nor extension.
(defun doxy-graph-file-name-base ()
	"Gets source code filename without extension."
	(interactive)
	(file-name-base buffer-file-name))

;; Gets file name extension.
(defun doxy-graph-file-name-extension ()
	"Gets source code file extension."
	(interactive)
	(file-name-extension buffer-file-name))

;; Gets latex file.
(defun doxy-graph-latex-file ()
	"Builds doxygen latex filename string.

Concats [source-code-filename-base] \"_8\"
[source-code-extension] \".tex\"."
	(interactive)
	(concat (doxy-graph-file-name-base) "_8" (doxy-graph-file-name-extension) ".tex"))

;; Opens new buffer with pdf call graph.
(defun doxy-graph-open-call-graph ()
	"Opens pdf call graph.

Shows call graph of the function or method at cursor."

	(interactive)
	(find-file-other-window
	 (concat (doxy-graph-get-latex-path)
					 (doxy-graph-filename (doxy-graph-get-word-at-point) "_cgraph")
					 ".pdf")))

;; Opens new buffer with pdf inverted call graph.
(defun doxy-graph-open-inverted-call-graph ()
	"Opens pdf inverted call graph.

Shows inverted call graph of the function or method at cursor
position."
	(interactive)
	(find-file-other-window
	 (concat (doxy-graph-get-latex-path)
					 (doxy-graph-filename (doxy-graph-get-word-at-point) "_icgraph")
					 ".pdf")))

;; Calls doxy-graph-gets-pdf-filename (latex-file function-name)
(defun doxy-graph-filename (function-name graph-type)
	"Gets pdf call graph filename.

Concatenates latex path with pdf call graph filename.

Argument FUNCTION-NAME is the function at cursor.

Argument GRAPH-TYPE can be \"_cgraph\" to regular call graph and
\"_icgraph\" for inverted call graph."
	(interactive)
	(doxy-graph-get-pdf-filename (concat (doxy-graph-get-latex-path) (doxy-graph-latex-file)) function-name graph-type))

;; Parses latex file to obtain pdf call graph.
(defun doxy-graph-get-pdf-filename (latex-file function-name graph-type)
	"Parses latex file and gets pdf filename to graph-type.

Argument LATEX-FILE is the latex file in which it parses pdf graph filename.

Argument FUNCTION-NAME is the function at cursor.

Argument GRAPH-TYPE can be \"_cgraph\" to regular call graph and
\"_icgraph\" for inverted call graph."
	(with-temp-buffer
		(insert-file-contents latex-file)
		(search-forward (concat "{" function-name "()}"))
		(search-forward "includegraphics")
		(let ((end-pos (search-forward graph-type))
					(begin-pos (search-backward "{")))
			(buffer-substring (+ begin-pos 1) end-pos))))

;;; Keymap
;;
;;
(defvar doxy-graph-mode-map (make-sparse-keymap)
	"Keybindings variable.")

;;;###autoload
(define-minor-mode doxy-graph-mode
  "doxy-graph-mode default keybindings."
  :lighter " doxy-graph"
  :keymap  doxy-graph-mode-map
	(define-key doxy-graph-mode-map (kbd "<C-f1>") 'doxy-graph-open-call-graph)
	(define-key doxy-graph-mode-map (kbd "<C-f2>") 'do1xy-graph-open-inverted-call-graph))

;;;###autoload
(add-hook 'c-mode-hook 'doxy-graph-mode)

;;;###autoload
(add-hook 'c++-mode-hook 'doxy-graph-mode)

(provide 'doxy-graph-mode)

;;; doxy-graph-mode.el ends here
