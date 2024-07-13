#!/bin/bash

<< task
Deploy a Django app and handle the code for error
task

code_clone(){
    echo "Cloning the Django App..."
    if ! git clone https://github.com/LondheShubham153/django-notes-app.git; then
        echo "Failed to clone the repository or the directory already exists."
        if [ -d "django-notes-app" ]; then
            cd django-notes-app
        else
            exit 1
        fi
    else
        cd django-notes-app
    fi
}

install_requirements(){
    echo "Installing the Dependencies..."
    sudo apt update

    # Install Docker
    if ! sudo apt install docker.io -y; then
        echo "Failed to install Docker."
        exit 1
    fi

    # Install Nginx
    if ! sudo apt install nginx -y; then
        echo "Failed to install Nginx."
        exit 1
    fi
}

required_restart(){
    # Fix Docker and Nginx service issues
    sudo systemctl daemon-reload

    # Enable and start Docker
    if ! sudo systemctl enable docker; then
        echo "Failed to enable Docker service."
        exit 1
    fi

    if ! sudo systemctl restart docker; then
        echo "Failed to restart Docker service."
        exit 1
    fi

    # Enable and start Nginx
    if ! sudo systemctl enable nginx; then
        echo "Failed to enable Nginx service."
        exit 1
    fi

    if ! sudo systemctl restart nginx; then
        echo "Failed to restart Nginx service."
        exit 1
    fi
}

deploy(){
    # Ensure we are in the correct directory
    cd django-notes-app || exit
    if ! docker build -t notes-app .; then
        echo "Failed to build the Docker image."
        exit 1
    fi
    if ! docker run -d -p 8000:8000 notes-app; then
        echo "Failed to run the Docker container."
        exit 1
    fi
}

echo "********** DEPLOYMENT STARTED **********"

if ! code_clone; then
    echo "Code clone failed."
    exit 1
fi

if ! install_requirements; then
    echo "Installation of requirements failed."
    exit 1
fi

if ! required_restart; then
    echo "Service restart failed."
    exit 1
fi

if ! deploy; then
    echo "Deployment failed, mail the admin"
    # sendmail
    exit 1
fi

echo "********** DEPLOYMENT DONE **********"