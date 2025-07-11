#!/bin/bash

# EC2 Deployment Script for Sentence Scrambler
# This script sets up and deploys the Streamlit app on an EC2 instance

set -e  # Exit on any error

echo "🚀 Starting EC2 deployment for Sentence Scrambler..."

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="sentence-scrambler"
APP_DIR="/opt/$APP_NAME"
SERVICE_NAME="sentence-scrambler"
STREAMLIT_PORT=8501
APACHE_PORT=80

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root (use sudo)"
   exit 1
fi

# Update system packages
print_status "Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install Python and dependencies
print_status "Installing Python and system dependencies..."
apt-get install -y python3 python3-pip python3-venv apache2 git supervisor

# Store original directory
ORIGINAL_DIR=$(pwd)

# Create application directory
print_status "Creating application directory..."
mkdir -p $APP_DIR

# Create application user
print_status "Creating application user..."
if ! id "$APP_NAME" &>/dev/null; then
    useradd -r -s /bin/bash -d $APP_DIR $APP_NAME
fi

# Copy application files (assumes files are in current directory)
print_status "Setting up application files..."
cp $ORIGINAL_DIR/app.py $APP_DIR/
cp $ORIGINAL_DIR/requirements.txt $APP_DIR/
cp $ORIGINAL_DIR/README.md $APP_DIR/

# Change to application directory
cd $APP_DIR

# Create virtual environment
print_status "Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
print_status "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Create Streamlit configuration
print_status "Creating Streamlit configuration..."
mkdir -p .streamlit
cat > .streamlit/config.toml << EOF
[server]
port = $STREAMLIT_PORT
headless = true
enableCORS = false
enableXsrfProtection = false

[browser]
gatherUsageStats = false

[theme]
primaryColor = "#FF6B6B"
backgroundColor = "#FFFFFF"
secondaryBackgroundColor = "#F0F2F6"
textColor = "#262730"
font = "sans serif"
EOF

# Create systemd service file
print_status "Creating systemd service..."
cat > /etc/systemd/system/$SERVICE_NAME.service << EOF
[Unit]
Description=Sentence Scrambler Streamlit App
After=network.target

[Service]
Type=simple
User=$APP_NAME
WorkingDirectory=$APP_DIR
Environment=PATH=$APP_DIR/venv/bin
ExecStart=$APP_DIR/venv/bin/streamlit run app.py --server.port=$STREAMLIT_PORT --server.address=0.0.0.0
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Configure Apache2
print_status "Configuring Apache2..."

# Enable required Apache modules
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_wstunnel
a2enmod headers
a2enmod rewrite

# Create Apache virtual host
cat > /etc/apache2/sites-available/$APP_NAME.conf << EOF
<VirtualHost *:$APACHE_PORT>
    ServerName $APP_NAME
    DocumentRoot $APP_DIR
    
    # Security headers
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    
    # Proxy to Streamlit
    ProxyPreserveHost On
    ProxyPass /health !
    ProxyPass / http://127.0.0.1:$STREAMLIT_PORT/
    ProxyPassReverse / http://127.0.0.1:$STREAMLIT_PORT/
    
    # WebSocket support for Streamlit
    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule ^/?(.*) "ws://127.0.0.1:$STREAMLIT_PORT/\$1" [P,L]
    
    # Health check endpoint
    Alias /health /var/www/html/health.html
    
    # Logging
    ErrorLog \${APACHE_LOG_DIR}/$APP_NAME-error.log
    CustomLog \${APACHE_LOG_DIR}/$APP_NAME-access.log combined
</VirtualHost>
EOF

# Create health check file
echo "healthy" > /var/www/html/health.html

# Enable the site
a2ensite $APP_NAME.conf

# Test Apache configuration
print_status "Testing Apache configuration..."
apache2ctl configtest

# Set proper permissions
print_status "Setting file permissions..."
chown -R $APP_NAME:$APP_NAME $APP_DIR
chmod +x $APP_DIR/venv/bin/streamlit

# Start services
print_status "Starting services..."
systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME
systemctl enable apache2
systemctl restart apache2

