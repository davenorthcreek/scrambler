#!/bin/bash

# Local Development Script for Sentence Scrambler
# This script sets up and runs the Streamlit app locally

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Configuration
APP_NAME="Sentence Scrambler"
PORT=8501

print_status "🔤 Starting $APP_NAME locally..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is not installed. Please install Python 3.8 or higher."
    exit 1
fi

# Check if we're in the correct directory
if [ ! -f "app.py" ]; then
    print_error "app.py not found. Please run this script from the project directory."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    print_status "Creating virtual environment..."
    python3 -m venv venv
    print_success "Virtual environment created!"
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source venv/bin/activate

# Check if requirements are installed
if [ ! -f "venv/pyvenv.cfg" ] || [ ! -f "requirements.txt" ]; then
    print_warning "Requirements file not found or virtual environment is corrupted."
    print_status "Installing/updating dependencies..."
    pip install --upgrade pip
    pip install -r requirements.txt
    print_success "Dependencies installed!"
else
    # Check if streamlit is installed
    if ! pip show streamlit &> /dev/null; then
        print_status "Installing dependencies..."
        pip install --upgrade pip
        pip install -r requirements.txt
        print_success "Dependencies installed!"
    fi
fi

# Check if port is available
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    print_warning "Port $PORT is already in use. Trying alternative ports..."
    for port in 8502 8503 8504 8505; do
        if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            PORT=$port
            break
        fi
    done
    print_status "Using port $PORT instead"
fi

# Create .streamlit directory and config if it doesn't exist
if [ ! -d ".streamlit" ]; then
    print_status "Creating Streamlit configuration..."
    mkdir -p .streamlit
    cat > .streamlit/config.toml << EOF
[server]
port = $PORT
headless = false
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
    print_success "Streamlit configuration created!"
fi

# Display startup information
echo
print_success "🚀 Starting $APP_NAME..."
echo
echo "📋 Configuration:"
echo "  - Port: $PORT"
echo "  - URL: http://localhost:$PORT"
echo "  - Environment: Development"
echo
echo "🎯 Features:"
echo "  - 📚 Multiple difficulty levels (Easy, Medium, Hard)"
echo "  - 🎲 Random sentence generation"
echo "  - ✏️ Custom sentence creation"
echo "  - ✅ Interactive answer checking"
echo "  - 🖨️ Print-friendly versions"
echo "  - 💡 Teaching tips and guidance"
echo
echo "👩‍🏫 For Teachers:"
echo "  - Use the sidebar to control difficulty and sentence selection"
echo "  - Display scrambled words to students on your screen"
echo "  - Access teaching tips and print versions"
echo
echo "👨‍🎓 For Students:"
echo "  - Look at the colorful word cards"
echo "  - Type your answer in the input field"
echo "  - Click 'Check My Answer' for instant feedback"
echo
print_warning "Press Ctrl+C to stop the server"
echo

# Start the Streamlit app
streamlit run app.py --server.port=$PORT

# Cleanup message (only shows if Streamlit exits gracefully)
echo
print_status "📚 Thanks for using $APP_NAME!"
print_status "💡 To run again, just execute: ./run_local.sh"
