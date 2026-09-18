# shellcheck shell=bash
# Login-shell setup shared by .zprofile and .bash_profile.

# The 'python' module is optional, so pyenv is not always installed. WSL also
# inherits the Windows PATH, which can put a pyenv-win shim on it; that shim
# only knows how to call cmd.exe, so ignore any pyenv under /mnt.
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d $PYENV_ROOT/bin ]]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
fi
if pyenv_bin=$(command -v pyenv) && [[ $pyenv_bin != /mnt/* ]]; then
    eval "$(pyenv init - "${ZSH_VERSION:+zsh}${BASH_VERSION:+bash}")"
fi
unset pyenv_bin
