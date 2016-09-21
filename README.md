# Simple TeX Live version management: tlenv

tlenv lets you easily switch between multiple versions of TeX Live. It's simple, unobtrusive, and follows the UNIX tradition of single-purpose tools that do one thing well.

This project was forked from rbenv (and ruby-build), and modified for TeX Live.

Use tlenv to set a TeX Live version for your document or application and guarantee
that your development environment matches production.

**Powerful in development.** Specify your TeX Live version once,
  in a single file. Just Works™ from the command line.
  Override the TeX Live version anytime: just set an environment variable.

**Rock-solid in production.** 
  The TeX Live version dependency lives in one place—your doc/app—so upgrades
  and rollbacks are  atomic, even when you switch versions.

**One thing well.** tlenv is concerned solely with switching TeX Live
  versions. It's simple and predictable. (Can be used plugin ecosystem).
  Specify TeX Live version as global or as local or as per folder basis.

## Table of Contents

* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the TeX Live Version](#choosing-the-texlive-version)
  * [Locating the TeX Live Installation](#locating-the-texlive-installation)
* [Installation](#installation)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
  * [How tlenv hooks into your shell](#how-tlenv-hooks-into-your-shell)
  * [Installing TeX Live Versions](#installing-latex-versions)
  * [Uninstalling TeX Live Versions](#uninstalling-latex-versions)
  * [Uninstalling tlenv](#uninstalling-tlenv)
* [Command Reference](#command-reference)
  * [tlenv local](#tlenv-local)
  * [tlenv global](#tlenv-global)
  * [tlenv shell](#tlenv-shell)
  * [tlenv versions](#tlenv-versions)
  * [tlenv version](#tlenv-version)
  * [tlenv rehash](#tlenv-rehash)
  * [tlenv which](#tlenv-which)
  * [tlenv whence](#tlenv-whence)
* [Environment variables](#environment-variables)
* [Development](#development)

## How It Works

At a high level, tlenv intercepts TeX Live commands using shim
executables injected into your `PATH`, determines which TeX Live version
has been specified by your document/application, and passes your commands along
to the correct TeX Live installation.

### Understanding PATH

When you run a command like `latex` or `dvips`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.

### Understanding Shims

tlenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    ~/.tlenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, tlenv maintains shims in that
directory to match every LaTeX command across every installed version
of TeX Live — `latex`, `dvips`, `maketexlsr`, `purifyeps`, `xdvi`, and so on.

Shims are lightweight executables that simply pass your command along
to tlenv. So with tlenv installed, when you run, say, `latex`, your
operating system will do the following:

* Search your `PATH` for an executable file named `latex`
* Find the tlenv shim named `latex` at the beginning of your `PATH`
* Run the shim named `latex`, which in turn passes the command along to
  tlenv

### Choosing the TeX Live version

When you execute a shim, tlenv determines which TeX Live version to use by
reading it from the following sources, in this order:

1. The `TLENV_VERSION` environment variable, if specified. You can use
   the [`tlenv shell`](#tlenv-shell) command to set this environment
   variable in your current shell session.

2. The first `.latex-version` file found by searching the directory of the
   script you are executing and each of its parent directories until reaching
   the root of your filesystem.

3. The first `.latex-version` file found by searching the current working
   directory and each of its parent directories until reaching the root of your
   filesystem. You can modify the `.latex-version` file in the current working
   directory with the [`tlenv local`](#tlenv-local) command.

4. The global `~/.tlenv/version` file. You can modify this file using
   the [`tlenv global`](#tlenv-global) command. If the global version
   file is not present, tlenv assumes you want to use the "system"
   TeX Live — i.e. whatever version would be run if tlenv weren't in your
   path.

### Locating the TeX Live Installation

Once tlenv has determined which version of TeX Live your application has
specified, it passes the command along to the corresponding TeX Live
installation.

## Installation

### Basic GitLab Checkout

This will get you going with the latest version of tlenv and make it
easy to fork and contribute any changes back upstream.

1. Check out tlenv into `~/.tlenv`.

    ~~~ sh
    $ git clone https://gitlab.vtex.lt/deimi/tlenv ~/.tlenv
    ~~~

2. Add `~/.tlenv/bin` to your `$PATH` for access to the `tlenv`
   command-line utility.

    ~~~ sh
    $ echo 'export PATH="$HOME/.tlenv/bin:$PATH"' >> ~/.bash_profile
    ~~~

    **Ubuntu Desktop note**: Modify your `~/.bashrc` instead of `~/.bash_profile`.

    **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.

3. Add `tlenv init` to your shell to enable shims and autocompletion.

    ~~~ sh
    $ echo 'eval "$(tlenv init -)"' >> ~/.bash_profile
    ~~~

    _Same as in previous step, use `~/.bashrc` on Ubuntu, or `~/.zshrc` for Zsh._

4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.) Now check if tlenv was set up:

    ~~~ sh
    $ type tlenv
    #=> "tlenv is a function"
    ~~~

#### Upgrading

If you've installed tlenv manually using git, you can upgrade your
installation to the cutting-edge version at any time.

~~~ sh
$ cd ~/.tlenv
$ git pull
~~~

To use a specific release of tlenv, check out the corresponding tag:

~~~ sh
$ cd ~/.tlenv
$ git fetch
$ git checkout v0.3.0
~~~

### How tlenv hooks into your shell

Skip this section unless you must know what every line in your shell
profile is doing.

`tlenv init` is the only command that crosses the line of loading
extra commands into your shell.
Here's what `tlenv init` actually does:

1. Sets up your shims path. This is the only requirement for tlenv to
   function properly. You can do this by hand by prepending
   `~/.tlenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.tlenv/completions/tlenv.bash` will set that
   up. There is also a `~/.tlenv/completions/tlenv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this automatically makes sure everything is up to
   date. You can always run `tlenv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   tlenv and plugins to change variables in your current shell, making
   commands like `tlenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `tlenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `tlenv init -` for yourself to see exactly what happens under the
hood.

### Installing TeX Live Versions

The `tlenv install` command doesn't ship with tlenv out of the box yet.

### Uninstalling TeX Live Versions

### Uninstalling tlenv

The simplicity of tlenv makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** tlenv managing your TeXlive versions, simply remove the
  `tlenv init` line from your shell startup configuration. This will
  remove tlenv shims directory from PATH, and future invocations like
  `latex` will execute the system latex version, as before tlenv.

  `tlenv` will still be accessible on the command line, but your TeX Live
  apps won't be affected by version switching.

2. To completely **uninstall** tlenv, perform step (1) and then remove
   its root directory. 

        rm -rf `tlenv root`

## Command Reference

Like `git`, the `tlenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### tlenv local

Sets a local application-specific LaTeX version by writing the version
name to a `.latex-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `TLENV_VERSION` environment variable or with the `tlenv shell`
command.

    $ tlenv local 2016

When run without a version number, `tlenv local` reports the currently
configured local version. You can also unset the local version:

    $ tlenv local --unset

tlenv stores local version specifications in a file named `.latex-version`.

### tlenv global

Sets the global version of TeX Live to be used in all shells by writing
the version name to the `~/.tlenv/version` file. This version can be
overridden by an application-specific `.latex-version` file, or by
setting the `TLENV_VERSION` environment variable.

    $ tlenv global vtex-2010

The special version name `system` tells tlenv to use the system TeX Live
(detected by searching your `$PATH`).

When run without a version number, `tlenv global` reports the
currently configured global version.

### tlenv shell

Sets a shell-specific TeX Live version by setting the `TLENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ tlenv shell devel-2015

When run without a version number, `tlenv shell` reports the current
value of `TLENV_VERSION`. You can also unset the shell version:

    $ tlenv shell --unset

Note that you'll need tlenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`TLENV_VERSION` variable yourself:

    $ export TLENV_VERSION=vtex-2010

### tlenv versions

Lists all TeX Live versions known to tlenv, and shows an asterisk next to
the currently active version.

    $ tlenv versions
      system
      2016
    * vtex-2010 (set by /Users/sam/.tlenv/version)
      vtex-2016
      devel-2016

### tlenv version

Displays the currently active TeX Live version, along with information on
how it was set.

    $ tlenv version
    1.9.3-p327 (set by /Users/sam/.tlenv/version)

### tlenv rehash

Installs shims for all TeX Live executables known to tlenv (i.e.,
`/usr/local/texlive/*/*/bin/*`). Run this command after you install a new
version of TeX Live.

    $ tlenv rehash

### tlenv which

Displays the full path to the executable that tlenv will invoke when
you run the given command.

    $ tlenv which dvips
    /usr/local/texlive/2015/bin/x86_64-linux

### tlenv whence

Lists all TeX Live versions with the given command installed.

    $ tlenv whence dviasm
    2015
    vtex-2015

## Environment variables

You can affect how tlenv operates with the following settings:

name | default | description
-----|---------|------------
`TLENV_VERSION` | | Specifies the TeX Live version to be used.<br>Also see [`tlenv shell`](#tlenv-shell)
`TLENV_ROOT` | `~/.tlenv` | Defines the directory under which TeX Live versions and shims reside.<br>Also see `tlenv root`
`TLENV_DEBUG` | | Outputs debug information.<br>Also as: `tlenv --debug <subcommand>`
`TLENV_HOOK_PATH` | [_see wiki_][hooks] | Colon-separated list of paths searched for tlenv hooks.
`TLENV_DIR` | `$PWD` | Directory to start searching for `.latex-version` files.

## Development

The tlenv source code is [hosted on
GitLab](https://gitlab.vtex.lt/deimi/tlenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://gitlab.vtex.lt/deimi/tlenv/issues).


  [ruby-build]: https://github.com/rbenv/ruby-build#readme
  [hooks]: https://github.com/rbenv/rbenv/wiki/Authoring-plugins#rbenv-hooks
