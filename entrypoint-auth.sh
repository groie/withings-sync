#!/bin/sh
# Temporary entrypoint for initial Withings authentication
# This runs the sync command once interactively, then exits

mkdir -p /home/withings-sync/config
poetry run withings-sync --config-folder /home/withings-sync/config
