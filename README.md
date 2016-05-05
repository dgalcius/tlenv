# TeX Live version selection with ltenv.

Use ltenv to set a TeX Live version for your application and guarantee
that your development environment matches production.

**Powerful in development.** Specify your TeX Live version once,
  in a single file. Just Works™ from the command line.
  Override the TeX Live version anytime: just set an environment variable.

**Rock-solid in production.** 
  The TeX Live version dependency lives in one place—your app—so upgrades
  and rollbacks are  atomic, even when you switch versions.

**One thing well.** ltenv is concerned solely with switching TeX Live
  versions. It's simple and predictable. (Can be used plugin ecosystem).
  Specify TeX Live version as global or as local or as per folder basis.

## Table of Contents

* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the TeX Live Version](#choosing-the-texlive-version)
  * [Locating the TeX live Installation](#locating-the-texlive-installation)
* [Installation](#installation)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
  * [Homebrew on Mac OS X](#homebrew-on-mac-os-x)
  * [How tlenv hooks into your shell](#how-rbenv-hooks-into-your-shell)
  * [Installing TeX Live Versions](#installing-ruby-versions)
  * [Uninstalling TeX Live Versions](#uninstalling-ruby-versions)
  * [Uninstalling ltenv](#uninstalling-rbenv)
* [Command Reference](#command-reference)
  * [ltenv local](#rbenv-local)
  * [ltenv global](#rbenv-global)
  * [ltenv shell](#rbenv-shell)
  * [ltenv versions](#rbenv-versions)
  * [ltenv version](#rbenv-version)
  * [ltenv rehash](#rbenv-rehash)
  * [ltenv which](#rbenv-which)
  * [ltenv whence](#rbenv-whence)
* [Environment variables](#environment-variables)
* [Development](#development)

## How It Works

At a high level, ltenv intercepts TeX Live commands using shim
executables injected into your `PATH`, determines which TeX Live version
has been specified by your application, and passes your commands along
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

ltenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    ~/.ltenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, ltenv maintains shims in that
directory to match every LaTeX command across every installed version
of TeX Live — `latex`, `dvips`, `maketexlsr`, `purifyeps`, `xdvi`, and so on.

Shims are lightweight executables that simply pass your command along
to ltenv. So with ltenv installed, when you run, say, `latex`, your
operating system will do the following:

* Search your `PATH` for an executable file named `latex`
* Find the ltenv shim named `latex` at the beginning of your `PATH`
* Run the shim named `latex`, which in turn passes the command along to
  ltenv

### Choosing the TeX Live version

When you execute a shim, ltenv determines which TeX Live version to use by
reading it from the following sources, in this order:

1. The `LTENV_VERSION` environment variable, if specified. You can use
   the [`ltenv shell`](#ltenv-shell) command to set this environment
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
   file is not present, ltenv assumes you want to use the "system"
   TeX Live — i.e. whatever version would be run if ltenv weren't in your
   path.

### Locating the TeX Live Installation

Once ltenv has determined which version of TeX Live your application has
specified, it passes the command along to the corresponding TeX Live
installation.

## Installation

If you're on Mac OS X, consider
[installing with Homebrew](#homebrew-on-mac-os-x).

### Basic GitHub Checkout

This will get you going with the latest version of ltenv and make it
easy to fork and contribute any changes back upstream.

1. Check out ltenv into `~/.ltenv`.

    ~~~ sh
    $ git clone https://gitlab.vtex.lt/deimi/ltenv ~/.ltenv
    ~~~

2. Add `~/.ltenv/bin` to your `$PATH` for access to the `ltenv`
   command-line utility.

    ~~~ sh
    $ echo 'export PATH="$HOME/.ltenv/bin:$PATH"' >> ~/.bash_profile
    ~~~

    **Ubuntu Desktop note**: Modify your `~/.bashrc` instead of `~/.bash_profile`.

    **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.

3. Add `ltenv init` to your shell to enable shims and autocompletion.

    ~~~ sh
    $ echo 'eval "$(ltenv init -)"' >> ~/.bash_profile
    ~~~

    _Same as in previous step, use `~/.bashrc` on Ubuntu, or `~/.zshrc` for Zsh._

4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.) Now check if ltenv was set up:

    ~~~ sh
    $ type ltenv
    #=> "ltenv is a function"
    ~~~

#### Upgrading

If you've installed ltenv manually using git, you can upgrade your
installation to the cutting-edge version at any time.

~~~ sh
$ cd ~/.ltenv
$ git pull
~~~

To use a specific release of ltenv, check out the corresponding tag:

~~~ sh
$ cd ~/.ltenv
$ git fetch
$ git checkout v0.3.0
~~~

### How ltenv hooks into your shell

Skip this section unless you must know what every line in your shell
profile is doing.

`ltenv init` is the only command that crosses the line of loading
extra commands into your shell.
Here's what `ltenv init` actually does:

1. Sets up your shims path. This is the only requirement for ltenv to
   function properly. You can do this by hand by prepending
   `~/.ltenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.ltenv/completions/ltenv.bash` will set that
   up. There is also a `~/.ltenv/completions/ltenv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this automatically makes sure everything is up to
   date. You can always run `ltenv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   ltenv and plugins to change variables in your current shell, making
   commands like `ltenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `ltenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `ltenv init -` for yourself to see exactly what happens under the
hood.

### Installing TeXLive Versions

The `ltenv install` command doesn't ship with ltenv out of the box yet.

### Uninstalling TeXLive Versions

### Uninstalling ltenv

The simplicity of ltenv makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** ltenv managing your TeXlive versions, simply remove the
  `ltenv init` line from your shell startup configuration. This will
  remove ltenv shims directory from PATH, and future invocations like
  `latex` will execute the system latex version, as before ltenv.

  `ltenv` will still be accessible on the command line, but your TeXLive
  apps won't be affected by version switching.

2. To completely **uninstall** ltenv, perform step (1) and then remove
   its root directory. 

        rm -rf `ltenv root`

## Command Reference

Like `git`, the `ktenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### ltenv local

Sets a local application-specific LaTeX version by writing the version
name to a `.latex-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `LTENV_VERSION` environment variable or with the `ltenv shell`
command.

    $ ltenv local 2016

When run without a version number, `ltenv local` reports the currently
configured local version. You can also unset the local version:

    $ ltenv local --unset

ltenv stores local version specifications in a file named `.latex-version`.

### ltenv global

Sets the global version of TeXLive to be used in all shells by writing
the version name to the `~/.ltenv/version` file. This version can be
overridden by an application-specific `.latex-version` file, or by
setting the `LTENV_VERSION` environment variable.

    $ ltenv global vtex-2010

The special version name `system` tells ltenv to use the system TeXLive
(detected by searching your `$PATH`).

When run without a version number, `ltenv global` reports the
currently configured global version.

### ltenv shell

Sets a shell-specific TeXLive version by setting the `LTENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ ltenv shell devel-2015

When run without a version number, `ltenv shell` reports the current
value of `LTENV_VERSION`. You can also unset the shell version:

    $ ltenv shell --unset

Note that you'll need ltenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`LTENV_VERSION` variable yourself:

    $ export LTENV_VERSION=vtex-2010

### ltenv versions

Lists all TeXLive versions known to ltenv, and shows an asterisk next to
the currently active version.

    $ ltenv versions
      system
      2016
    * vtex-2010 (set by /Users/sam/.ltenv/version)
      vtex-2016
      devel-2016

### ltenv version

Displays the currently active TeXLive version, along with information on
how it was set.

    $ ltenv version
    1.9.3-p327 (set by /Users/sam/.ltenv/version)

### ltenv rehash

Installs shims for all TeXLive executables known to ltenv (i.e.,
`/usr/local/texlive/*/*/bin/*`). Run this command after you install a new
version of TeXLive.

    $ ltenv rehash

### ltenv which

Displays the full path to the executable that ltenv will invoke when
you run the given command.

    $ ltenv which dvips
    /usr/local/texlive/2015/bin/x86_64-linux

### ltenv whence

Lists all TeXLive versions with the given command installed.

    $ ltenv whence dviasm
    2015
    vtex-2015

## Environment variables

You can affect how ltenv operates with the following settings:

name | default | description
-----|---------|------------
`LTENV_VERSION` | | Specifies the TeXLive version to be used.<br>Also see [`ltenv shell`](#ltenv-shell)
`LTENV_ROOT` | `~/.ltenv` | Defines the directory under which TeXLive versions and shims reside.<br>Also see `ltenv root`
`LTENV_DEBUG` | | Outputs debug information.<br>Also as: `ltenv --debug <subcommand>`
`LTENV_HOOK_PATH` | [_see wiki_][hooks] | Colon-separated list of paths searched for ltenv hooks.
`LTENV_DIR` | `$PWD` | Directory to start searching for `.latex-version` files.

## Development

The ltenv source code is [hosted on
GitLab](https://gitlab.vtex.lt/deimi/ltenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://gitlab.vtex.lt/deimi/ltenv/issues).


  [ruby-build]: https://github.com/rbenv/ruby-build#readme
  [hooks]: https://github.com/rbenv/rbenv/wiki/Authoring-plugins#rbenv-hooks
