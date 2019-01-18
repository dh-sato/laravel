#!/bin/bash
cp -p .env.example .env
php artisan key:generate

php artisan storage:link
php artisan view:clear
php artisan cache:clear
composer dump-autoload --optimize

chmod 777 -R ./storage
chmod 777 -R ./vender
chown -R nginx ./*

systemctl restart php-fpm.service
systemctl restart nginx.service
