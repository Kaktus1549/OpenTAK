#!/bin/bash

base64 -d <<< "ICBfX18gICAgICAgICAgICAgICAgIF9fX19fICBfICAgIF8gIF9fICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogLyBfIFwgXyBfXyAgIF9fXyBfIF98XyAgIF98LyBcICB8IHwvIC8gIF9fXyAgX19fIF8gX19fXyAgIF9fX19fIF8gX18gCnwgfCB8IHwgJ18gXCAvIF8gXCAnXyBcfCB8IC8gXyBcIHwgJyAvICAvIF9ffC8gXyBcICdfX1wgXCAvIC8gXyBcICdfX3wKfCB8X3wgfCB8XykgfCAgX18vIHwgfCB8IHwvIF9fXyBcfCAuIFwgIFxfXyBcICBfXy8gfCAgIFwgViAvICBfXy8gfCAgIAogXF9fXy98IC5fXy8gXF9fX3xffCB8X3xfL18vICAgXF9cX3xcX1wgfF9fXy9cX19ffF98ICAgIFxfLyBcX19ffF98ICAgCiAgICAgIHxffCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA="

echo " ---------- Install script ----------"

echo "Welcome to the OpenTAK server installation script!"
echo "This script will guide you through the installation process."
echo "Please make sure you have Docker and Docker Compose installed. If you want leave default values, just press Enter."
echo ""

echo " ---------- Configuration ----------"

read -p "Enter the port for the docker container (default: 1569): " DOCKER_PORT
DOCKER_PORT=${DOCKER_PORT:-1569}
read -p "Enter address for the MySQL server (default: localhost): " MYSQL_HOST
MYSQL_HOST=${MYSQL_HOST:-localhost}
read -p "Enter the port where MySQL server is running (default: 3306): " MYSQL_PORT
MYSQL_PORT=${MYSQL_PORT:-3306}
read -p "Enter the MySQL user (default default): " MYSQL_USER
MYSQL_USER=${MYSQL_USER:-default}
read -sp "Enter the MySQL password: " MYSQL_PASSWORD
echo ""
read -p "Enter the MySQL database (default: opentak): " MYSQL_DATABASE
MYSQL_DATABASE=${MYSQL_DATABASE:-opentak}

clear

base64 -d <<< "ICBfX18gICAgICAgICAgICAgICAgIF9fX19fICBfICAgIF8gIF9fICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogLyBfIFwgXyBfXyAgIF9fXyBfIF98XyAgIF98LyBcICB8IHwvIC8gIF9fXyAgX19fIF8gX19fXyAgIF9fX19fIF8gX18gCnwgfCB8IHwgJ18gXCAvIF8gXCAnXyBcfCB8IC8gXyBcIHwgJyAvICAvIF9ffC8gXyBcICdfX1wgXCAvIC8gXyBcICdfX3wKfCB8X3wgfCB8XykgfCAgX18vIHwgfCB8IHwvIF9fXyBcfCAuIFwgIFxfXyBcICBfXy8gfCAgIFwgViAvICBfXy8gfCAgIAogXF9fXy98IC5fXy8gXF9fX3xffCB8X3xfL18vICAgXF9cX3xcX1wgfF9fXy9cX19ffF98ICAgIFxfLyBcX19ffF98ICAgCiAgICAgIHxffCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA="
echo " ---------- Master user ----------"
echo "Now we will create the master admin user for the OpenTAK server."
echo "This user will have full administrative privileges."
echo ""

read -p "Enter the username for the master admin user (default: admin): " MASTER_USERNAME
MASTER_USERNAME=${MASTER_USERNAME:-admin}
read -sp "Enter the password for the master admin user: " MASTER_PASSWORD
echo ""

cat > ./REST/.env <<EOF
DATABASE_URL="mysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DATABASE"
DATABASE_HOST="$MYSQL_HOST"
DATABASE_PORT="$MYSQL_PORT"
DATABASE_USER="$MYSQL_USER"
DATABASE_PASSWORD="$MYSQL_PASSWORD"
DATABASE_NAME="$MYSQL_DATABASE"

MASTER_USER="$MASTER_USERNAME"
MASTER_PASSWORD="$MASTER_PASSWORD"
EOF

cat > ./Docker/.env <<EOF
DOCKER_PORT=$DOCKER_PORT
DATABASE_USER=$MYSQL_USER
DATABASE_PASSWORD=$MYSQL_PASSWORD
EOF

echo " ---------- Building the Docker container ----------"
cd Docker
docker compose up -d --build

echo " ---------- Installation complete ----------"
exit 0