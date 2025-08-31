# ~/.bash_profile
# Source ~/.profile for environment variables
if [ -f "$HOME/.profile" ]; then
  . "$HOME/.profile"
fi

# Source ~/.bashrc for interactive features
if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
