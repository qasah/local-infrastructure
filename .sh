#!/bin/sh

CONFIG_FILE='/config.yaml'
OUTPUT_DIR='/generated'
OUTPUT_FILE='docker-compose.yaml'

OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_FILE"

if [ ! -f $CONFIG_FILE ]; then
  echo 'Configuration file not found!'
  exit 1
fi

if [ -f $OUTPUT_PATH ]
then 
    rm $OUTPUT_PATH
fi 

if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir -p "$OUTPUT_DIR"
fi

PROJECT=$(yq e '.project' $CONFIG_FILE)
COMPONENTS=$(yq e '.components' $CONFIG_FILE)

echo "name: $PROJECT" >> $OUTPUT_PATH
echo "services:" >> $OUTPUT_PATH

for row in $(echo "${COMPONENTS}" | yq e -o=j - | jq -r '.[] | @base64'); do
  _jq() {
    echo ${row} | base64 -d | jq -r ${1}
  }

  IMAGE=$(_jq '.image')
  TAG=$(_jq '.tag')
  PORT=$(_jq '.port')
  RESTART=$(_jq '.restart')
  INSTANCES=$(_jq '.instances')
  VOLUME=$(_jq '.volume')

  for row in $(echo "${INSTANCES}" | yq e -o=j - | jq -r '.[] | @base64'); do
    INSTANCE_NAME=$(_jq '.name')
    INSTANCE_LABEL=$(_jq '.label')
    INSTANCE_PORT=$(_jq '.port')
    INSTANCE_VALUES=$(_jq '.values')
    INSTANCE_LABEL=$(_jq '.label')

    echo "  $INSTANCE_NAME:" >> $OUTPUT_PATH
    echo "    image: $IMAGE:$TAG" >> $OUTPUT_PATH
    echo "    restart: $RESTART" >> $OUTPUT_PATH    
    echo "    ports:" >> $OUTPUT_PATH
    echo "      - \"$INSTANCE_PORT:$PORT\"" >> $OUTPUT_PATH
    echo "    environment:" >> $OUTPUT_PATH 

    for row in $(echo "${INSTANCE_VALUES}" | yq e -o=j - | jq -r '.[] | @base64'); do
      VALUE=$(echo ${row} | base64 -d)
      echo "      - ${VALUE}" >> $OUTPUT_PATH
    done
    
    echo "    deploy:" >> $OUTPUT_PATH
    echo "      restart_policy:" >> $OUTPUT_PATH
    echo "        condition: on-failure" >> $OUTPUT_PATH
    echo "        delay: 5s" >> $OUTPUT_PATH
    echo "        max_attempts: 3" >> $OUTPUT_PATH
    echo "        window: 120s" >> $OUTPUT_PATH
    echo "      resources:" >> $OUTPUT_PATH
    echo "        limits:" >> $OUTPUT_PATH
    echo "          cpus: 0.50" >> $OUTPUT_PATH
    echo "          memory: 50M" >> $OUTPUT_PATH
    echo "        reservations:" >> $OUTPUT_PATH
    echo "          cpus: 0.25" >> $OUTPUT_PATH
    echo "          memory: 20M" >> $OUTPUT_PATH
    echo
  done
done
