#!/usr/bin/env bats

load ../helper.sh

setup() {
  create_test_dir
  # shellcheck source=../../homeshick.sh
  source "$HOMESHICK_DIR/homeshick.sh"
}

teardown() {
  delete_test_dir
}

@test 'globally ignored files are not linked' {
  castle 'ignored-files'
  homeshick --batch link ignored-files
  [ ! -L "$HOME/.globalignored" ]
}

@test 'host-specific ignored files are not linked' {
  castle 'ignored-files'
  homeshick --batch link ignored-files
  [ ! -L "$HOME/.hostignored" ]
}

@test 'files ignored for other hosts are still linked' {
  castle 'ignored-files'
  homeshick --batch link ignored-files
  [ -L "$HOME/.otherhost" ]
}

@test 'files ignored by glob hostname that does not match are still linked' {
  castle 'ignored-files'
  homeshick --batch link ignored-files
  [ -L "$HOME/.globhost" ]
}

@test 'non-ignored files are linked normally' {
  castle 'ignored-files'
  homeshick --batch link ignored-files
  [ -L "$HOME/.bashrc" ]
  [ -L "$HOME/.config/app.conf" ]
}

@test 'no .homesickignore means all files are linked' {
  castle 'rc-files'
  homeshick --batch link rc-files
  [ -L "$HOME/.bashrc" ]
}

@test 'glob hostname section matches correctly' {
  castle 'ignored-files'
  # Rewrite .homesickignore so glob-* matches current host
  local repo="$HOME/.homesick/repos/ignored-files"
  local host
  host=$(hostname)
  # Create a glob pattern that matches: first 3 chars + *
  local glob_pattern="${host:0:3}*"
  cat > "$repo/.homesickignore" <<EOF
[$glob_pattern]
.globhost
EOF
  commit_repo_state "$repo"
  homeshick --batch link ignored-files
  [ ! -L "$HOME/.globhost" ]
}
