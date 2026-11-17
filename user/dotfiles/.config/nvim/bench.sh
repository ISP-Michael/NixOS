#!/bin/sh
# Compare the current (vim.pack) config with the preserved lazy.nvim config.
#
#   ./bench.sh          # 7 runs per case
#   N=15 ./bench.sh     # more runs
#
# The old config is ~/.config/nvim-lazy and shares ~/.local/share/nvim-lazy
# with the installed lazy.nvim plugins.
set -eu

N=${N:-7}
TMP=$(mktemp -d "${TMPDIR:-/tmp}/nvim-bench.XXXXXX")
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/bench.py" <<'PY'
def main():
    print("hi")

if __name__ == "__main__":
    main()
PY

median() {
  sort -n | awk '{ a[NR] = $1 } END { print a[int((NR + 1) / 2)] }'
}

startup() {
  # $1 = old|new, $2 = label, $3 = optional file
  cfg=$1
  label=$2
  file=${3:-}
  for i in $(seq 1 "$N"); do
    st="$TMP/${cfg}-${label}-${i}.st"
    if [ "$cfg" = old ]; then
      if [ -n "$file" ]; then
        NVIM_APPNAME=nvim-lazy nvim --headless "$file" --startuptime "$st" +qa >/dev/null 2>&1
      else
        NVIM_APPNAME=nvim-lazy nvim --headless --startuptime "$st" +qa >/dev/null 2>&1
      fi
    else
      if [ -n "$file" ]; then
        nvim --headless "$file" --startuptime "$st" +qa >/dev/null 2>&1
      else
        nvim --headless --startuptime "$st" +qa >/dev/null 2>&1
      fi
    fi
    grep 'NVIM STARTED' "$st" | tail -1 | awk '{ print $1 }'
  done | median
}

wall() {
  # $1 = old|new, $2 = file|empty, $3 = load-all command
  cfg=$1
  file=$2
  cmd=$3
  for i in $(seq 1 "$N"); do
    start=$(date +%s%N)
    if [ "$cfg" = old ]; then
      if [ "$file" = empty ]; then
        NVIM_APPNAME=nvim-lazy nvim --headless +"$cmd" +qa >/dev/null 2>&1
      else
        NVIM_APPNAME=nvim-lazy nvim --headless "$file" +"$cmd" +qa >/dev/null 2>&1
      fi
    else
      if [ "$file" = empty ]; then
        nvim --headless +"$cmd" +qa >/dev/null 2>&1
      else
        nvim --headless "$file" +"$cmd" +qa >/dev/null 2>&1
      fi
    fi
    end=$(date +%s%N)
    echo $(( (end - start) / 1000000 ))
  done | median
}

print_row() {
  name=$1
  old=$2
  new=$3
  printf '%-24s %10s %10s %8s\n' "$name" "$old" "$new" \
    "$(awk -v o="$old" -v n="$new" 'BEGIN { printf "%.2fx", o / n }')"
}

old_empty=$(startup old empty)
new_empty=$(startup new empty)
old_py=$(startup old python "$TMP/bench.py")
new_py=$(startup new python "$TMP/bench.py")
old_all=$(wall old empty 'Lazy! load all')
new_all=$(wall new empty 'PackLoadAll')
old_all_py=$(wall old "$TMP/bench.py" 'Lazy! load all')
new_all_py=$(wall new "$TMP/bench.py" 'PackLoadAll')

printf '%-24s %10s %10s %8s\n' 'case' 'lazy.nvim' 'vim.pack' 'faster'
printf '%-24s %10s %10s %8s\n' '----' '---------' '--------' '------'
print_row 'empty, no plugins' "$old_empty" "$new_empty"
print_row 'python file' "$old_py" "$new_py"
print_row 'all plugins' "$old_all" "$new_all"
print_row 'all plugins + python' "$old_all_py" "$new_all_py"
printf '\nAll values are milliseconds (median of %s runs).\n' "$N"
