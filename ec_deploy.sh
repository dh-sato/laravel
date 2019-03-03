#!/bin/bash
DEPLOY_PATH="/home/webapp/laravelsample"

cd ${DEPLOY_PATH} || exit 99

sudo cp -p /home/webapp/.test-env .env
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# 必要なディレクトリを作成
sudo mkdir -p ./shared
sudo mkdir -p "./releases/${TIMESTAMP}"

# 作業ディレクトリにデプロイ
sudo ln -nfs "${DEPLOY_PATH}/releases/${TIMESTAMP}" ./release
sudo cp -arf /home/webapp/laravelsample_source/* ./release/

sudo chown -R nginx:nginx ${DEPLOY_PATH}
sudo chmod 2775 ${DEPLOY_PATH}
sudo find ${DEPLOY_PATH} -type d -exec sudo chmod 2775 {} +
sudo find ${DEPLOY_PATH} -type f -exec sudo chmod 0664 {} +

# デプロイ対象外ファイルを用意
if [ ! -d ./shared/storage ]; then
  sudo cp -arf ./release/storage ./shared/
  sudo chmod 777 -R ./shared/storage
fi

sudo chmod 777 -R ./release/vendor

cd ./release || exit 99

# デプロイ対象外ファイルをシンボリックリンク化
sudo rm -f .env
sudo ln -nfs ${DEPLOY_PATH}/.env ./.env
sudo chown -h nginx ./.env
sudo rm -rf ./storage
sudo ln -nfs ${DEPLOY_PATH}/shared/storage ./storage
sudo chown -h nginx ./storage

# 各種コマンド実施
composer install
composer dump-autoload

php artisan key:generate
php artisan storage:link
php artisan optimize:clear

yarn install
yarn build

cd ../ || exit 99

# デプロイ実施
sudo ln -nfs "${DEPLOY_PATH}/releases/${TIMESTAMP}" ./current
sudo unlink ./release

sudo systemctl restart php-fpm.service
sudo systemctl restart nginx.service
