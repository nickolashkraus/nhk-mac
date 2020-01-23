#!/usr/bin/env bash
#
# Functions
#
# This file is sourced by `run.sh`

function echo_c {
  echo -en $2
  echo "${1}"
  echo -en $RESET
}

function usage {
  echo_c
  echo_c "Usage: nhk-mac" $WHITE
  echo_c
}

function set_hostname {
  echo_c "Setting hostname..." $WHITE
  sudo scutil --set HostName "${1}"
}

function set_wallpaper {
  echo_c "Setting wallpaper..." $WHITE
  db='/Users/n/Library/Application Support/Dock/desktoppicture.db'
  val_0=0
  val_1=1
  val_2=0.0841198042035103
  val_3=0.084135964512825
  val_4=0.0841171219944954
  val_5="'$(sudo find /System/Library -type d -name "*Solid Colors" 2>/dev/null)'"
  val_6="'$(sudo find /System/Library -type f -name "*Transparent.tiff" 2>/dev/null)'"
  sqlite3 "$db" "DELETE FROM data;"
  sqlite3 "$db" "INSERT INTO data(value) VALUES ($val_5), ($val_0), ($val_1), ($val_6), ($val_2), ($val_3), ($val_4);" && \
  killall Dock
}

function configure_dock {
  echo_c "Configuring Dock..." $WHITE
  defaults write com.apple.Dock autohide -bool true
  defaults write com.apple.dock autohide-delay -int 0
  defaults write com.apple.dock autohide-time-modifier -int 0
  defaults write com.apple.dock persistent-apps -array
  defaults write com.apple.dock persistent-others -array
  defaults write com.apple.dock recent-apps -array
  defaults write com.apple.dock show-recent -bool FALSE
  defaults write com.apple.dock tilesize -int 32
  defaults write com.apple.dock 'orientation' -string 'left'
  killall Dock
}

function install_xcode {
  if ! [ -x "$(command -v git)" ]; then
    echo_c "Installing Xcode Developer Tools..." $WHITE
    xcode-select --install
    echo_c "Press ENTER to continue."
    read -n 1
  fi
}

function install_homebrew {
  if ! [ -x "$(command -v brew)" ]; then
    echo_c "Installing Homebrew..." $WHITE
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo_c "Updating Homebrew..." $WHITE
  brew update
  fi
}

function install_homebrew_bundle {
  echo_c "Installing Homebrew Bundle..." $WHITE
  brew bundle
}

function install_iterm2 {
  if [ ! -d /Applications/iTerm.app ]; then
    echo_c "Installing iTerm2..." $WHITE
    ITERM2_VERSION=$(echo $ITERM2_VERSION | sed 's/\./_/g')
    curl -LOk https://iterm2.com/downloads/stable/iTerm2-$ITERM2_VERSION.zip
    unzip -q iTerm2-$ITERM2_VERSION.zip
    mv iTerm.app /Applications
    rm iTerm2-$ITERM2_VERSION.zip
  fi
}

function install_spectacle {
  if [ ! -d /Applications/Spectacle.app ]; then
    echo_c "Installing Spectacle..." $WHITE
    curl -LOk https://s3.amazonaws.com/spectacle/downloads/Spectacle+$SPECTACLE_VERSION.zip
    unzip -q Spectacle+$SPECTACLE_VERSION.zip
    mv Spectacle.app /Applications
    rm Spectacle+$SPECTACLE_VERSION.zip
  fi
}

function install_zsh {
  if [ ! -d $HOME/.oh-my-zsh ]; then
    echo_c "Installing Zsh..." $WHITE
    git clone https://github.com/NickolasHKraus/oh-my-zsh $HOME/.oh-my-zsh
    cd $HOME/.oh-my-zsh
    git remote add upstream git@github.com:robbyrussell/oh-my-zsh.git
    cd $HOME
  fi
}

function install_vundle {
  if [ ! -d $HOME/.vim/bundle/Vundle.vim ]; then
    echo_c "Installing Vundle..." $WHITE
    git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
  fi
}

