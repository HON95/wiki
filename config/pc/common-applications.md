---
title: Common Applications
toc_enable: yes
breadcrumbs:
- title: Home
  url: /
- title: Configuration Notes
  url: /config/
- title: PC
---
{% include header.md %}

## Git

### Config

```ini
[user]
	name = <full_name>
	email = <email_addr>
[commit]
	gpgsign = false
[core]
	autocrlf = input
	eol = lf
```

## SSH

### Usage

- New key (RSA): `ssh-keygen -t rsa -b 4096`

### Config

```text
# File: ~/.ssh/config

# Use special user and key
host github.com
    User git
    IdentityFile ~/.ssh/id_rsa_artorias
```

## Vim

### Config

```text
" File: ~/.vimrc

" Global: /etc/vim/vimrc

" Better YAML indentation
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
```

## VS Code

### Extensions

- HTML CSS Support (ecmel.vscode-html-css)

### Config

```javascript
// Linux file: ~/.config/Code/user/settings.json
// Windows file: %APPDATA%\Code\User\settings.json

{
"files.encoding": "utf8",
"files.eol": "\n",
// Hide open editors Explorer section
"explorer.openEditors.visible": 0,
"explorer.confirmDragAndDrop": false,
"explorer.confirmDelete": false,
// Don't jump to file in Explorer when tabbing to it
"explorer.autoReveal": false,
// Hide these in Explorer
"files.exclude": {
  "**/__pycache__/": true,
  "**/*.o": true,
  "**/*.pyc": true
},
// Don't show quick suggestion while typing
"editor.quickSuggestions": false,
"editor.autoClosingBrackets": "never",
"editor.autoClosingQuotes": "never",
"editor.autoSurround": "never",
"html.autoClosingTags": false,
}
```

{% include footer.md %}
