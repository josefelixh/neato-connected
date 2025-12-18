#!/bin/bash
# ESPHome Docker CLI helper script

DOCKER_IMAGE="esphome/esphome"
CONFIG_FILE="neato-esp.yaml"

case "$1" in
  compile)
    echo "Compiling $CONFIG_FILE..."
    docker run --rm -v "${PWD}":/config -it $DOCKER_IMAGE compile /config/$CONFIG_FILE
    ;;

  upload)
    echo "Uploading to $CONFIG_FILE (OTA)..."
    docker run --rm --network=host -v "${PWD}":/config -it $DOCKER_IMAGE upload /config/$CONFIG_FILE
    ;;

  run)
    echo "Compiling and uploading $CONFIG_FILE..."
    docker run --rm --network=host -v "${PWD}":/config -it $DOCKER_IMAGE run /config/$CONFIG_FILE
    ;;

  logs)
    echo "Showing logs for $CONFIG_FILE..."
    docker run --rm --network=host -v "${PWD}":/config -it $DOCKER_IMAGE logs /config/$CONFIG_FILE
    ;;

  validate)
    echo "Validating $CONFIG_FILE..."
    docker run --rm -v "${PWD}":/config -it $DOCKER_IMAGE config /config/$CONFIG_FILE
    ;;

  clean)
    echo "Cleaning build files..."
    docker run --rm -v "${PWD}":/config -it $DOCKER_IMAGE clean /config/$CONFIG_FILE
    ;;

  *)
    echo "ESPHome Docker CLI Helper"
    echo ""
    echo "Usage: ./esphome.sh [command]"
    echo ""
    echo "Commands:"
    echo "  compile   - Compile the firmware"
    echo "  upload    - Upload firmware via OTA (requires compile first)"
    echo "  run       - Compile and upload in one step"
    echo "  logs      - View device logs"
    echo "  validate  - Validate configuration"
    echo "  clean     - Clean build files"
    echo ""
    exit 1
    ;;
esac
