---
title: Linux
breadcrumbs:
- title: Personal Devieces
---
{% include header.md %}

Common Linux stuff.

# System Cleanup

- Show dir file sizes: `sudo du -sh _DIR_/{.,}* 2>/dev/null | sort -hr | head -n10`
- Show biggest dirs/files (GUI): `baobab`
- Clean trash: `sudo rm -rf ~/.local/share/Trash/*`
- Clean Docker: `sudo docker system prune -af`
- Clean Singularity: `sudo singularity cache clean`
- Clean yay/pacman (Arch): `yay -Scc` (or `sudo pacman -Scc`)

{% include footer.md %}
