#!/usr/bin/env bash
set -e
command -v docker >/dev/null || { echo 'ERROR: docker required'; exit 1; }
echo 'OK: docker found'
