#!/bin/sh

[ -n "$SYSTEM_TAG_FILE" ] || SYSTEM_TAG_FILE="$HOME/.system_tags"
SYSTEM_TAGS=$(tr '-' '_' 2>/dev/null < "$SYSTEM_TAG_FILE")

has_tag() {
  local tag_name
  tag_name=$(echo "$1" | tr '-' '_')

  [[ " $SYSTEM_TAGS " == *" $tag_name "* ]]
}
