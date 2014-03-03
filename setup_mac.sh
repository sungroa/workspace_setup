/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> /Users/sungroa/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/sungroa/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

brew update
brew install tmux vim fonttool  withgraphite/tap/graphite