# Create startup script
print_status "Creating management scripts..."
cat > /usr/local/bin/sentence-scrambler << 'EOF'
#!/bin/bash
case "$1" in
    start)
        sudo systemctl start sentence-scrambler
        sudo systemctl start apache2
        echo "Sentence Scrambler started"
        ;;
    stop)
        sudo systemctl stop sentence-scrambler
        echo "Sentence Scrambler stopped"
        ;;
    restart)
        sudo systemctl restart sentence-scrambler
        sudo systemctl restart apache2
        echo "Sentence Scrambler restarted"
        ;;
    status)
        sudo systemctl status sentence-scrambler
        ;;
    logs)
        sudo journalctl -u sentence-scrambler -f
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs}"
        exit 1
        ;;
esac
EOF

chmod +x /usr/local/bin/sentence-scrambler

# Create log rotation
print_status "Setting up log rotation..."
cat > /etc/logrotate.d/$SERVICE_NAME << EOF
/var/log/$SERVICE_NAME/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 $APP_NAME $APP_NAME
}
EOF

# Create backup script
print_status "Creating backup script..."
cat > /usr/local/bin/backup-sentence-scrambler << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/backups/sentence-scrambler"
DATE=$(date +%Y%m%d_%H%M%S)
APP_DIR="/opt/sentence-scrambler"

mkdir -p $BACKUP_DIR

# Backup application files
tar -czf $BACKUP_DIR/sentence-scrambler_$DATE.tar.gz \
    -C /opt sentence-scrambler \
    --exclude=sentence-scrambler/venv \
    --exclude=sentence-scrambler/__pycache__

# Keep only last 10 backups
cd $BACKUP_DIR
ls -t *.tar.gz | tail -n +11 | xargs rm -f

echo "Backup completed: sentence-scrambler_$DATE.tar.gz"
EOF

chmod +x /usr/local/bin/backup-sentence-scrambler

# Setup firewall (if ufw is available)
if command -v ufw &> /dev/null; then
    print_status "Configuring firewall..."
    ufw allow ssh
    ufw allow $APACHE_PORT
    ufw --force enable
fi

# Wait for services to start
print_status "Waiting for services to start..."
sleep 10

# Check service status
print_status "Checking service status..."
if systemctl is-active --quiet $SERVICE_NAME; then
    print_success "Sentence Scrambler service is running"
else
    print_error "Sentence Scrambler service failed to start"
    systemctl status $SERVICE_NAME
    exit 1
fi

if systemctl is-active --quiet apache2; then
    print_success "Apache2 service is running"
else
    print_error "Apache2 service failed to start"
    systemctl status apache2
    exit 1
fi

# Get server IP
SERVER_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || hostname -I | awk '{print $1}')

print_success "🎉 Deployment completed successfully!"
echo
echo "📋 Deployment Summary:"
echo "  - Application: Sentence Scrambler"
echo "  - Status: Running"
echo "  - URL: http://$SERVER_IP"
echo "  - Port: $APACHE_PORT"
echo "  - Service: $SERVICE_NAME"
echo
echo "📖 Management Commands:"
echo "  - Start:    sentence-scrambler start"
echo "  - Stop:     sentence-scrambler stop"
echo "  - Restart:  sentence-scrambler restart"
echo "  - Status:   sentence-scrambler status"
echo "  - Logs:     sentence-scrambler logs"
echo "  - Backup:   backup-sentence-scrambler"
echo
echo "📁 Important Paths:"
echo "  - App Directory: $APP_DIR"
echo "  - Config File: $APP_DIR/.streamlit/config.toml"
echo "  - Service File: /etc/systemd/system/$SERVICE_NAME.service"
echo "  - Apache Config: /etc/apache2/sites-available/$APP_NAME.conf"
echo
echo "🔧 Next Steps:"
echo "1. Test the application by visiting http://$SERVER_IP"
echo "2. Configure SSL certificate for HTTPS (recommended)"
echo "3. Set up monitoring and alerting"
echo "4. Configure automated backups"
echo
print_warning "Note: This deployment uses HTTP. For production, configure HTTPS with SSL certificates."
