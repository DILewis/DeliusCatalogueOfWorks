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

## Credits:

Catalogue data created and edited by **Joanna Bullivant** and **Daniel Grimley**

Incipits by **Timothy Coombes**, **Alexander Ho** and **Joanna Bullivant**

Web development by David Lewis

Thanks to: The British Library, the Delius Trust, the Danish Centre for Music Editing, the Oxford E-Research Centre, Helen Faulkner, Kevin Page, Andrew Hankinson, Daniel Hulme, Mario Baptiste, Amelie Roper, Richard Chesser, Axel Teich Geertinger, Sigfrid Lundberg, Peter Stadler, Omar Siam, Zsofia Abraham, Daniel Schopper, Clemens Gubsch

