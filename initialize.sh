#!/bin/bash
DEPLOY_PATH="/home/webapp/laravelsample"

cd ${DEPLOY_PATH} || exit 99

sudo chown -R nginx:nginx ${DEPLOY_PATH}
sudo chmod 2775 ${DEPLOY_PATH}
sudo find ${DEPLOY_PATH} -type d -exec sudo chmod 2775 {} +
sudo find ${DEPLOY_PATH} -type f -exec sudo chmod 0664 {} +

cp -p .env.example .env

composer install
composer dump-autoload

php artisan key:generate
php artisan storage:link
php artisan optimize:clear

sudo chmod -R 777 ./storage
sudo chmod -R 777 ./vendor

sudo systemctl restart php-fpm.service
sudo systemctl restart nginx.service
