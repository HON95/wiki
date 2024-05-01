---
title: Git
breadcrumbs:
- title: Software Engineering
---
{% include header.md %}

## General

- Signing commits and tags:
    - Should be done to provide authenticity and integrity to the commit, but also signal that the commits before it are also correct.
    - If committing a lot and in potentially untrusted codebases, maybe avoid signing commits by default to avoid vouching for the stuff that came before.
    - There are also cases when committing from untrusted environments where your private key is not available, such as on dev/test machines, where you may import the work to the "trusted" machine afterwards and continue working on it.
    - Should be done when committing releases and things where every commit up to and including that one should be trusted.
    - Opinionated advice: Avoid using auto-signing, use signing more selectively instead, as a sign of approval.
    - Signing can be done using PGP, SSH or S/MIME, but you should generally prefer PGP. Use e.g. SSH signing by setting `gpg.format = ssh`.
- Commit message (opinionated):
    - The commit messages should be structured such that it's easy to see what the commit does and so you can easily search through a long log of commits.
    - For single sentences (i.e. just the subject), use the inline mode (`-m "<message>"`).
    - To add a body or footer, leave out the message option to open an editor when running the command. Add the concise, one-line subject, then the body and lastly the footer, with a single, empty line separating each of the three sections.
    - The footer may e.g. be used to store breaking changes and closed issues. See Conventional Commits for info about formatting the breaking changes.
    - Use a single sentence in imperative, present tense with no capitalized first letter and no trailing period, such as: "fix login bug causing bluescreen". It should complete the sentence: "If applied, this commit will \<message\>".
    - Reverting commits should use subject "revert: \<original message\>" and should contain "This reverts commit \<hash\>." in the header. If using Conventional Commits, consider using a "revert" type instead.
    - No lines in the message should be longer than 100 characters.
    - Footers should use the git trailer convention, where each line should consist of a word token, ":\<space\>" or "\<space\> #" and a string value. The word token must use "-" in place of space, but an exception has been made for "BREAKING CHANGE". The string value may use spaces and newlines, until a new token/separator pair is encountered.
    - Consider using [Conventional Commits](https://www.conventionalcommits.org/).
        - Format: `<type>[scope]: <description>`
        - Example types (only "feat" and "fix" are from the specification):
            - feat: A new feature (strict).
            - fix: A bug fix (strict).
            - docs: Documentation changes only.
            - style: Formatting only, nothing that changes the meaning of the code (not style as in CSS).
            - refactor: Code changes that neither fixes bugs nor adds features.
            - perf: Code changes that improves performance.
            - test: Changes to code tests.
            - chore: Changes to the build system, auxillary tools and similar.
            - revert: A reverted commit, referencing the original commit in the footer.
        - A commit should only conform to a single type. Consider breaking up the commit into multiple if it doesn't.
        - The scope strongly depends on the modules of the project. If the commit does not clearly involve a single scope, then avoid specifying the scope.
        - Breaking changes:
            - Must add a "!" after the type/scope in the subject and optionally a "BREAKING CHANGE: \<description\>" in the footer if not specified clearly in the subject description.
            - "BREAKING CHANGE:" must always be upper-case and may use a hyphen instead of the space.
        - Relating to Semantic Versioning (SemVer), "fix" should translate to patch releases, "feat" should translate to minor releases and "BREAKING CHANGE" should translate to major releases.
        - Examples subjects:
            - "feat(api)!: send an email to the customer when a product is shipped"
            - "docs: correct spelling of CHANGELOG"
            - "feat(lang): add Norwegian language"
    - For squash based workflows, lead maintainers can clean up the commit messages when they're merged, so that the "casual contributer" doesn't need to conform exactly to the commit message rules.
- Big repo enhancements:
    - Windows has contributed a lot here since they moved Windows to git. They have approximately 3.5M files in a 300GB repo, used by 4000 engineers (2024). Most of the features were added through the Scalar project, but it's now mostly available in the Git core.

## Commands

- General:
    - Check the status: `git status`
    - Update local config and add cron job to update/cleanup repo stuff in the background: `git maintenance start`
    - Show reflog: `git reflog`
- Cloning:
    - Clone a repo using SSH (GitHub HON95/wiki example): `git clone git@github.com:HON95/wiki.git [local-dir]`
    - Partial clone without blobs (for big repos, will fetch them on demand): `git clone --filter=blob:none <...>`
    - Partial clone without trees (for big repos, rarely used, maybe for CI): `git clone --filter=tree:0 <...>`
    - Clone with scalar:
        - The `scalar` command now comes shipped with Git, after being upstreamed by Microsoft.
        - Cloning with scalar will set up the defaults for better scaling, with features like prefetching, commit-graph, filesystem monitor, partial cloning and sparse checkout.
        - Usage: `scalar clone <remote-repo>`
- Staging files:
    - Stage all changes: `git add -A`
    - Stage specific files: `git add <file>`
    - Unstage changes: `git reset [file]`
    - Unstage all files (without changing them): `git reset`
    - Discard changes for file: `git checkout [target] -- <file>` (target defaults to HEAD)
    - Discard changes for file (new command): `git restore [--source <target>] <file>` (target defaults to HEAD)
    - Discard all changes: `git reset --hard HEAD`
    - gitignore:
        - Add files to ignore in `.gitignore` in the same or a parent folder.
        - A leading `/` means to only match in the same folder as the gitignore file (the gitignore root).
        - A trailing `/` means to only match directories.
        - A `*` means to use globbing to match files, e.g. `*.log` to match all log files.
        - A leading `**/` means to match in the current directory or in subdirectories.
- Committing:
    - Typical command (with inline message): `git commit -m "<message>"`
    - Commit message:
        - See genearal note.
        - Should use Conventional Commits.
        - Use `-m "<message>"` to specify only the subject or leave it out to open an editor where you can specify the body and footer too.
    - Signing:
        - See note above about when to sign commits.
        - Configure a signing key in the config first.
        - To sign a commit, use `git commit -S ...`.
    - Fixup and auto-squash:
        - Allows you to add a special type of commit that updates a previous commit, without rebase nightmares.
        - If you only want to update the directly previous commit, just use `git commit --amend` instead.
        - Commit the updates to a previous commit, referencing the previous commit: `git commit --fixup=<prev-commit-hash>`
        - Auto-squash the temporary fixup commit(s) into the original commit(s): `git rebase --autosquash <branch>`
    - Show details about the last commit: `git cat-file -p HEAD`
    - Show details about a single file in the last commit: `git cat-file -p HEAD:"filename.txt"` (example)
- Pulling/pushing:
    - Force push, e.g. when changing history (dangerous): `git push --force`
    - Force push, but only if the remote hasn't changed (less dangerous): `git push --force-with-lease`
- Branching:
    - Checkout a branch: `git checkout [-b] <branch>` (`-b` if new branch)
    - Checkout a branch (new command): `git switch [-c] <branch>` (`-c` if new branch)
    - Edit the description of a branch: `git branch --edit-description [branchname]` (defaults to active branch)
    - Sparse checkout (limit locally present dirs, assume others are unchanged): `git sparse-checkout set <dir ...>`
- Stashing:
    - **TODO**
- Diffing:
    - Show diff between unstaged changes and staged/HEAD: `git diff [file]`
    - Show diff for a commit: `git diff <commit-hash>~ <commit-hash>`
    - Show diffs within a line as diffs within a line: `git diff --word-diff`
- Log searching:
    - Show log for repo: `git log`
    - Show log for file: `git log <file>`
    - Show log as patch text: `git log -p`
    - Search log for when something changed: `git log -G <regex> -p`
    - Show log with graph (show branching and merging): `git log --graph --oneline`
- Blaming:
    - Blame for a section of lines: `git blame -L <start-line>,<stop-line> <file>`
    - Check history for a section of lines: `git log -L <start-line>,<stop-line>:<file>` (note the `:`)
    - Check for a function (using heuristics to delimit it): `git blame -L :<funcname-regex> <file>`
    - Ignore whitespace: `git blame -w <...>`
    - Detect movement (don't get ownership if you move it):
        - Detect movement in the same commit: `git blame -C <...>`
        - ... or in the commit that created the file: `git blame -C -C <...>`
        - ... or in any commit at all (slow): `git blame -C -C -C <...>`
- Attributes:
    - The attribute config is stored in `.gitattributes`.
    - Used by e.g. Git LFS.
    - Show EXIF diff for binary picture diffs (repo-level):
        1. Install `exiftool`.
        1. Enable EXIF diffing: `echo '*.png diff=exif' >> .gitattributes`
        1. Set EXIF tool: `git config diff.exif.textconv exiftool`
- Submodules:
    - **TODO**
- Hooks:
    - Most important hooks:
        - Commit stuff: `pre-commit`, `prepare-commit-msg`, `commit-msg`, `post-commit`
        - Rewriting stuff: `pre-rebase`, `post-rewrite`
        - Merging stuff: `post-merge`, `pre-merge-commit`
        - Switching/pushing stuff: `post-checkout`, `reference-transaction`, `pre-push`
        - Server stuff: `pre-receive`, `update`, `proc-receive`, `post-receive`, `post-update`, `push-to-checkout`
    - The [pre-commit app](https://pre-commit.com/) may be used to manage pre-commit hooks, like checks to run before the commit is allowed to go through. [Husky](https://typicode.github.io/husky/) is another alternative.
- Git Large File Storage (LFS):
    - To keep large files in the repo by pushing them to an LFS server but with references in the repo.
    - Uses Git's "smudge and clean" to pull/push files seemingly like normal Git files.
    - Git LFS might need to be installed first:
        - Windows: [Download from git-lfs.com.](https://git-lfs.com/)
    - Enable LFS for repo (setup hooks): `git lfs install`
    - Track certain files (setup attributes): `git lfs track "*.mov"`
    - Show info about file in LFS: `git cat-file -p HEAD:"movie.mov"` (example)
- Config:
    - Se section below.
    - Update global config: `git config --global <key> <value>`

## Config

- Conditional configs:
    - Use `[includeIf <condition>]` sections with a `path = <config-path>` statement to conditionally include the config at the target path.
    - Example: Use `[includeIf "gitdir:~/projects/work/"]` plus `path = ~/projects/work/.gitconfig` to use the work git config for work projects, e.g. to change the email address or SSH keys.
- Project config:
    - Enable filesystem monitor for git status (for big repos):
        - `git config core.untrackedcache true`
        - `git config core.fsmonitor true`

### Example Global Config

File: `~/.gitconfig`

Note: Avoid quotation marks around values.

```ini
# https://wiki.hon.one/swe/git/
# https://github.com/HON95/configs/blob/master/git/config

[user]
        name = <full_name>
        email = <email_addr>
[core]
        # Convert CRLF to LF
        autocrlf = input
[fetch]
        # Write commit-graph cache
        writeCommitGraph = true
[commit]
        # Don't auto-sign, use it selectively instead
        gpgsign = false
[rerere]
        # Reuse recorded resolution (ReReRe)
        # Remember and reapply resolutions to previous merge conflicts and stuff
        enabled = true
[column]
        # Wider "git branch" output
        ui = auto
[branch]
        # Sorted "git branch" output
        sort = -committerdate
[rebase]
        # Automaticall update refs by sefault after rebase
        updateRefs = true
```

(Keep up to date with [HON95/configs](https://github.com/HON95/configs/blob/master/git/config).)

{% include footer.md %}
