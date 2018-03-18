;;; mpdel.el --- Play and control your MPD music  -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Damien Cassou

;; Author: Damien Cassou <damien@cassou.me>
;; Keywords: multimedia
;; Url: https://gitlab.petton.fr/mpdel/mpdel
;; Package-requires: ((emacs "25.1") (libmpdel "0.3.0"))
;; Version: 0.3.0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; MPDel is an Emacs client for Music Player Daemon (MPD), a flexible,
;; powerful, server-side application for playing music.  This project
;; provides an Emacs user interface including playlists, navigation in
;; the database and playback control.  Read the README.org file for
;; more information.

;;; Code:

(require 'libmpdel)
(require 'mpdel-core)
(require 'mpdel-playlist)
(require 'mpdel-song)
(require 'mpdel-nav)


;;; Customization
(defgroup mpdel nil
  "Configure mpdel's global minor mode."
  :group 'libmpdel)

(defcustom mpdel-prefix-key (kbd "C-x Z")
  "Prefix key to all global mpdel keybindings."
  :type 'key-sequence)


;;; Add features to all mpdel buffers
(defun mpdel-song-small-increment ()
  "Move forward by value of variable `mpdel-song-small-increment'."
  (interactive)
  (mpdel-song--seek mpdel-song-small-increment))

(define-key mpdel-core-map (kbd "F") #'mpdel-song-small-increment)

(defun mpdel-song-normal-increment ()
  "Move forward by value of variable `mpdel-song-normal-increment'."
  (interactive)
  (mpdel-song--seek mpdel-song-normal-increment))

(define-key mpdel-core-map (kbd "f") #'mpdel-song-normal-increment)

(defun mpdel-song-large-increment ()
  "Move forward by value of variable `mpdel-song-large-increment'."
  (interactive)
  (mpdel-song--seek mpdel-song-large-increment))

(define-key mpdel-core-map (kbd "M-f") #'mpdel-song-large-increment)

(defun mpdel-song-small-decrement ()
  "Move backward by value of variable `mpdel-song-small-decrement'."
  (interactive)
  (mpdel-song--seek mpdel-song-small-decrement))

(define-key mpdel-core-map (kbd "B") #'mpdel-song-small-decrement)

(defun mpdel-song-normal-decrement ()
  "Move backward by value of variable `mpdel-song-normal-decrement'."
  (interactive)
  (mpdel-song--seek mpdel-song-normal-decrement))

(define-key mpdel-core-map (kbd "b") #'mpdel-song-normal-decrement)

(defun mpdel-song-large-decrement ()
  "Move backward by value of variable `mpdel-song-large-decrement'."
  (interactive)
  (mpdel-song--seek mpdel-song-large-decrement))

(define-key mpdel-core-map (kbd "M-b") #'mpdel-song-large-decrement)

(defun mpdel-add-to-current-playlist ()
  "Add selected entities to current playlist."
  (interactive)
  (libmpdel-current-playlist-add (mpdel-core-selected-entities)))

(define-key mpdel-core-map (kbd "a") #'mpdel-add-to-current-playlist)

(defun mpdel-add-to-stored-playlist ()
  "Add selected entities to a stored playlist."
  (interactive)
  (libmpdel-stored-playlist-add (mpdel-core-selected-entities)))

(define-key mpdel-core-map (kbd "A") #'mpdel-add-to-stored-playlist)

(defun mpdel-replace-current-playlist ()
  "Replace current playlist with selected entities."
  (interactive)
  (libmpdel-current-playlist-replace (mpdel-core-selected-entities)))

(define-key mpdel-core-map (kbd "r") #'mpdel-replace-current-playlist)

(defun mpdel-replace-stored-playlist ()
  "Replace a stored playlist with selected entities."
  (interactive)
  (libmpdel-stored-playlist-replace (mpdel-core-selected-entities)))

(define-key mpdel-core-map (kbd "R") #'mpdel-replace-stored-playlist)

(defun mpdel-dired (&optional pos)
  "Open dired on the entity at POS, point if nil."
  (interactive)
  (libmpdel-dired (mpdel-core-entity-at-point pos)))

(define-key mpdel-core-map (kbd "C-x C-j") #'mpdel-dired)

(define-key mpdel-core-map (kbd "l") #'mpdel-playlist-open)
(define-key mpdel-core-map (kbd "L") #'mpdel-playlist-open-stored-playlist)
(define-key mpdel-core-map (kbd "n") #'mpdel-nav-open-artists)
(define-key mpdel-core-map (kbd "N") #'mpdel-nav-open-stored-playlists)
(define-key mpdel-core-map (kbd "v") #'mpdel-song-open)
(define-key mpdel-core-map (kbd "s s") #'mpdel-nav-search-by-title)
(define-key mpdel-core-map (kbd "s l") #'mpdel-nav-search-by-album)
(define-key mpdel-core-map (kbd "s r") #'mpdel-nav-search-by-artist)


;;; Add features to playlist buffers
(defun mpdel-playlist-song-navigate ()
  "Open a navigator containing song at point."
  (interactive)
  (mpdel-nav--open (libmpdel-entity-parent (mpdel-core-entity-at-point))))

(define-key mpdel-playlist-mode-map (kbd "^") #'mpdel-playlist-song-navigate)

(defun mpdel-playlist-open-song-at-point ()
  "Open buffer displaying information about song at point."
  (interactive)
  (mpdel-song-open (mpdel-core-entity-at-point)))

(define-key mpdel-playlist-mode-map (kbd "V") #'mpdel-playlist-open-song-at-point)


;;; Add features to the song buffers
(cl-defmethod mpdel-core--entity-at-point (_pos (_mode (derived-mode mpdel-song-mode)))
  (mpdel-song-buffer-song))

(defun mpdel-song-navigate ()
  "Open a navigator containing song at point."
  (interactive)
  (mpdel-nav--open (libmpdel-entity-parent (mpdel-song-buffer-song))))

(define-key mpdel-song-mode-map (kbd "^") #'mpdel-song-navigate)


;;; Add features to the navigator buffers
(cl-defmethod mpdel-nav--dive ((entity libmpdel-song))
  "When diving into a song, open a song buffer."
  (mpdel-song-open entity))


;;; Define the global minor mode so users can control MPD from non-MPD
;;; buffers
(defvar mpdel-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map mpdel-prefix-key 'mpdel-core-map)
    map)
  "Keymap activating variable `mpdel-core-map'.")

(define-minor-mode mpdel-mode
  "Activate keybindings to play and control your MPD server.

\\{mpdel-mode-map}"
  :global t
  :require 'mpdel
  :lighter " MPDel")

(provide 'mpdel)
;;; mpdel.el ends here

;;; LocalWords:  Mpdel mpdel
