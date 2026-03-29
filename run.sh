CONTAINER_HOME='/root'
HOST_HOME=$HOME/.cld

mkdir -p $HOST_HOME
[ ! -s $HOST_HOME/.claude.json ] && echo '{}' > $HOST_HOME/.claude.json

mount_if_exists() {
  local src="$1"
  local dst="$2"
  local mode="${3:-ro}"

  if [ -d "$src" ]; then
    echo "-v $src:$dst:$mode"
  fi
}

GIT_MOUNT=$(mount_if_exists "$(pwd)/.git" "/ws/.git")
NODE_MODULES_MOUNT=$(mount_if_exists "$(pwd)/node_modules" "/ws/node_modules")

docker run \
  --pull=never \
  -v $(pwd):/ws \
  $GIT_MOUNT \
  $NODE_MODULES_MOUNT \
  -v $HOST_HOME/.claude:$CONTAINER_HOME/.claude \
  -v $HOST_HOME/.claude.json:$CONTAINER_HOME/.claude.json \
  --device /dev/snd:/dev/snd \
  -it \
  cld