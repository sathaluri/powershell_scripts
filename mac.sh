#!/bin/sh

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Fetch the list of software to install from JSON file
configUrl="https://raw.githubusercontent.com/sathaluri/powershell_scripts/main/config.json"
softwareList=$(curl -s $configUrl)

# Function to install software using Homebrew
brew_install() {
    local packageName=$1
    echo "Installing $packageName"
    
    if brew list --formula --versions $packageName >/dev/null; then
        echo "$packageName is already installed."
    else 
        brew install $packageName && echo "$packageName is installed."
    fi
}

# Install software from JSON file
echo "Reading software list from JSON file..."
packageCount=$(echo $softwareList | jq '. | length')

for ((i=0; i<$packageCount; i++))
do
    package=$(echo $softwareList | jq -r .[$i].package)
    install=$(echo $softwareList | jq -r .[$i].install)
    
    if [[ $install == "true" ]]; then
        brew_install "$package"
    fi
done
