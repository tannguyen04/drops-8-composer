# Advanced deployment workflow Drupal 8.

## Purpose
This repository is an example of an advanced deployment workflow on Hero integrating tools such as:
* Pattern-lab integration to custom theme.
* Dependency management with Composer
* Build process on Circle CI
* Deploy prototype generate from pattern lab in custom theme to heroko app

## Circle CI Setup
The following sensitive variables will need to be
stored in Circle CI as environment variables
* HEROKU_APP_NAME
    * The Heroku app name of the site to deploy to
* HEROKU_EMAIL
    * Email address of the account used to deployment with Heroko
* HEROKU_TOKEN
    * The API Key of the account used to deployment with Heroko
* THEME_NAME
    * The custom theme name will build prototype
* GIT_EMAIL
    * Email address of the account used to make Git commits to the Heroku repository
* GIT_USERNAME
    * Username of the account used to make Git commits to the Heroku repository
* GIT_TOKEN
    * A Github token with read access to the source repository

## Heroku app
```
public/
.gitignore
Procfile
composer.json
composer.lock
```
with content of `Procfile`
```
web: vendor/bin/heroku-php-apache2 public/
```

## See also
* [CircleCI](https://circleci.com/)
* [Getting Started with Python on Heroku](https://devcenter.heroku.com/articles/getting-started-with-python) and [Managing Multiple Environments for an App](https://devcenter.heroku.com/articles/multiple-environments) articles from the [Heroku Dev Center](https://devcenter.heroku.com/)
* [Continuous Deployment with Heroku](https://circleci.com/docs/continuous-deployment-with-heroku) from the CircleCI docs.
* [Heroku CLI Authentication](https://devcenter.heroku.com/articles/authentication)
