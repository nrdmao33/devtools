#!/bin/bash
# clean-stale-bazel-cache.sh
cleaned=0
for dir in ~/.cache/bazel/_bazel_*/*/; do
  marker="$dir/DO_NOT_BUILD_HERE"
  if [ -f "$marker" ]; then
    workspace=$(cat "$marker")
    if [ ! -d "$workspace" ]; then
      echo "Removing: $workspace"
      rm -rf "$dir"
      ((cleaned++))
    fi
  fi
done
echo "Cleaned $cleaned stale output base(s)."

# Delete disk cache entries older than 30 days
DISK_CACHE=$HOME/.cache/bazel_disk_cache
du -sh $DISK_CACHE
find $DISK_CACHE -atime +30 -delete
du -sh $DISK_CACHE
