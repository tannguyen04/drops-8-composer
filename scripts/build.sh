#!/bin/bash

# generate styleguide from pattern lab
cd "web/themes/custom/${THEME_NAME}/pattern-lab"
M | composer install --no-dev
php core/console --generate
