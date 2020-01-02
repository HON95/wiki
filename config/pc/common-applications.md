---
title: Common Applications
toc_enable: yes
breadcrumbs:
- title: Configuration
- title: PC
---
{% include header.md %}

## Firefox

### Config

- (Linux) Disable middle mouse paste:
  - Go to `about:config`.
  - Set `middlemouse.paste` to false.

## Git

### Config
Location: `~/.gitconfig`

[Example](https://github.com/HON95/configs/blob/master/pc/common/gitconfig).

## SSH

### Usage

- New key (RSA): `ssh-keygen -t rsa -b 4096`

### Config
Location: `~/.ssh/config`

[Example](https://github.com/HON95/configs/blob/master/pc/common/ssh_config).

## Vim

### Config
Location:
- Global: `/etc/vim/vimrc`
- User: `~/.vimrc`

[Example](https://github.com/HON95/configs/blob/master/pc/common/vimrc).

## VS Code

### Extensions

- HTML CSS Support (ecmel.vscode-html-css)

### Config
Location:
- Linux: `~/.config/Code/User/settings.json`
- Windows: `%APPDATA%\Code\User\settings.json`

[Example](https://github.com/HON95/configs/blob/master/pc/common/vscode_settings.json).

{% include footer.md %}
