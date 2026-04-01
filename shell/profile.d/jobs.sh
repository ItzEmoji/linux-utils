# Begin /etc/profile.d/jobs.sh
export MAKEFLAGS="-j$(nproc)"
export CARGO_BUILD_JOBS=$(nproc)
export NINJAJOBS=$(nproc)
# End /etc/profile.d/jobs.sh
