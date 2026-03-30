pkg-list() {
  {
    # --- binaries (FAST) ---
    compgen -c 2>/dev/null \
      | sort -u \
      | awk '{print "BIN\t"$1"\tunknown"}'

    # --- shared libraries ---
    ldconfig -p 2>/dev/null \
      | awk -F'=> ' '/=>/ {
          name=$1
          path=$2
          sub(/ .*/, "", name)
          sub(/\.so.*/, "", name)

          ver="unknown"
          if (match(path, /\.so\.[^\/]+$/)) {
            ver=substr(path, RSTART+4)
          }

          print "LIB\t" name "\t" ver
        }'

    # --- pkg-config (parallel for speed) ---
    pkg-config --list-all 2>/dev/null \
      | awk '{print $1}' \
      | sort -u \
      | xargs -r -P$(nproc 2>/dev/null || echo 4) -I{} sh -c '
          v=$(pkg-config --modversion "{}" 2>/dev/null || echo unknown)
          printf "PKG\t%s\t%s\n" "{}" "$v"
        '
  } | sort -u
}
