#!/bin/sh

export HOMEBREW_BREW_GIT_REMOTE="..."  # put your Git mirror of Homebrew/brew here
export HOMEBREW_CORE_GIT_REMOTE="..."  # put your Git mirror of Homebrew/homebrew-core here

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Install software from config.ini
echo "Reading software list from config.ini..."
while IFS= read -r line; do
    if [[ $line == \#* ]]; then
        continue
    fi
    IFS='=' read -ra item <<< "$line"
    if [[ ${item[1]} == "true" ]]; then
        brew_install "${item[0]}"
    fi
done < <(curl -s https://raw.githubusercontent.com/sathaluri/powershell/main/config.ini)

# Function to install software using Homebrew
brew_install() {
    echo "\n Installing $1"
    if brew list $1 &> /dev/null; then
        echo "${1} is already installed."
    else 
        brew tap aws/tap
        brew install $1 && echo "$1 is installed."
    fi
}

# Install VS Code extensions
if [[ $(brew list --cask | grep visual-studio-code) && $(brew list --cask | grep aws-toolkit-vscode) && $(code --list-extensions | grep ms-python.python) && $(code --list-extensions | grep ms-vscode.PowerShell) ]]; then
    echo "VS Code extensions are already installed."
else
    echo "Installing VS Code extensions..."
    code --install-extension ms-python.python
    code --install-extension amazonwebservices.aws-toolkit-vscode
    code --install-extension ms-vscode.PowerShell
fi

# check if Python installation is required
if grep -q "^python=true$" config.ini; then
    # check if Python 3.9 is installed
    if ! python3.9 --version >/dev/null 2>&1; then
        # install Python 3.9 via Homebrew
        echo "Python 3.9 is not installed. Installing Python 3.9 using Homebrew package manager."
        brew install python@3.9
    else
        echo "Python 3.9 is already installed."
    fi
    
    # set Python 3.9 as global
    echo "Setting Python 3.9 as global..."
    pyenv global 3.9.10

    # check if pip3 is recognized
    if ! command -v pip3 &> /dev/null; then
        echo "pip3 is not recognized. Please close and reopen the terminal, then run this script again to install Python packages."
    else
        # install Python packages
        echo "Installing Python packages..."
        pip3 install PyMySQL
        pip3 install django
        pip3 install djangorestframework
        pip3 install pytz
        pip3 install psycopg2-binary
    fi
fi
fi
