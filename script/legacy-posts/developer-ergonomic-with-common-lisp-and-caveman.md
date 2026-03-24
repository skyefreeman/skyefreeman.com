---
layout: post
title: "Developer Ergonomics with Common Lisp"
date: "April 21th, 2023"
author: Skye Freeman
description: "Common Lisp is an incredible tool for writing software. Let's explore some simple ways to amplify productivity."
---
All of the websites that I maintain are being served with Common Lisp, utilizing the [Caveman2](https://github.com/fukamachi/caveman) web framework.

I've wanted to improve developer ergonomics for several common tasks, and consolidate to using the lisp repl for as much automation as possible. Namely, I want to speed up the process of:

- Loading a Lisp package.
- Stepping into a Lisp package.
- Starting a local web server.
- Launch any project specific development facilities.

Using [skyefreeman.com](https://skyefreeman.com) as an example (where you're currently reading this), I have a makefile that consolidates a number of tasks. One example is running `make develop` starts the [browsersync](https://browsersync.io) and [tailwindcss](https://tailwindcss.com) filewatchers:

```make
# Starts each facility for developing skyefreeman-web.
develop:
	browser-sync start --proxy "localhost:8080" --files "**/*" \
	& npx tailwindcss -i ./static/css/main.css -o ./static/css/generated/tailwind.css --watch \
```

Development of this website currently requires a number of setup commands before I start work:

1. Load the package with Quicklisp.

```cl
CL-USER> (ql:quickload :skyefreeman-web)
```

2. Step into the package.
```cl
CL-USER> (in-package :skyefreeman-web)
```

3. Start the webserver

```cl
SKYEFREEMAN-WEB> (start :port 8080)
```

4. Start development facilities (from a separate shell)
```bash
make develop
```

I have a package that loads automatically when starting up my lisp called **skyetools**, which I use to collect generally applicable functions between all my projects. Using [Roswell](https://github.com/roswell/roswell) to launch and manage a lisp implementation, a file at **~/.roswell/init.lisp** will get loaded alongside each startup. I generally try and treat "starting the lisp repl" the same as "starting the computer".

Here's my `~/.roswell/init.lisp`:

```cl
(ql:quickload :skyetools)
```
Everything in the `:skyetools` package will be available from the repl by default (`skyetools` is used as a namespace).

Step one and two from above can be consolidated into a single command, inside `skyetools`:

```cl
(defmacro into-package (keyword)
  "Load and move into the package defined by KEYWORD."
  `(progn
     (ql:quickload ,keyword)
     (in-package ,keyword)))
```

This loads and moves into the package in one fell swoop. We use a macro here to ensure the keyword maintains self-evaluation.

Next, step three and four of "starting the webserver" and "running development facilities" can also be consolidated:

First off, we write a function called `make-develop`. 

```cl
(defparameter *make-develop-process* nil)

(defun make-develop ()
  "Run the 'make develop' script, which starts the dev server."
  (uiop:chdir *application-root*)
  (let ((process (uiop:launch-program "make develop"
			       :input :stream
			       :output :stream)))
    (setq *make-develop-process* process)))
```

This wraps the `make develop` command that used to be called from an external shell, and launches it as an asynchronous program using `uiop`. The `process-info` object that gets returned is stored in the `*make-develop-process*` parameter, so that we can inspect and manage it independantly.

Now that `make develop` is callable from inside `:skyefreeman-web` package, we can wrap it inside another function to start the web server and call `make-develop` in one shot:

```cl
(defun start-dev ()
  (if (and (not (running?))
	   (equalp *make-develop-process* nil))
      (progn
	   (start :port 8080)
	   (make-develop))
      (error "Development server is already running.")))
```

This checks whether the server is running, and if not, starts everything up. 

While this whole exercise results in two small wrappers, this improvement greatly reduces the cognitive load of getting started on a new feature or bugfix. We could even take it a step further and wrap both `(into-package :skyefreeman-web)` and `(skyefreeman-web:start-dev)`, making this a single command for switching work contexts immediately - from anywhere in my filesystem.

For posterity, here's a number of other functions for stopping the dev server, and managing spawned processes that may be handy

```cl
(defun process-kill (process)
  (uiop:close-streams process)
  (uiop:terminate-process process))

(defun process-output (process)
  "Print the output from the given process."
  (let ((stream (uiop:process-info-output process)))
    (loop while (listen stream) do
      (princ (read-line stream))
      (terpri))))

(defparameter *make-develop-process* nil)
(defun make-develop ()
  "Run the 'make develop' script, which starts the dev server."
  (uiop:chdir *application-root*)
  (let ((process (uiop:launch-program "make develop"
			       :input :stream
			       :output :stream)))
    (setq *make-develop-process* process)))
	
(defun start-dev ()
  (if (and (not (running?))
	   (equalp *make-develop-process* nil))
      (progn
	(start :port 8080)
	(make-develop))
      (error "Development server is already running.")))

(defun stop-dev ()
  (stop)
  (process-kill *make-develop-process*)
  (setq *make-develop-process* nil)

  ;; This closes browsersync
  (uiop:run-program "lsof -t -i tcp:3000 | xargs kill")) 
```

I've found that spending the time to incorporate external tools into lisp has a compounding effect. Anything can become lisp code, whether it's a non-lisp programming language, or any format of data. A shell command can easily be bridge and utilized from within a lisp program, as if it was a part of the language.

Scripts, tools, code generation, the web server and everything else. It's all part of the same lisp program, and writing tools for building your program faster can all live in the same place.

Writing a set of functions for generating new files, html templates, server deployment, or running tests. These can all just be lisp functions that live within the same package/program. 

The experience of writing lisp is a constant upward ascent, where every line of code you write has the ability to amplify future output. Your lisp program **is** the development environment.
