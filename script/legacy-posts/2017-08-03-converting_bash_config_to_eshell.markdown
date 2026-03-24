---
layout: post 
title: Translating Your Bash Configuration to Eshell
date: 2017-08-03 19:53:39 
author: Skye Freeman 
categories: Programming Emacs
---

One of the mental barriers I had in making the switch over from iTerm2 + Bash to Emacs' Eshell was translating my `.bash_profile` (or `.bashrc` on some systems) into Emacs Lisp. Over the years my shell configuration has grown modestly, providing a slew of shortcuts, functions and styling customizations.

Eshell is not a shell emulator, instead it is a complete shell written from the ground up in Emacs Lisp. This difference provides the huge advantage of up opening your shell to every bit of Lisp available to Emacs, combined with the time tested power of a Unix shell. Shell programs can therefore be run interchangably with your Lisp programs. What's more, since it is all just Emacs Lisp - everything is customizable to the core.

The only upfront cost in configuration for Eshell is that any existing shell customizations you might have won't translate, since configuring Eshell works a little bit differently.

The majority of content in my `.bash_profile` are aliases, providing terse versions of sometimes hard to remember commands, or shortcuts to specific directories in my file system. The rest are shell functions (of which all have a built in Emacs counterpart), and visual tweaks to the command prompt. The bulk of the work comes in the form of alias conversions, so let's focus on that.

Adding new aliases to Eshell isn't too much of a farcry to your `.bash_profile`. Eshell maintains its own `Eshell` directory at the root of your Emacs configuration, this is where `aliases` and `history` files are stored for continued use by Eshell. Adding new aliases can happen in two ways, we can append `alias` declarations directly to the `eshell/aliases` file, or add them in an active eshell process by way of the `alias` function. On the whole, the syntax of an Eshell `alias`:

```bash
alias ll 'ls -la'
alias la 'ls -a'
```

is almost identical to that of it's bash counter part:
 
```bash
alias la='ls -a'
alias ll='ls -la'
```

To avoid copy/pasting our aliases, doctoring them, then copying them over one at a time into an Eshell process, let's instead write a little Emacs Lisp to automate the whole process. 

Breaking our task up conceptually, here's what we need to do: 

1) Create a function that is passed a filepath, read the file, split each line into its own string, and return a list of said strings.
2) Create a function that is passed a list of strings, filter out non-alias strings, then return only a list of aliases commands.
3) Create an interactive function that ties together step 1 and 2. First we'll open up Eshell, then iterate over the list of `alias` strings from step 2. Next, strip and format each string to match the structure of an Eshell alias command, then insert the new string directly into Eshell.

Starting with 1, let's call our "file splitting" function `read-lines`:

```lisp
(defun read-lines (FILEPATH)
  "Return a list of lines of a file at FILEPATH."
  (with-temp-buffer
    (insert-file-contents FILEPATH)
    (split-string (buffer-string) "\n" t)))
```

Running through `read-lines` one line at a time: `with-temp-buffer` creates a temporary emacs buffer and moves cursor focus to it. `insert-file-contents`, as its name suggests, inserts all the text from the passed file into our temporary buffer. Lastly, we retrieve the text in our temporary buffer as a single string using `buffer-string`, and split it into a list of strings deliminated by newline markers ("\n"). 

Beyond the context of our little experiment, `read-lines` is a useful little function that I recommend adding to your Emacs toolbox. Transforming entire text files into lists is infinitely useful, and can be handy for any file processing task that we can imagine.

Moving on to task 2, let's write the `extract-bash-aliases` function.

```lisp
(defun extract-bash-aliases (LIST)
  "Takes a LIST of strings, and transforms it into a list of shell aliases."
  (filter (lambda (string)
	    (and
	     (string-match-p (regexp-quote "alias") string)
	     (not (string-match-p (regexp-quote "#") string))))
	  LIST))
```

Filter works as it does in other languages, you provide an anonymous function that returns a boolean, and a list. Each element in the list is checked against our function, returning a new list with elements that pass our predicate. The anonymous function, denoted by `lambda`, processes each string in the list, checking whether the string contains the substring "alias", while also ensuring the line is not a comment (which start with "#" in a shell script).

Pausing for a second, I need to confess that the `filter` function used above is not built into Emacs Lisp, but is instead a helper function within my Emacs configuration. It recreates the functional mainstay using some core Emacs Lisp functions. Let's take a small detour and briefly discuss it:

