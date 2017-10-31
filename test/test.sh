#!/bin/sh

shellcheck -x -e SC2039 setup/*.sh setup/.macos setup/run_with_log has_tag.sh
