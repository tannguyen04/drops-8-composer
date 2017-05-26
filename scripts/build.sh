cd "web/themes/custom/${THEME_NAME}/pattern-lab"
M | composer install --no-dev
php core/console --generate
