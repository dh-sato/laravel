#!/bin/bash
DEPLOY_PATH="/home/webapp/laravelsample"

cd ${DEPLOY_PATH} || exit 99

TIMESTAMP=$(date +%Y%m%d%H%M%S)

# 必要なディレクトリを作成
mkdir -p ./shared
mkdir -p "./releases/${TIMESTAMP}"


# 作業ディレクトリにデプロイ
ln -nfs "${DEPLOY_PATH}/releases/${TIMESTAMP}" ./release
cp -arf /home/webapp/laravelsample_source/* ./release/

cp -p .env.example .env

chown -R nginx:nginx ${DEPLOY_PATH}
chmod 2775 ${DEPLOY_PATH}
find ${DEPLOY_PATH} -type d -exec sudo chmod 2775 {} +
find ${DEPLOY_PATH} -type f -exec sudo chmod 0664 {} +

# デプロイ対象外ファイルを用意
if [ ! -d ./shared/storage ]; then
  cp -arf ./release/storage ./shared/
  chmod 777 -R ./shared/storage
fi

chmod 777 -R ./shared/vendor

# 各種コマンド実施
composer install
composer dump-autoload

php artisan key:generate
php artisan storage:link
php artisan optimize:clear

yarn install
yarn build

# デプロイ対象外ファイルをシンボリックリンク化
rm -f .env
ln -nfs ${DEPLOY_PATH}/.env ./.env
chown -h nginx ./.env
rm -rf ./storage
ln -nfs ${DEPLOY_PATH}/shared/storage ./storage

chown -h nginx ./storage

cd ../ || exit 99

# デプロイ実施
ln -nfs "${DEPLOY_PATH}/releases/${TIMESTAMP}" ./current
unlink ./release

systemctl restart php-fpm.service
systemctl restart nginx.service

cd ./release || exit 99
