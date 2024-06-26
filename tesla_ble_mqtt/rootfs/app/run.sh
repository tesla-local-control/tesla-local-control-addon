#!/bin/sh

[ -L /command/with-contenv ] \
  && exec /command/with-contenv /usr/bin/bashio /app/run-tesla-local-control-main.sh \
  || exec /bin/sh run-tesla-local-control-main.sh
