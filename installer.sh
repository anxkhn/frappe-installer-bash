#!/bin/bash

# Function to display progress
display_step() {
    echo "------------------------------------------------------------"
    echo "STEP $1: $2"
    echo "------------------------------------------------------------"
}

# Function to check if a package is installed
is_package_installed() {
    dpkg -l | grep -q "^ii  $1"
}

# Check if the script is running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run this script as root"
    exit 1
fi

# Ask for root password
read -s -p "[sudo] password for $(whoami): " root_password

echo

# Ask for DB root password
read -s -p "Enter DB root password: " db_root_password
if [ -z "$db_root_password" ]; then
    echo "Error: Password cannot be empty"
    exit 1
fi

echo
# Ask for test app admin password
read -s -p "Admin password for test app: " admin_password
if [ -z "$admin_password" ]; then
    echo "Error: Password cannot be empty"
    exit 1
fi

# Update package list
echo
echo "$root_password" | sudo -S apt update
echo

# Check/Install Python 3.11
default_python_version=$(python3 --version 2>&1)
if [[ $default_python_version == *"3.11"* ]]; then
    echo "Default Python version is already 3.11.x. Skipping Python 3.11 installation."
    display_step "0" "Upgrade packages"
    echo
    sudo apt upgrade -y
else
    display_step "0" "Add Python repository and upgrade packages"
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt install -y python3.11
    python3.11 --version
    sudo apt upgrade -y
fi

# Install Prerequisites
display_step "1" "Install git"
if ! is_package_installed git; then
    sudo apt install -y git
else
    echo "Git is already installed. Skipping..."
fi

display_step "2" "Install python3-dev"
if ! is_package_installed python3-dev; then
    sudo apt install -y python3-dev
else
    echo "python3-dev is already installed. Skipping..."
fi

display_step "3" "Install setuptools and pip"
if ! is_package_installed python3-setuptools; then
    sudo apt install -y python3-setuptools
else
    echo "python3-setuptools is already installed. Skipping..."
fi
if ! is_package_installed python3-pip; then
    sudo apt install -y python3-pip
else
    echo "python3-pip is already installed. Skipping..."
fi

display_step "4" "Install virtualenv"
if ! is_package_installed python3.11-venv; then
    sudo apt install -y python3.11-venv
else
    echo "python3.11-venv is already installed. Skipping..."
fi

display_step "5" "Install MariaDB"
if ! is_package_installed mariadb-server; then
    sudo apt install -y software-properties-common
    sudo apt install -y mariadb-server
else
    echo "mariadb-server is already installed. Skipping..."
fi

sudo mysql_secure_installation <<EOF

$'\n'
Y
Y
$db_root_password
$db_root_password
Y
Y
Y
Y
EOF

display_step "6" "Install MySQL database development files"
if ! is_package_installed libmysqlclient-dev; then
    sudo apt install -y libmysqlclient-dev
else
    echo "libmysqlclient-dev is already installed. Skipping..."
fi

display_step "7" "Edit MariaDB configuration"
if grep -q '^\[server\]' /etc/mysql/mariadb.conf.d/50-server.cnf &&
grep -q '^\[mysqld\]' /etc/mysql/mariadb.conf.d/50-server.cnf &&
grep -q '^\[mysql\]' /etc/mysql/mariadb.conf.d/50-server.cnf; then
    echo "MariaDB configuration block already exists. Skipping..."
else
    sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf > /dev/null <<EOT
[server]
user = mysql
pid-file = /run/mysqld/mysqld.pid
socket = /run/mysqld/mysqld.sock
basedir = /usr
datadir = /var/lib/mysql
tmpdir = /tmp
lc-messages-dir = /usr/share/mysql
bind-address = 127.0.0.1
query_cache_size = 16M
log_error = /var/log/mysql/error.log

[mysqld]
innodb-file-format=barracuda
innodb-file-per-table=1
innodb-large-prefix=1
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
EOT
fi

sudo service mysql restart

display_step "8" "Install Redis"
if ! is_package_installed redis-server; then
    sudo apt install -y redis-server
else
    echo "redis-server is already installed. Skipping..."
fi

display_step "9" "Install Node.js 18.x package"
if ! is_package_installed curl; then
    sudo apt install -y curl
else
    echo "curl is already installed. Skipping..."
fi

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
source ~/.profile
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 18
nvm_output=$(nvm use 18)

if [[ "$nvm_output" != *"Now using node v18."* ]]; then
    echo "Error: Failed to use Node.js version 18.x."
    exit 1
else
    echo "Node.js version 18.x is installed and activated successfully."
fi

display_step "10" "Install Yarn"
sudo apt install -y npm
sudo npm install -g yarn

display_step "11" "Install wkhtmltopdf"
sudo apt install -y xvfb libfontconfig wkhtmltopdf

display_step "12" "Install frappe-bench"
sudo -H pip3 install frappe-bench
bench --version
installed_bench_version=$(bench --version)
if [[ "$installed_bench_version" == *"5."* ]]; then
    echo "Congratulations! frappe-bench is installed."
else
    echo "Error: frappe-bench is not installed properly."
    exit 1
fi

display_step "13" "Initialize frappe-bench & install Frappe latest version"
bench init frappe-bench --frappe-branch version-15 --python python3.11
cd frappe-bench/

display_step "14" "Create a site in frappe bench"
bench new-site hello.com --admin-password $admin_password --db-root-password $db_root_password
bench --site hello.com add-to-hosts

display_step "15" "Install ERPNext latest version in bench & site"
bench get-app erpnext --branch version-15
bench --site hello.com install-app erpnext
sudo kill -9 $(lsof -t -i:11000)
sudo kill -9 $(lsof -t -i:13000)
bench start &
sleep 5
xdg-open "http://hello.com:8000"

echo "------------------------------------------------------------"
echo "Installation Complete!"
echo "URL: http://hello.com:8000"
echo "Use the following credentials to login:"
echo "user: administrator"
echo "password: $admin_password"
echo "------------------------------------------------------------"
echo "Thank you for using the installer. Feel free to star the repo at https://github.com/anxkhn/frappe-installer-bash"