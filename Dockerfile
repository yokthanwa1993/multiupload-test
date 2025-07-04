# Use an official PHP image with Apache, which is well-suited for this project.
# Force rebuild: 2025-07-04-04:26:00
FROM php:8.1-apache

# Install system dependencies required for PHP extensions
RUN apt-get update && apt-get install -y \
    libonig-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure and install required PHP extensions for the project.
# mbstring is used for handling multi-byte strings (e.g., in YouTube titles).
# fileinfo is used by mime_content_type to detect file types.
# gd is needed for image manipulation, which might be useful for thumbnails.
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install mbstring fileinfo gd curl

# Copy custom PHP configuration to increase upload limits
COPY uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# Copy all application files from the current directory to the web server's root directory in the container.
COPY . /var/www/html/

# Create directories and grant the web server user (www-data) write permissions to the 'uploads' and 'credentials' directories.
# This is crucial so that the application can save uploaded files and access tokens.
# Updated: 2025-07-04 to fix permission issues in CapRover deployment
RUN mkdir -p /var/www/html/uploads && \
    mkdir -p /var/www/html/credentials && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 777 /var/www/html/uploads && \
    chmod -R 777 /var/www/html/credentials

# The apache server in the base image is already configured to expose port 80, which CapRover will use. 