source ~/.local/share/omarchy/default/bash/rc
alias code=vscodium-electron

export PATH=$PATH:/home/jaxon/.spicetify

eval "$(starship init bash)"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
