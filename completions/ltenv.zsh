if [[ ! -o interactive ]]; then
    return
fi

compctl -K _ltenv ltenv

_ltenv() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(ltenv commands)"
  else
    completions="$(ltenv completions ${words[2,-2]})"
  fi

  reply=("${(ps:\n:)completions}")
}
