#!/bin/bash
# Run: bash claude-code/hooks/lib/test-merge-detection.sh
# Cases: expect "merge" (guard must fire) or "no" (mention only).
source "$(dirname "$0")/merge-target.sh"
M="gh pr ""merge"
NL=$'\n'
pass=0; fail=0
t() {
  local want=$1 desc=$2 cmd=$3 got=no
  is_merge_command "$cmd" && got=merge
  if [ "$got" = "$want" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $desc (want $want, got $got)"; fi
}
t merge "plain"                 "$M 12"
t merge "after cd"              "cd ~/code/x && $M 12 -R a/b"
t merge "after quoted cd"       "cd \"/Users/c/Corey's Projects\" && $M 12"
t merge "in subshell"           "( $M 12 )"
t merge "bash -c single"        "bash -c '$M 12'"
t merge "eval double"           "eval \"$M 12\""
t merge "bash heredoc"          "bash <<'EOF'${NL}$M 12${NL}EOF"
t merge "python heredoc"        "python3 - <<'EOF'${NL}import os; os.system('$M 12')${NL}EOF"
t merge "real merge after body" "gh pr create --body-file - <<'EOF'${NL}see $M${NL}EOF${NL}$M 12"
t merge "\$() in dquotes"       "echo \"\$($M 12)\""
t merge "backticks in dquotes"  "echo \"\`$M 12\`\""
t merge "unclosed heredoc tag"  "git commit -m \"use <<EOF here\"${NL}$M 12"
t no    "pr body heredoc"       "gh pr create --body-file - <<'EOF'${NL}Run $M 14 after${NL}EOF"
t no    "commit message"        "git commit -m \"guard now catches $M\""
t no    "echo single quotes"    "echo 'use $M 5'"
t no    "issue body -b"         "gh issue create -b \"then $M 3\""
t no    "cat heredoc"           "cat > f.md <<EOF${NL}$M${NL}EOF"
t no    "grep for it"           "grep -rn '$M' hooks/"
echo "pass=$pass fail=$fail"
# cd path survives cleaning, quotes intact
clean_command "cd \"/Users/c/Corey's Projects\" && $M 12" | grep -q "Corey's Projects" && echo "cd path kept" || echo "FAIL: cd path lost"
[ "$fail" -eq 0 ]
