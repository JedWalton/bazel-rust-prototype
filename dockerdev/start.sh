#!/bin/bash

systemctl --user start docker-desktop

# Wait for Docker daemon to become available
daemon_wait_message_displayed=0
until docker info &>/dev/null; do
    if [ $daemon_wait_message_displayed -eq 0 ]; then
        echo -e "Starting Docker daemon...\n"
    fi
    sleep 5 
    echo "Waiting for Docker daemon to come online."
    daemon_wait_message_displayed=1
done

if [ $daemon_wait_message_displayed -eq 1 ]; then
    echo -e "\nDocker daemon is online!\n"
fi

# Docker daemon is now available, proceed with the script
echo -e "Building your development environment.\n"
image_exists=$(docker images -q dev-env | wc -l)
if [ $image_exists -eq 0 ]; then
    echo -e "First startup may take some time...\n"
    echo -e "Then this will be cached :)\n"
fi

sudo rm -rf /home/$USER/Git/jedwaltondev/dev/.dotfiles
cp -r ~/.dotfiles /home/$USER/Git/jedwaltondev/dev

chmod -R 777 /home/$USER/Git/jedwaltondev/ 2>/dev/null || true
git config --global --add safe.directory /home/$USER/Git/jedwaltondev

docker rm -f dev-env 2>/dev/null || true
docker rm -f dev-container 2>/dev/null || true

# Prompt for password and build image
read -e -s -p "Please enter a password for your development user: " PASSWORD
echo -e "\n"

docker build -t dev-env . --build-arg USER=${USER} --build-arg PASSWORD=${PASSWORD}

docker stop registry 2>/dev/null || true
docker rm registry 2>/dev/null || true

ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "[localhost]:2222" 2>/dev/null || true

docker volume create dev-home >/dev/null

docker run -d -p 5000:5000 --restart=always --name registry registry:2 >/dev/null


docker run -d --rm \
  --init \
  --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock:Z \
  -v /$HOME/.ssh:/home/dev/.ssh:Z \
  -v /$HOME/Git/jedwaltondev:/home/dev/Git/jedwaltondev:Z \
  -v dev-home:/home/dev \
  --user root \
  --name dev-container \
  -p 2222:22 \
  -p 3000-3050:3000-3050 \
  dev-env >/dev/null \
  /bin/bash -c "chown -R dev:dev /var/run/docker.sock && chmod -R 775 /var/run/docker.sock && /usr/sbin/sshd -D" &


rm -rf /home/$USER/Git/jedwaltondev/dev/.dotfiles

# Wait for the SSH server to become available
ssh_wait_message_displayed=0

until nc -z localhost 2222 &>/dev/null; do
    if [ $ssh_wait_message_displayed -eq 0 ]; then
        echo -e "Starting SSH server...\n"
    fi
    sleep 5
    echo "Waiting for SSH server to come online."
    ssh_wait_message_displayed=1
done

if [ $ssh_wait_message_displayed -eq 1 ]; then
    echo -e "\nDevelopment server online!\n"
fi

echo -e "To access your development environment, run the following command:\n"
echo -e "$ ssh dev@localhost -p 2222\n"
echo -e "To update your rust analyzer, From ~/Git/jedwaltondev, run the following command:\n"
echo -e "bazel run @rules_rust//tools/rust_analyzer:gen_rust_project\n"

