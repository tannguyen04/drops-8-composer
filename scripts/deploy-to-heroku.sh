#!/bin/bash

# Variables
txtgrn=$(tput setaf 2) # Green
txtrst=$(tput sgr0) # Text reset.

COMMIT_MESSAGE="Deploy by $(git config --get user.name), $(git rev-parse --abbrev-ref HEAD) ($(git rev-parse --short HEAD))"

# If the Pantheon git directory does not exist.
if [ ! -d ".heroku" ]
then
  # Clone the Pantheon repoa
  echo -e "\n${txtgrn}Cloning Heroku repository ${txtrst}"
  heroku git:clone -a $HEROKU_APP_NAME ".heroku"
else
  echo -e "\n${txtgrn}Pull latest from Heroku ${txtrst}"
  git -C ".heroku" pull
fi

echo -e "\n${txtgrn}Applying new changes to Heroku repo ${txtrst}"
mkdir -p .heroku/public
mkdir -p .heroku/public/css
mkdir -p .heroku/public/fonts
mkdir -p .heroku/public/images
mkdir -p .heroku/public/js

rsync -a --delete "web/themes/custom/${THEME_NAME}/pattern-lab/public/" ".heroku/public/"
rsync -a "web/themes/custom/${THEME_NAME}/css/" ".heroku/public/css/"
rsync -a "web/themes/custom/${THEME_NAME}/fonts/" ".heroku/public/fonts/"
rsync -a "web/themes/custom/${THEME_NAME}/images/" ".heroku/public/images/"
rsync -a "web/themes/custom/${THEME_NAME}/js/" ".heroku/public/js/"

# Move into the heroku repo to apply changes.
cd .heroku
git add -A
git commit -m"$COMMIT_MESSAGE"

echo -e "\n${txtgrn}Pushing the master branch to Heroku ${txtrst}"
git push heroku master --force
