function __fish_ltenv_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'ltenv' ]
    return 0
  end
  return 1
end

function __fish_ltenv_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c ltenv -n '__fish_ltenv_needs_command' -a '(ltenv commands)'
for cmd in (ltenv commands)
  complete -f -c ltenv -n "__fish_ltenv_using_command $cmd" -a "(ltenv completions $cmd)"
end
