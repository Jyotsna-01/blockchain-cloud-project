#!/bin/bash
# This script runs automatically on first EC2 boot
# Every line is logged to /var/log/user-data.log for debugging

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "===== Starting deployment at $(date) ====="

# ─── SYSTEM UPDATE ─────────────────────────────────────────────────────────────
echo "Updating system packages..."
dnf update -y
dnf install -y python3 python3-pip python3-devel git mysql gcc

# ─── CLONE YOUR REPO ───────────────────────────────────────────────────────────
echo "Cloning application repository..."
cd /home/ec2-user
git clone https://github.com/Jyotsna-01/securing-data-with-blockchain-and-ai.git app
cd app

# ─── PYTHON ENVIRONMENT ────────────────────────────────────────────────────────
echo "Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install django mysqlclient boto3 gunicorn python-decouple

# Install from requirements if it exists
if [ -f packages.txt ]; then
    pip install -r packages.txt
fi

# ─── ENVIRONMENT VARIABLES ─────────────────────────────────────────────────────
# These values are injected by Terraform at deploy time via templatefile()
echo "Writing environment configuration..."
cat > /home/ec2-user/app/.env << EOF
DEBUG=False
DB_HOST=${db_host}
DB_NAME=${db_name}
DB_USER=${db_username}
DB_PASSWORD=${db_password}
AWS_STORAGE_BUCKET_NAME=${app_bucket_name}
ALLOWED_HOSTS=*
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
EOF

# ─── DJANGO SETUP ──────────────────────────────────────────────────────────────
echo "Running Django setup..."
python3 manage.py collectstatic --noinput 2>/dev/null || true
python3 manage.py migrate --noinput 2>/dev/null || true

# ─── START GUNICORN (Production Django Server) ─────────────────────────────────
# runserver is for development only — Gunicorn is production grade
echo "Starting Gunicorn server..."
gunicorn --bind 0.0.0.0:8000 \
         --workers 2 \
         --daemon \
         --access-logfile /var/log/gunicorn-access.log \
         --error-logfile /var/log/gunicorn-error.log \
         Secure.wsgi:application 2>/dev/null || \
gunicorn --bind 0.0.0.0:8000 \
         --workers 2 \
         --daemon \
         --access-logfile /var/log/gunicorn-access.log \
         --error-logfile /var/log/gunicorn-error.log \
         DataSecuring.wsgi:application 2>/dev/null || true

echo "===== Deployment complete at $(date) ====="