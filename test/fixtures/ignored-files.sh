#!/usr/bin/env bash

# shellcheck disable=2164
fixture_ignored_files() {
  local git_username="Homeshick user"
  local git_useremail="homeshick@example.com"
  local castle="$REPO_FIXTURES/ignored-files"
  git init "$castle"
  cd "$castle"
  git config user.name "$git_username"
  git config user.email "$git_useremail"

  mkdir -p home/.config
  echo "keep me" > home/.bashrc
  echo "global ignore" > home/.globalignored
  echo "host ignore" > home/.hostignored
  echo "other host" > home/.otherhost
  echo "glob host" > home/.globhost
  echo "config" > home/.config/app.conf

  cat > .homesickignore <<EOF
# Global ignore (before any section)
.globalignored

[$(hostname)]
.hostignored

[other-host]
.otherhost

[glob-*]
.globhost
EOF

  git add -A
  git commit -m 'Castle with .homesickignore'
}

fixture_ignored_files > /dev/null
