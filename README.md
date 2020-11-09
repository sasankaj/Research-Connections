# Docker-based Drupal stack

[![Build Status](https://travis-ci.org/wodby/docker4drupal.svg?branch=master)](https://travis-ci.org/wodby/docker4drupal)

## Introduction

Docker4Drupal is a set of docker images optimized for Drupal. Use `docker-compose.yml` file from the [latest stable release](https://github.com/wodby/docker4drupal/releases) to spin up local environment on Linux, Mac OS X and Windows. 

* Read the docs on [**how to use**](https://wodby.com/docs/stacks/drupal/local#usage)
* Ask questions on [Slack](http://slack.wodby.com/)
* Follow [@wodbycloud](https://twitter.com/wodbycloud) for future announcements

## Stack
The Drupal stack consist of the following containers:

| Container       | Versions               | Service name    | Image                              | Default |
| --------------  | ---------------------- | --------------- | ---------------------------------- | ------- |
| [Nginx]         | 1.19, 1.18             | `nginx`         | [wodby/nginx]                      |        |
| [Apache]        | 2.4                    | `apache`        | [wodby/apache]                     | ✓        |
| [Drupal]        | 9, 8, 7                | `php`           | [wodby/drupal]                     | ✓       |
| [PHP]           | 7.4, 7.3, 7.2          | `php`           | [wodby/drupal-php]                 | ✓        |
| Crond           |                        | `crond`         | [wodby/drupal-php]                 | ✓       |
| [MariaDB]       | 10.5, 10.4, 10.3, 10.2 | `mariadb`       | [wodby/mariadb]                    | ✓       |
| [PostgreSQL]    | 12, 11, 10, 9.x        | `postgres`      | [wodby/postgres]                   |         |
| [Redis]         | 6, 5                   | `redis`         | [wodby/redis]                      |         |
| [Memcached]     | 1                      | `memcached`     | [wodby/memcached]                  |         |
| [Varnish]       | 6.0, 4.1               | `varnish`       | [wodby/varnish]                    |         |
| [Node.js]       | 14, 12, 10             | `node`          | [wodby/node]                       |         |
| [Drupal node]   | 1.0                    | `drupal-node`   | [wodby/drupal-node]                |         |
| [Solr]          | 8, 7, 6, 5             | `solr`          | [wodby/solr]                       |         |
| [Elasticsearch] | 7, 6                   | `elasticsearch` | [wodby/elasticsearch]              |         |
| [Kibana]        | 7, 6                   | `kibana`        | [wodby/kibana]                     |         |
| [OpenSMTPD]     | 6.0                    | `opensmtpd`     | [wodby/opensmtpd]                  |         |
| [Mailhog]       | latest                 | `mailhog`       | [mailhog/mailhog]                  | ✓       |
| [AthenaPDF]     | 2.10.0                 | `athenapdf`     | [arachnysdocker/athenapdf-service] |         |
| [Rsyslog]       | latest                 | `rsyslog`       | [wodby/rsyslog]                    |         |
| [Blackfire]     | latest                 | `blackfire`     | [blackfire/blackfire]              |         |
| [Webgrind]      | 1                      | `webgrind`      | [wodby/webgrind]                   |         |
| [Xhprof viewer] | latest                 | `xhprof`        | [wodby/xhprof]                     |         |
| Adminer         | 4.6                    | `adminer`       | [wodby/adminer]                    |         |
| phpMyAdmin      | latest                 | `pma`           | [phpmyadmin/phpmyadmin]            |         |
| Selenium chrome | 3.141                  | `chrome`        | [selenium/standalone-chrome]       |         |
| Portainer       | latest                 | `portainer`     | [portainer/portainer]              | ✓       |
| Traefik         | latest                 | `traefik`       | [_/traefik]                        | ✓       |

Supported Drupal versions: 9 / 8 / 7


## Domains
The services currently enabled on the site are:

| Service name  | Domain URL                                      | Status    |
| ------------- | ----------------------------------------------- | --------- |
| nginx/apache  | http://researchconnections.docker.localhost:8080            | Active    |
| solr          | http://solr.researchconnections.docker.localhost:8080       | Active    |
| portainer     | http://portainer.researchconnections.docker.localhost:8080  | Active    |
| mailhog       | http://mailhog.researchconnections.docker.localhost:8080    | Active    |
| pma           | http://pma.researchconnections.docker.localhost:8080        | Active    |
| adminer       | http://adminer.researchconnections.docker.localhost:8080    | Disabled  |
| nodejs        | http://nodejs.researchconnections.docker.localhost:8080     | Disabled  |
| node          | http://front.researchconnections.docker.localhost:8080      | Disabled  |
| varnish       | http://varnish.researchconnections.docker.localhost:8080    | Disabled  |
| webgrind      | http://webgrind.researchconnections.docker.localhost:8080   | Disabled  |

**Note:** To enable any additional service, please update your docker-compose.yml file.


## First Time setup

To get this project running on your machine, use the following instructions

Clone this repository to your local machine into the directory Research-Connections
```
git clone git@github.com:sasankaj/Research-Connections.git Research-Connections
```

Download the drupal settings file for local development from [here](https://icfonline.sharepoint.com/sites/ResearchConnections16/Shared%20Documents/General/Development/Local%20Dev/Local%20Settings/settings.local.php). and place it into the /web/sites/default/ directory of your project. 


Download the local services.yml file for local development (twig debug) from [here](https://icfonline.sharepoint.com/sites/ResearchConnections16/Shared%20Documents/General/Development/Local%20Dev/Local%20Settings/local.services.yml). and place it into the /web/sites/ directory of your project. 


Intiialize docker containers
```
make up
```

Install all project dependencies
```
make composer install
```

Import the latest database backup.
```
docker-compose exec mariadb sh -c 'exec mysql -u root -p"password" drupal9_rc < /docker-entrypoint-initdb.d/rc9-db-backup.sql'
```

Import the latest configuration files into the site
```
make shell php
drush cim -v
exit
```

Clear drupal site cache
```
make drush cr
```


## Database import and export

Exporting all databases:

```
docker-compose exec mariadb sh -c 'exec mysqldump --all-databases -uroot -p"password"' > alldatabases.sql
```

Exporting your Drupal database:

```
docker-compose exec mariadb sh -c 'exec mysqldump -uroot -p"root-password" drupal9_rc' > rc9-db-backup.sql
```

Importing a database:

```
docker-compose exec mariadb sh -c 'exec mysql -u root -p"password" drupal9_rc < /docker-entrypoint-initdb.d/rc9-db-backup.sql'
```


## Exporting new configuration items

1. Login to the php containers shell
2. export your configuration
3. Exit from the php shell

```
make shell php

drush cex -v

exit
```


## Importing new configuration files into your local environment
1. Login to the php containers shell
2. Import all configurations 
3. Exit from the php shell

```
make shell php

drush cim -v

exit
```



## Committing your local changes to Git
Once you are done working on your local code/configuration changes, please test your code against the coding standards by running the phpcs command referenced below.

When you are ready to commit your changes and you have add your changes to the staging area, your commit message should satisfy the following requirements:

```
> Contain the project prefix (RC9) followed by a hyphen
> Contain a ticket number followed by a colon and a space
> Be at least 15 characters long and end with a period.
> Valid example: RC9-2409: Updated behat configuration.
```

The commit message is enfored using a commit hook, and you will not be able to commit your changes until the commit message is in the right format.

**Note**:\
Git hooks are not pushed or pulled, as they are not part of the repository code.
To enable the commit hook for your local environment, please download the commit hook from [here](https://icfonline.sharepoint.com/sites/ResearchConnections16/Shared%20Documents/General/Development/Local%20Dev/git%20hooks/commit-msg). and place it into the .git/hooks directory of your project. Then make sure the newly added hook has 755 permissions (-rwxr-xr-x)

```
chmod 755 .git/hooks/commit-msg
```


## Solr

Access a running Solr container via `make shell solr` or `docker-compose exec solr sh`

Creating a core

```
make create core=[core name] -f /usr/local/bin/actions.mk
```

Reload solr core

You can reload the core from the Solr admin dashboard or by executing the following orchestration action from the container with running Solr:

```
make reload core=[core name] -f /usr/local/bin/actions.mk
```


## PHP CodeSniffer
PHP CodeSniffer (phpcs) tokenizes PHP, JavaScript and CSS files to detect and fix violations of a defined set of coding standards.
Before you commit your changes, you can check your code for coding standards violations by running the following command:

```
docker-compose exec -T php phpcs "path/to/your/code/files"
```


## IDE configuration
You must additionally configure your IDE to debug CLI requests.

PHPStorm
1. Open `Run > Edit Configurations` from the main menu, choose `Defaults > PHP Web Page` in the left sidebar
2. Click to `[...]` to the right of Server and add a new server
   - Enter name `my-ide` (as specified in `PHP_IDE_CONFIG` of your docker-compose.yml)
   - Enter any host, it does not matter
   - Check `Use path mappings`, select path to your project and enter `/var/www/html` in the right column (Absolute path on the server)
3. Choose newly created server in "Server" for PHP Web Page
4. Save settings


## Crond

Crond enabled by default and runs every hour. The default command is:

```
drush -r /var/www/html/web cron
```


## Additional Documentation

Full documentation is available at https://wodby.com/docs/stacks/drupal/local.


## Images' tags

Images tags format is `[VERSION]-[STABILITY_TAG]` where:

`[VERSION]` is the _version of an application_ (without patch version) running in a container, e.g. `wodby/nginx:1.15-x.x.x` where Nginx version is `1.15` and `x.x.x` is a stability tag. For some images we include both major and minor version like PHP `7.2`, for others we include only major like Redis `5`. 

`[STABILITY_TAG]` is the _version of an image_ that corresponds to a git tag of the image repository, e.g. `wodby/mariadb:10.2-3.3.8` has MariaDB `10.2` and stability tag [`3.3.8`](https://github.com/wodby/mariadb/releases/tag/3.3.8). New stability tags include patch updates for applications and image's fixes/improvements (new env vars, orchestration actions fixes, etc). Stability tag changes described in the corresponding a git tag description. Stability tags follow [semantic versioning](https://semver.org/).

We highly encourage to use images only with stability tags.


## Maintenance

We regularly update images used in this stack and release them together, see [releases page](https://github.com/wodby/docker4drupal/releases) for full changelog and update instructions. Most of routine updates for images and this project performed by [the bot](https://github.com/wodbot) via scripts located at [wodby/images](https://github.com/wodby/images).


## Beyond local environment

Docker4Drupal is a project designed to help you spin up local environment with docker-compose. If you want to deploy a consistent stack with orchestrations to your own server, check out [Drupal stack](https://wodby.com/stacks/drupal) on Wodby ![](https://www.google.com/s2/favicons?domain=wodby.com).


## Other Docker4x projects

* [docker4php](https://github.com/wodby/docker4php)
* [docker4wordpress](https://github.com/wodby/docker4wordpress)
* [docker4ruby](https://github.com/wodby/docker4ruby)
* [docker4python](https://github.com/wodby/docker4python)


## License

This project is licensed under the MIT open source license.

[Apache]: https://wodby.com/docs/stacks/drupal/containers#apache
[AthenaPDF]: https://wodby.com/docs/stacks/drupal/containers#athenapdf
[Blackfire]: https://wodby.com/docs/stacks/drupal/containers#blackfire
[Drupal node]: https://wodby.com/docs/stacks/drupal/containers#drupal-nodejs
[Drupal]: https://wodby.com/docs/stacks/drupal/containers#php
[Elasticsearch]: https://wodby.com/docs/stacks/elasticsearch
[Kibana]: https://wodby.com/docs/stacks/elasticsearch
[Mailhog]: https://wodby.com/docs/stacks/drupal/containers#mailhog
[MariaDB]: https://wodby.com/docs/stacks/drupal/containers#mariadb
[Memcached]: https://wodby.com/docs/stacks/drupal/containers#memcached
[Nginx]: https://wodby.com/docs/stacks/drupal/containers#nginx
[Node.js]: https://wodby.com/docs/stacks/drupal/containers#nodejs
[OpenSMTPD]: https://wodby.com/docs/stacks/drupal/containers#opensmtpd
[PHP]: https://wodby.com/docs/stacks/drupal/containers#php
[PostgreSQL]: https://wodby.com/docs/stacks/drupal/containers#postgresql
[Redis]: https://wodby.com/docs/stacks/drupal/containers#redis
[Rsyslog]: https://wodby.com/docs/stacks/drupal/containers#rsyslog
[Solr]: https://wodby.com/docs/stacks/drupal/containers#solr
[Varnish]: https://wodby.com/docs/stacks/drupal/containers#varnish
[Webgrind]: https://wodby.com/docs/stacks/drupal/containers#webgrind
[XHProf viewer]: https://wodby.com/docs/stacks/php/containers#xhprof-viewer

[_/traefik]: https://hub.docker.com/_/traefik
[arachnysdocker/athenapdf-service]: https://hub.docker.com/r/arachnysdocker/athenapdf-service
[blackfire/blackfire]: https://hub.docker.com/r/blackfire/blackfire
[mailhog/mailhog]: https://hub.docker.com/r/mailhog/mailhog
[phpmyadmin/phpmyadmin]: https://hub.docker.com/r/phpmyadmin/phpmyadmin
[portainer/portainer]: https://hub.docker.com/r/portainer/portainer
[selenium/standalone-chrome]: https://hub.docker.com/r/selenium/standalone-chrome
[wodby/adminer]: https://hub.docker.com/r/wodby/adminer
[wodby/apache]: https://github.com/wodby/apache
[wodby/drupal-node]: https://github.com/wodby/drupal-node
[wodby/drupal-php]: https://github.com/wodby/drupal-php
[wodby/drupal]: https://github.com/wodby/drupal
[wodby/elasticsearch]: https://github.com/wodby/elasticsearch
[wodby/kibana]: https://github.com/wodby/kibana
[wodby/mariadb]: https://github.com/wodby/mariadb
[wodby/memcached]: https://github.com/wodby/memcached
[wodby/nginx]: https://github.com/wodby/nginx
[wodby/node]: https://github.com/wodby/node
[wodby/opensmtpd]: https://github.com/wodby/opensmtpd
[wodby/postgres]: https://github.com/wodby/postgres
[wodby/redis]: https://github.com/wodby/redis
[wodby/rsyslog]: https://hub.docker.com/r/wodby/rsyslog
[wodby/solr]: https://github.com/wodby/solr
[wodby/varnish]: https://github.com/wodby/varnish
[wodby/webgrind]: https://hub.docker.com/r/wodby/webgrind
[wodby/xhprof]: https://hub.docker.com/r/wodby/xhprof