```lisp
(defun filter (CONDITION LIST)
  (delq
   nil
   (mapcar
    (lambda (x)
      (and (funcall CONDITION x) x))
    LIST)))
```

This might look a little bit scary, but have no fear. `Filter` takes two arguments, a function that returns a boolean, and a list. Taking it from the top of `filter`: `delq` is a handy function that takes two variables, a matching predicate and a list. Conceptually, `delq` removes elements in a list that match the given value - which in this case is `nil`. The list provided to `delq` is created by the `mapcar` function, which transforms the contents of our original `LIST`. `mapcar` visits each element, and returns the element unchanged if our `CONDITION` evaluates to true, or nil if false. The result of this is in fact another list, which is mixed with elements that pass our condition, and nil values. `delq` then deletes all of the `nil` values (since that is what we told it get rid of), and the `filter` function finally returns the result.

Phew, that was some wild stuff. Moving on. The bread and butter that ties it all together - the `bash-to-eshell-aliases` function.

```lisp
(defun bash-to-eshell-aliases (BASHFILE)
  "Takes a BASHFILE, trims it to a list of alias commands, and inserts them as eshell aliases."
  (interactive "f")
  (eshell)
  (dolist (element (extract-bash-aliases (read-lines BASHFILE)))
    (let ((trimmed (replace-regexp-in-string "=" " " element)))
      (goto-char (point-max))
      (insert trimmed)
      (eshell-send-input))))
```

Our `bash-to-eshell-aliases` function takes a file that is assumed to be a bash configuration (bonus points if you add an assertion to verify it in fact, is). We first tell Emacs that this is an `interactive` function, passing the argument "f". "f" enforces the fact that, if we were to invoke this command interactively, you would be asked to insert a file path before the rest of the function evaluates, which is automatically binded to our function argument `BASHFILE`.

Next, the command `eshell` fires up a new Eshell process, while also moving cursor focus to the new buffer. The rest of the hard work has already been done, let's just piece it all together. `dolist` visits each element in a list, providing an immutable representation of the current element at each iteration. The list passed to `dolist` is the result of `read-lines` passed to `extract-bash-aliases`, producing a trimmed list of solely bash alias variables. 

Each element in our list is now converted to a new variable called `trimmed`, which replaces instances of "=" with a blank space. Next, we ensure that our cursor is at the very end of our Eshell buffer with `goto-char` set to `point-max`. Finally, we insert our newly `trimmed` Eshell alias and mimic a prompt return with `eshell-send-input`, which causes the alias to be inserted right into our Eshell configuration. These steps are then repeated for every element in our list.

And there we have it! We've automated the conversion of aliases in our `.bash_profile`, to their Eshell counterparts. 

Now for some quick reflection. The strategy I've described here makes a ton of assumptions, tailored to the structure and layout of my personal `.bash_profile`. Specifically, I'm assuming that a string containing the word "alias" is in fact an alias, or that a line that contains the symbol "#" is a comment (the word alias could be used as a variable of another function, or "#" could not be at the first space of a line, but instead after a valid bit of shell code). These are edge cases I chose to ignore due to the omission of them within my `.bash_profile`, but could be in yours (just a heads up!). Lastly, this conversion code will likely get you 99% of the way to a set of useable Eshell aliases. 

For example, if an aliased command expects to be called with an argument, Eshell requires the addition of a `$1`. This is due to the fact that the `alias` provided by Eshell is instead calling an Emacs Lisp function, which  requires an explicit argument if needed. In the shell, an alias is simply shorthand for a longer string, which is substituted at runtime. Passing an argument to an Eshell defined alias without a `$1` would be equivelent to passing an argument to a Lisp function that isn`t expecting one. Here's an example illustrating my point:

```bash
alias gc='git add -A && git commit -am '
```

translated to Eshell would be: 

```bash
alias gc 'git add -A && git commit -am $1'
```

Therefore, a little bit of customized "massaging" to your generated aliases might be required (sorry!).

One last note, [my Emacs][emacs-config] and [eshell configuration][eshell-config] is open-source, in addition to [the code we've just written][bash-to-eshell] in it's entirety. If you have any interest in how all of this fits into the rest of my Emacs environment, feel free to go check it out.

[emacs-config]: https://github.com/skyefreeman/.emacs.d
[eshell-config]: https://github.com/skyefreeman/.emacs.d/blob/master/custom/eshell-config.el
[bash-to-eshell]: https://github.com/skyefreeman/.emacs.d/blob/master/custom/bash-to-eshell-aliases.el
