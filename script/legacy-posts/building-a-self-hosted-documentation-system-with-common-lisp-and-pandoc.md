---
layout: post
title: "Building a Documentation System with Common Lisp and Pandoc"
date: "April 25, 2023"
author: Skye Freeman
description: "Lets look at the current landscape of existing documentation engines, then ignore all of it and write our own using Common Lisp."
image: "/images/banner-building-documentation-system-with-common-lisp.jpg"
url_slug: building-a-documentation-system-with-common-lisp-and-pandoc
---
I'm currently working through a first draft of a custom self-hosted documentation system for [SwiftStarterKits](https://swiftstarterkits.com). I wrote about the overall goals of this system [yesterday](/blog/writing-a-documentation-system), and is definitely recommended reading for continuity.

## Why not use something off the shelf?

There are plenty of pre-built documentation generators. Some are general purpose documentation frameworks ([Docusaurus](https://docusaurus.io), [GitBook](https://www.gitbook.com/?ref=producthunt)), others focus on specific stacks or technologies ([DocC](https://developer.apple.com/documentation/docc), [Nextra](https://nextra.site), [Sphinx](https://www.sphinx-doc.org/en/master/)). I could potentially save a ton of time by using one of these, lets walk through the few that I've played with.

### DocC

The internal SwiftStarterKits API reference is already using DocC. That's a no brainer, given it's built into Xcode and Swift Package Manager. But when it comes to exporting and hosting the system on an existing website, I ran into some major quirks that just weren't worth the time expendature to figure out:

- The exported `doccarchive` (what is generated when you "export" documentation) is a SPA built with Vue.js. An index.html file is generated alongside tons of nested folders and resources, and requires a running webserver plus dedicated routing rules to work. The embedded base URL's from the generated Javascript files implicitly assume specific routing rules, which **can** be changed, but is designed to exist on a dedicated web server. Unfortunately, this isn't what I want.

- There are divergent sets of documentation between using [DocC](https://developer.apple.com/documentation/xcode/distributing-documentation-to-external-developers) via `xcodebuild docbuild`, versus using the [Swift-DocC](https://apple.github.io/swift-docc-plugin/documentation/swiftdoccplugin/generating-documentation-for-hosting-online) plugin through SPM: `swift package generate-documentation`. Commands for transforming documentation output for use in a static hosting environment exist, but we don't have full control over routing rules (an extra /documentation is appended, meaning the `starterkit` package will have docs located at **swiftstarterkits.com/documentation/starterkit/documentation**. This capability is only for swift packages at this time (as far as I can tell), and isn't supported via xcodebuild. This would only cover half the SwiftStarterKits library, making this a non-starter for now.

### Docusaurus

Having spent days going down the DocC self-hosting rabbit hole, I looked around at other choices. [Docusaurus]([Docusaurus](https://docusaurus.io)) is a highly praised open source documentation system backed by Meta Open Source, which I gave a shot.

Long story short, similar problems to DocC. 

Docusaurus aims to be a complete website generator in a box, and also doesn't make it easy to host alongside an existing set of webpages served from a custom router. Tons of React and Node conventions are used, and I'm just not interested in dealing with the mental overhead of a separate software stack.

## What is documentation anyways?

Text. It's all just text. The software industry builds massive commercial systems around what is essentially just plain text. All of these off the shelf documentation systems bring with it a huge set of complexities and a web of intricate dependencies that I don't really want to invest in. 

Documentation is **just text**. Taking a server side rendering approach  means we just need to generate HTML, then provide custom routing rules on how to find individual and grouped documents. This minimal approach eschews most of the complexity of the modern web, keeps the website fast, small and content focused.

## Building a minimal documentation system with Lisp

Common Lisp gives us all the tools we need provide the needed structure for organizing our text. We're going to be writing documentation in markdown and converting them into HTML. [Pandoc](https://pandoc.org) solves this problem wonderfully, and is very well documented.

### Wrapping Pandoc

First, lets write a small wrapper for the Pandoc command line interface, enabling us to call into it from Lisp:

```cl
(defun pandoc (input-path from to)
  (let ((command-str
	  (format nil "pandoc ~a -f ~a -t ~a" input-path from to)))
    (uiop:run-program command-str :output :string)))
```

Here, we use `format` to create the command string, utilizing the `-f` and `-t` flags for defining the input and output file types ("from" and "to", respectively). `input-path` allows us to pass in the filepath that we'd like to convert. Last, we use `uiop:run-program` to run the shell command synchronously. The rest of the Pandoc CLI isn't needed right now.

Here's an example call to the `pandoc` function which we can call from our program or from the repl (which conceptually are the same thing!):

```cl
> (pandoc
	  #P"~/dev/starterkit/starterkit-web/views/docs/markdown/introduction.md" 
	  "markdown"
	  "html")

> "<h1 id=\"introduction\">Introduction</h1>
  <p>Welcome to the SwiftStarterKits documentation.</p>"
```

Manually typing the filepath, input, and output type is error prone. We'll improve on the ergonomics of this later.

### Generating HTML

Now that we have our bridge to call Pandoc, we can now provide markdown input files, and generate html output files. Lets deal with managing the file paths of our system:

```cl
(defparameter *application-root* (asdf:system-source-directory :starterkit-web))
(defparameter *doc-directory* (merge-pathnames #P"views/docs/" *application-root*))
(defparameter *input-directory* (merge-pathnames #P"markdown/" *doc-directory*))
(defparameter *output-directory* (merge-pathnames #P"posts/" *doc-directory*))
```

By convention, parameters surrounded by a set of asterisk `*` denotes a mutable variable (these are called "earmuffs").

To ensure these filepaths are portable between systems, we first denote a `*application-root*` parameter, which will be dynamic and point towards wherever this lisp package is located in the filesystem (we get this by calling `asdf:system-source-directory`, passing the name of our package). In this case, the function will return `~/dev/starterkit/starterkit-web`.

Next, `*doc-directory*` is defined, returning `/starterkit-web/views/docs`. This is where all of our documentation files will live for both the input markdown (which will be our source of truth), and the output html.

Last, `*input-directory*` and `*output-directory*` are defined, pointing to `/starterkit-web/views/docs/markdown` and `/starterkit-web/views/docs/posts/` respectively. The path name "posts" is used just to conform to the internal naming conventions I already use for the blog (`/starterkit-web/views/blog/posts/`).

Given this bit of enforcement on basic filesystem structure, we can deal with the filenames themselves:

```cl
(defun naked-filename (filepath)
  "Given a FILEPATH, return the FILENAME without its file type or path."
  (first
   (ppcre:split #\. (file-namestring filepath))))

(defun html-filename (filepath)
  "Given a FILEPATH, return the FILENAME as an html file type."
  (format nil "~a.html" (naked-filename filepath)))
```

`naked-filename` recieves a file path, and returns the file's name without a filetype extension or any path information. Calling this function looks like this:

```cl
> (naked-filename #P"/path/to/file/document.md")
> "document"
```

`html-filename` does something similar to `naked-filename`, but appends ".html" to the end of the string.

```cl
> (html-filename #P"/path/to/file/document.md")
> "document.html"
```

Now that we have primitives for filenames and filepaths, lets build a function for writing text to the filesystem.

```cl
(defun file-write-contents* (output-path input)
  "Given a OUTPUT-PATH and an INPUT string, write the INPUT to a file at OUTPUT-PATH."
  (with-open-file (stream
		   output-path
		   :direction :output
		   :if-exists :supersede
		   :if-does-not-exist :create)
    (format stream input)))
```

`file-write-contents*` is just a wrapper function, which has a trailing asterisk to conventionally denote that calling it has side effects (writing to the filesystem). 

The function recieves a filepath and an input string, then uses `with-open-file` to create a lexically scoped stream which `format` can write to. Additionally, we pass several function keys supported by the `with-open-file` function for specifying file overwrite and creation rules (if it already exists overwrite the file, and if it doesn't exist create the file).

Now, we can put all of our helper functions together. We'll write a function to recieve a markdown filename, associate it with a complete filepath in the `docs/markdown/` directory, convert it to html, then write it to an html file in the `docs/posts/` directory.

```cl
(defun generate-post-from-markdown* (filename)
  "From a .md file in the /posts/markdown/ directory, generate a new blog post."
   
  (let* ((input-path
           (merge-pathnames filename *input-directory*))
	     
		 (output-filename
	       (html-filename input-path))
	     
		 (output-filepath
	       (merge-pathnames output-filename *output-directory*))
	     
		 (output-string
           (pandoc input-path "markdown" "html"))
         
		 ;; `format` treats '~' as a directive.
	     (cleaned-output-string
           (cl-ppcre:regex-replace-all "~" output-string "~~")))
		   
    (file-write-contents* output-filepath cleaned-output-string)))
```

In `generate-post-from-markdown*` We first create bindings for `input-path`, `output-filename`, `output-filepath` and `output-string` using the computed values from calling our convenience functions. The `cleaned-output-string` value is added to fix a slight gotcha when passing external text into the format function. 

A tilde character (~) within the string that we pass to format will trigger a directive (which the format function will use for interpolation, there's a great article about Lisp format directives [on Wikipedia](https://en.wikipedia.org/wiki/Format_(Common_Lisp)#Directives)). In this case we escape all tilde instances with an extra "~", turning  "~" into "~~".

Last, we call our `file-write-contents*` function from before, passing all of our computed values, writing the new html file to the system. 

## Next steps

And there we have it, the beginnings of a minimal document generator which gives us the power to:

- Write documents in markdown.
- Convert these documents from markdown to html.
- Provide filesystem structure to our document system.

Because we're using Lisp, all of the functions that were just written are interactive, and can be called from the repl of our running program. The process of writing a new document means interacting with our system in real time.

As a next step, we can plan to use these primitives and extend the system in a variety of ways:

- Interactively generate new markdown files.
- Wrap the generated html within a separate html template to provide styling (easy with the [tailwindcss typography plugin](https://tailwindcss.com/docs/typography-plugin)). 
- Generate a table of contents using document names, or embedded markdown metadata.
- Generate an in-document table of contents by scraping files for markdown section headers.
- Generate document filters or tags, again by adding markdown metadata and scraping it.

All of these can be solved by a one off Lisp function, maintaining our markdown as the source of truth. We could even go a step further and write a local development tool for regenerating html files everytime a markdown file changes (you know, rather than continuously calling one of our `generate` functions).
