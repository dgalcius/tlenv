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

This will get you going with the latest version of rbenv and make it
easy to fork and contribute any changes back upstream.

1. Check out rbenv into `~/.ltenv`.

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

3. Add `rbenv init` to your shell to enable shims and autocompletion.

    ~~~ sh
    $ echo 'eval "$(ltenv init -)"' >> ~/.bash_profile
    ~~~

    _Same as in previous step, use `~/.bashrc` on Ubuntu, or `~/.zshrc` for Zsh._

4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.) Now check if rbenv was set up:

    ~~~ sh
    $ type ltenv
    #=> "rbenv is a function"
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

If you've [installed via Homebrew](#homebrew-on-mac-os-x), then upgrade
via its `brew` command:

~~~ sh
$ brew update
$ brew upgrade rbenv ruby-build
~~~

### Homebrew on Mac OS X

As an alternative to installation via GitHub checkout, you can install
rbenv and [ruby-build][] using the [Homebrew](http://brew.sh) package
manager on Mac OS X:

~~~
$ brew update
$ brew install rbenv ruby-build
~~~

Afterwards you'll still need to add `eval "$(ltenv init -)"` to your
profile as stated in the caveats. You'll only ever have to do this
once.

### How rbenv hooks into your shell

Skip this section unless you must know what every line in your shell
profile is doing.

`ltenv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from RVM, some of you might be
opposed to this idea. Here's what `ltenv init` actually does:

1. Sets up your shims path. This is the only requirement for rbenv to
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
   rbenv and plugins to change variables in your current shell, making
   commands like `rbenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `rbenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `ltenv init -` for yourself to see exactly what happens under the
hood.

### Installing Ruby Versions

The `rbenv install` command doesn't ship with rbenv out of the box, but
is provided by the [ruby-build][] project. If you installed it either
as part of GitHub checkout process outlined above or via Homebrew, you
should be able to:

~~~ sh
# list all available versions:
$ rbenv install -l

# install a Ruby version:
$ rbenv install 2.0.0-p247
~~~

Alternatively to the `install` command, you can download and compile
Ruby manually as a subdirectory of `~/.rbenv/versions/`. An entry in
that directory can also be a symlink to a Ruby version installed
elsewhere on the filesystem. rbenv doesn't care; it will simply treat
any entry in the `versions/` directory as a separate Ruby version.

### Uninstalling Ruby Versions

As time goes on, Ruby versions you install will accumulate in your
`~/.rbenv/versions` directory.

To remove old Ruby versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Ruby version with the `rbenv prefix` command, e.g. `rbenv prefix
1.8.7-p357`.

The [ruby-build][] plugin provides an `rbenv uninstall` command to
automate the removal process.

### Uninstalling rbenv

The simplicity of rbenv makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** rbenv managing your Ruby versions, simply remove the
  `rbenv init` line from your shell startup configuration. This will
  remove rbenv shims directory from PATH, and future invocations like
  `ruby` will execute the system Ruby version, as before rbenv.

  `rbenv` will still be accessible on the command line, but your Ruby
  apps won't be affected by version switching.

2. To completely **uninstall** rbenv, perform step (1) and then remove
   its root directory. This will **delete all Ruby versions** that were
   installed under `` `rbenv root`/versions/ `` directory:

        rm -rf `rbenv root`

   If you've installed rbenv using a package manager, as a final step
   perform the rbenv package removal. For instance, for Homebrew:

        brew uninstall rbenv

## Command Reference

Like `git`, the `rbenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### rbenv local

Sets a local application-specific Ruby version by writing the version
name to a `.ruby-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `RBENV_VERSION` environment variable or with the `rbenv shell`
command.

    $ rbenv local 1.9.3-p327

When run without a version number, `rbenv local` reports the currently
configured local version. You can also unset the local version:

    $ rbenv local --unset

Previous versions of rbenv stored local version specifications in a
file named `.rbenv-version`. For backwards compatibility, rbenv will
read a local version specified in an `.rbenv-version` file, but a
`.ruby-version` file in the same directory will take precedence.

### rbenv global

Sets the global version of Ruby to be used in all shells by writing
the version name to the `~/.rbenv/version` file. This version can be
overridden by an application-specific `.ruby-version` file, or by
setting the `RBENV_VERSION` environment variable.

    $ rbenv global 1.8.7-p352

The special version name `system` tells rbenv to use the system Ruby
(detected by searching your `$PATH`).

When run without a version number, `rbenv global` reports the
currently configured global version.

### rbenv shell

Sets a shell-specific Ruby version by setting the `RBENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ rbenv shell jruby-1.7.1

When run without a version number, `rbenv shell` reports the current
value of `RBENV_VERSION`. You can also unset the shell version:

    $ rbenv shell --unset

Note that you'll need rbenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`RBENV_VERSION` variable yourself:

    $ export RBENV_VERSION=jruby-1.7.1

### rbenv versions

Lists all Ruby versions known to rbenv, and shows an asterisk next to
the currently active version.

    $ rbenv versions
      1.8.7-p352
      1.9.2-p290
    * 1.9.3-p327 (set by /Users/sam/.rbenv/version)
      jruby-1.7.1
      rbx-1.2.4
      ree-1.8.7-2011.03

### rbenv version

Displays the currently active Ruby version, along with information on
how it was set.

    $ rbenv version
    1.9.3-p327 (set by /Users/sam/.rbenv/version)

### rbenv rehash

Installs shims for all Ruby executables known to rbenv (i.e.,
`~/.rbenv/versions/*/bin/*`). Run this command after you install a new
version of Ruby, or install a gem that provides commands.

    $ rbenv rehash

### rbenv which

Displays the full path to the executable that rbenv will invoke when
you run the given command.

    $ rbenv which irb
    /Users/sam/.rbenv/versions/1.9.3-p327/bin/irb

### rbenv whence

Lists all Ruby versions with the given command installed.

    $ rbenv whence rackup
    1.9.3-p327
    jruby-1.7.1
    ree-1.8.7-2011.03

## Environment variables

You can affect how rbenv operates with the following settings:

name | default | description
-----|---------|------------
`RBENV_VERSION` | | Specifies the Ruby version to be used.<br>Also see [`rbenv shell`](#rbenv-shell)
`RBENV_ROOT` | `~/.rbenv` | Defines the directory under which Ruby versions and shims reside.<br>Also see `rbenv root`
`RBENV_DEBUG` | | Outputs debug information.<br>Also as: `rbenv --debug <subcommand>`
`RBENV_HOOK_PATH` | [_see wiki_][hooks] | Colon-separated list of paths searched for rbenv hooks.
`RBENV_DIR` | `$PWD` | Directory to start searching for `.ruby-version` files.

## Development

The rbenv source code is [hosted on
GitHub](https://github.com/rbenv/rbenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/rbenv/rbenv/issues).


  [ruby-build]: https://github.com/rbenv/ruby-build#readme
  [hooks]: https://github.com/rbenv/rbenv/wiki/Authoring-plugins#rbenv-hooks