function install_powerline_fonts {
  echo_c "Installing Powerline fonts..." $WHITE
  git clone https://github.com/powerline/fonts.git --depth=1
  cd fonts
  ./install.sh
  cd ..
  rm -rf fonts
}

function create_ssh_keys {
  echo_c "Creating SSH keys..." $WHITE
  mkdir -p $HOME/.ssh
  if [ ! -a $HOME/.ssh/id_rsa ]; then
    ssh-keygen -b 2048 -t rsa -f $HOME/.ssh/id_rsa -P ""
    chmod 400 $HOME/.ssh/id_rsa
    echo_c "You will need to add the public key to your GitHub account." $YELLOW
    cat $HOME/.ssh/id_rsa.pub
    echo_c "Press ENTER to continue."
    read -n 1
  else
    echo_c "SSH keys already exist." $GREEN
  fi
}

function setup_workspace {
  if [ ! -d $HOME/Workspace ]; then
    echo_c "Creating 'Workspace' directory..." $WHITE
    mkdir -p $HOME/Workspace
  else
    echo_c "${HOME}/Workspace already exists." $GREEN
  fi
  echo_c "Cloning repositories..." $WHITE
  cd $HOME/Workspace
  if ! [ -x "$(command -v jq)" ]; then
    brew install jq
  fi
  (ssh-agent -s && ssh-add ~/.ssh/id_rsa) >/dev/null 2>&1
  ssh git@github.com >/dev/null 2>&1
  if [ $? -eq 255 ]; then
    echo_c "Permission denied (publickey)." $RED
    exit 1
  fi
  SSH_URLS=($(curl -s https://api.github.com/users/NickolasHKraus/repos | jq '.[].ssh_url' | tr -d \"))
  for ssh_url in "${SSH_URLS[@]}"; do
    echo Cloning "${ssh_url}"..
    output=$(git clone "${ssh_url}" 2>&1)
    if [ $(echo $output | grep -i "already exists" -c) -ne 0 ]; then
      echo_c "Repository already exists." $GREEN
    fi
  done
}

function install_homebrew_packages {
  echo_c "Installing Homebrew packages..." $WHITE
  brew bundle --file=$HOME/Workspace/dotfiles/Brewfile
  echo_c "Upgrading Homebrew packages..." $WHITE
  brew upgrade
}

function configure_python {
  echo_c "Installing virtualenv and virtualenvwrapper..." $WHITE
  pip install virtualenv virtualenvwrapper
  echo_c "Configuring virtualenv and virtualenvwrapper..." $WHITE
  export WORKON_HOME=$HOME/.virtualenvs
  export VIRTUALENVWRAPPER_PYTHON=$HOME/.pyenv/shims/python
  export VIRTUALENVWRAPPER_VIRTUALENV=$HOME/.pyenv/shims/virtualenv
  source /usr/local/bin/virtualenvwrapper.sh
  echo_c "Installing Python ${PYTHON2_VERSION} via pyenv..." $WHITE
  pyenv install $PYTHON2_VERSION
  echo_c "Installing Python ${PYTHON3_VERSION} via pyenv..." $WHITE
  pyenv install $PYTHON3_VERSION
  echo_c "Creating virtual environments..." $WHITE
  eval "$(pyenv init -)"
  pyenv shell $PYTHON2_VERSION
  pyenv virtualenvwrapper
  mkvirtualenv dev2
  deactivate
  pyenv shell $PYTHON3_VERSION
  pyenv virtualenvwrapper
  mkvirtualenv dev3
}

function install_python_packages {
  workon dev3
  pip install -r $HOME/Workspace/dotfiles/requirements.txt
}

function install_bash_scripts {
  source $HOME/Workspace/bash-scripts/install.sh
}

function install_dotfile {
  source $HOME/Workspace/dotfiles/install.sh
}

function install_vim_scripts {
  source $HOME/Workspace/vim-scripts/install.sh
}

function install_vim_plugins {
  vim +PluginInstall +qall
}
