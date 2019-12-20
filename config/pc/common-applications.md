---
title: Common Applications
toc_enable: yes
breadcrumbs:
- title: Configuration
- title: PC
---
{% include header.md %}

## Git

### Config
Location: `~/.gitconfig`

Example: [.gitconfig]({{ site.github.repository_url }}/blob/master/config/pc/files/gitconfig).

## SSH

### Usage

- New key (RSA): `ssh-keygen -t rsa -b 4096`

### Config
Location: `~/.ssh/config`

Example: [config]({{ site.github.repository_url }}/blob/master/config/pc/files/ssh_config).

## Vim

### Config
Location:
- Global: `/etc/vim/vimrc`
- User: `~/.vimrc`

Example: [vimrc]({{ site.github.repository_url }}/blob/master/config/pc/files/vimrc).

## VS Code

### Extensions

- HTML CSS Support (ecmel.vscode-html-css)

### Config
Location:
- Linux: `~/.config/Code/user/settings.json`
- Windows: `%APPDATA%\Code\User\settings.json`

Example: [settings.json]({{ site.github.repository_url }}/blob/master/config/pc/files/vscode_settings.json).

{% include footer.md %}
