# DeliusCatalogueOfWorks
This repository contains the extra files needed to publish a working MerMEId instance for the **Delius Catalogue of Works**. You will need a copy of the Edirom version of MerMEId and a server with Docker installed. The instructions below assume an Apache server, but there are no specialised requirements for the main web server, with most URL rewriting done from within Docker.

## Steps to install:

  1. Create and run the **Docker** instance
    1. Copy `project` folder into the MerMEId directory
    1. Either overwrite `foo/bar` with the copy in `foo` or edit the Dockerfile to point to the new version
    1. Build and run the docker image
  1. Copy `delius-catalogue.conf` into the `sites_available` directory (or equivalent), editing as necessary
  1. Copy the Incipits directory into `/var/www/html/` or equivalent (assuming that http.conf already points there)
  1. Copy letsencrypt certificates into `/etc/letsencrypt`
  1. Create `systemd` process for running Docker on startup

   
