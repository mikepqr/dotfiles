#!/bin/bash

configured=$(defaults read com.googlecode.iterm2.plist LoadPrefsFromCustomFolder)

if [[ $configured -eq 1 ]] ; then 
    echo "iTerm already configured."
    exit 0
fi

prefsfolder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$prefsfolder"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
echo "iTerm configured to use $prefsfolder."
echo "Install Source Code Pro, e.g. brew cask install font-source-code-pro"
