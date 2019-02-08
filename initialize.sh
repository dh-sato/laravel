#!/bin/bash
deploy_path="/home/webapp/laravelsample"

cd ${deploy_path} || exit 99

cp -p .env.example .env
php artisan key:generate

php artisan storage:link
php artisan view:clear
php artisan cache:clear

chmod -R 777 ./storage
chmod -R 777 ./vendor
chown -R nginx. ./*

systemctl restart php-fpm.service
systemctl restart nginx.service
