# Advanced deployment workflow Drupal 8.

## Purpose
This repository is an advanced deployment workflow on Pantheon integrating tools such as:
* composer.
* Dependency management with Composer
* Build process on Circle CI
* Deploy prototype generate from pattern lab in custom theme to heroko app

## Circle CI Setup
The following sensitive variables will need to be stored in Circle CI as environment variables
* GIT_EMAIL
    * Email address of the account used to make Git commits to the Heroku repository
* GIT_USERNAME
    * Username of the account used to make Git commits to the Heroku repository
* GIT_TOKEN
    * A Github token with read access to the source repository

## See also
* [CircleCI](https://circleci.com/)
