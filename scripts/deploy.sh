#!/bin/bash

# Variables
BUILD_DIR=$(pwd)
txtred=$(tput setaf 1) # Red
txtgrn=$(tput setaf 2) # Green
txtylw=$(tput setaf 3) # Yellow
txtblu=$(tput setaf 4) # Blue
txtpur=$(tput setaf 5) # Purple
txtcyn=$(tput setaf 6) # Cyan
txtwht=$(tput setaf 7) # White
txtrst=$(tput sgr0) # Text reset.

COMMIT_MESSAGE="$(git show --name-only --decorate)"
PANTHEON_ENV="dev"
TEST_URL=""

cd $HOME

# If the Pantheon directory does not exist
if [ ! -d "$HOME/pantheon" ]
then
  # Clone the Pantheon repo
  echo -e "\n${txtylw}Cloning Pantheon repository into $HOME/pantheon  ${txtrst}"
  git clone $PANTHEON_GIT_URL pantheon
fi

cd pantheon
git fetch

# Log into terminus.
echo -e "\n${txtylw}Logging into Terminus ${txtrst}"
terminus auth:login --machine-token=$PANTHEON_MACHINE_TOKEN

# Check if we are NOT on the master branch
if [ $CIRCLE_BRANCH != "master" ]
then

  # Branch name can't be more than 11 characters
  # Normalize branch name to adhere with Multidev requirements
  export normalize_branch="$CIRCLE_BRANCH"
  export valid="^[-0-9a-z]" # allows digits 0-9, lower case a-z, and -
  # If the branch name is invalid
    if [[ $normalize_branch =~ $valid ]]
    then
    export normalize_branch="${normalize_branch:0:11}"
    # Attempt to normalize it
    export normalize_branch="${normalize_branch//[-_]}"
    echo "Success: "$normalize_branch" is a valid branch name."
    else
      # Otherwise exit
    echo "Error: Multidev cannot be created due to invalid branch name: $normalize_branch"
    exit 1
  fi

  # Update the environment variable
  PANTHEON_ENV="${normalize_branch}"

  echo -e "\n${txtylw}Checking for the multidev environment ${normalize_branch} via Terminus ${txtrst}"

  # Get a list of all environments
  PANTHEON_ENVS="$(terminus multidev:list $PANTHEON_SITE_UUID --format=list --field=Name)"
  terminus multidev:list $PANTHEON_SITE_UUID --fields=Name

  MULTIDEV_FOUND=0

  while read -r line; do
      if [[ "${line}" == "${normalize_branch}" ]]
      then
        MULTIDEV_FOUND=1
      fi
  done <<< "$PANTHEON_ENVS"

  # If the multidev for this branch is found
  if [[ "$MULTIDEV_FOUND" -eq 1 ]]
  then
    # Send a message
    echo -e "\n${txtylw}Multidev found! ${txtrst}"
  else
    # otherwise, create the multidev branch
    echo -e "\n${txtylw}Multidev not found, creating the multidev branch ${normalize_branch} via Terminus ${txtrst}"
    terminus multidev:create $PANTHEON_SITE_UUID.dev $normalize_branch
    git fetch
  fi

  # Checkout the correct branch
  GIT_BRANCHES="git show-ref --verify refs/heads/$normalize_branch"
  if [[ ${GIT_BRANCHES} == *"${normalize_branch}"* ]]
  then
    echo -e "\n${txtylw}Branch ${normalize_branch} found, checking it out ${txtrst}"
      git checkout $normalize_branch
    else
      echo -e "\n${txtylw}Branch ${normalize_branch} not found, creating it ${txtrst}"
    git checkout -b $normalize_branch
    fi
fi

# Delete the web and vendor subdirectories if they exist
if [ -d "$HOME/pantheon/web" ]
then
  # Remove it without folder sites.
  echo -e "\n${txtylw}Removing $HOME/pantheon/web ${txtrst}"
  find web/* -maxdepth 1 -type 'f' delete
  find web/* -maxdepth 1 -type 'd' | grep -v "sites" | xargs rm -rf
fi
if [ -d "$HOME/pantheon/vendor" ]
then
  # Remove it
  echo -e "\n${txtylw}Removing $HOME/pantheon/vendor ${txtrst}"
  rm -rf $HOME/pantheon/vendor
fi

mkdir -p web
mkdir -p vendor

echo -e "\n${txtylw}Rsyncing $BUILD_DIR/web ${txtrst}"
rsync -a $BUILD_DIR/web/* ./web/

echo -e "\n${txtylw}Copying $BUILD_DIR/pantheon.yml ${txtrst}"
cp $BUILD_DIR/pantheon.yml .

echo -e "\n${txtylw}Rsyncing $BUILD_DIR/vendor ${txtrst}"
rsync -a $BUILD_DIR/vendor/* ./vendor/

echo -e "\n${txtylw}Rsyncing $BUILD_DIR/config ${txtrst}"
rsync -a $BUILD_DIR/config/* ./config/

echo -e "\n${txtylw}Forcibly adding all files and committing${txtrst}"
git add -A --force .
git commit -m "Circle CI build $CIRCLE_BUILD_NUM by $CIRCLE_PROJECT_USERNAME" -m "$COMMIT_MESSAGE"

# Force push to Pantheon
if [ $CIRCLE_BRANCH != "master" ]
then
  echo -e "\n${txtgrn}Pushing the ${normalize_branch} branch to Pantheon ${txtrst}"
  git push -u origin $normalize_branch --force
else
  echo -e "\n${txtgrn}Pushing the master branch to Pantheon ${txtrst}"
  git push -u origin master --force
fi

# Send status to PR.
if [ $CIRCLE_BRANCH != "master" ]
then
  PANTHEON_ENVS_NAME="$(terminus site:info $PANTHEON_SITE_UUID --format=string --field=name)"
  TEST_URL="$(terminus multidev:list $PANTHEON_SITE_UUID --format=string --field=domain | grep $normalize_branch-$PANTHEON_ENVS_NAME)"
  curl -H "Authorization: token ${GIT_TOKEN}" --request POST --data '{"state": "success", "description": "Url Env", "target_url": "http://'$TEST_URL'"}' https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/statuses/$CIRCLE_SHA1
fi
