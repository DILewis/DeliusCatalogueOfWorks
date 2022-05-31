# DeliusCatalogueOfWorks
This repository contains the extra files needed to publish a working MerMEId instance for the **Delius Catalogue of Works**. You will need a copy of the Edirom version of MerMEId and a server with Docker installed. The instructions below assume an Apache server, but there are no specialised requirements for the main web server, with most URL rewriting done from within Docker.

This readme has the following sections:
 * [Steps to install](#steps-to-install)
 * [What's in this repo, and why?](#whats-in-this-repo-and-why)
 * [Overriding MerMEId XSLT](#overriding-mermeid-xslt)
 * [Keeping database files and customisations between MerMEId updates](#keeping-database-files-and-customisations-between-MerMEId-updates)
 * [Credits](#credits)

More details of the process of migrating from an old (Copenhagen, MEI 3) MerMEId to the new (Paderborn, MEI 4) one can be found in [this article](https://github.com/Edirom/MerMEId/wiki/Migrating-from-old-(kb-dk)-MerMEId-install-to-the-2021-dev-branch) on that repo's wiki. Some future work ideas are also in the Issue Tracker here.

## Steps to install:

  1. Create and run the **Docker** instance
     1. Copy `project` folder into the MerMEId directory
     1. Either overwrite MerMEId's `jetty-exist-additional-config/etc/webapp/WEB-INF/controller-config.xml` with the copy in `config-files` before installation, or copy the modified file directly into the built image
     1. Build the image (`docker build --tag dcw .`)
     1. Run the image (`docker run -d -p 6379:6379 -p 8080:8080 --restart unless-stopped --name DCW dcw`) 

  1. Copy `delius-catalogue.conf` into the `sites_available` directory (or equivalent), editing as necessary
  1. Copy the Incipits directory into `/var/www/html/` or equivalent (assuming that http.conf already points there)
  1. Copy letsencrypt certificates (not included in this repo for obvious reasons) into `/etc/letsencrypt`
  1. Create `systemd` process for running Docker on startup

Currently, since data is stored in `/project`, the MerMEId editor will not be able to access it. Pull Request [PR59][https://github.com/Edirom/MerMEId/pull/59] will  allow this if you change the `data-root` property in `properties.xml` to `/db/apps/mermeid/project/`. In future, we should also move this directory out of the mermeid directory to improve the upgrade path.

## What's in this repo, and why?
 * **Data files**. These are specific to the Delius Catalogue of Works (other projects may need something similar)
   * Catalogue files in `/project/data`. These are dynamically served by an embedded copy of eXist XML database in MerMEId. For projects that (like us) start with old data files, it is important to remember to convert MEI 3 to MEI 4 using the XSLT provided as part of the MerMEId repository.
   * Incipit score images in `/incipits/delius/`. These are statically served by the web server.

The latest versions of MerMEId include a powerful editing environment for works catalogues but (at the time of writing) no mechanism for publishing them as web pages. This is a regression from previous versions. To fill this gap, we have needed to add or modify a few things. In many cases, we are reinstating and updating code previously present in MerMEId.

 * **Web server configuration**. This is specific to the Delius Catalogue of Works (other projects may need something similar)
   * Apache configuration file in `/sites_available/DCW.conf` handles basic transfer of web traffic to the MerMEId server
 * **MerMEId web server configuration**. This is specific to the Delius Catalogue of Works. Other projects may need something similar, but we have discussed ways to generalise what is done here into the main MerMEId package
   * *eXist* configuration file `/config-files/controller-config.xml`. This altered version of the standard MerMEID file allows user-facing urls to be of the form `/foo/page.html` rather than `/foo/page.xq`. This reflects the form of the server response rather than the internal processes of the software generating that response (in principle making the urls more robust to technology change).
 * **Web site resources**. This is a combination of very Delius-specific and quite generic material needed for generating and serving the web pages
   * Static-served site resources in `/project/resources/[js|images|css` These are for the styling, images and functionality of pages
   * Page templates are in `/project/resources/html` (static templates) and `/project/resources/page_xq` (xquery templating). These two combine to provide the main structures and information management for the dynamic site. 
   * Additional project-related information (abbreviations, etc) is in `/project/resources/page_xml`. This overrides some general information
   * Rewritten MerMEId XSLT code in `/project/resources/mei_to_html_public.xsl`. These transforms are used in most of the page templates. They override functionality that is in core MerMEId. More information about this is in the next section (below).

## Overriding MerMEId XSLT
There is only a small difference between formatting catalogue data as HTML for MerMEId itself and doing so for published web catalogues. This means that it should be possible to share a lot of the XSLT that does the MEI-->HTML conversion.

Most of this functionality is provided by core MerMEID in `/db/apps/mermeid/style/mei_to_html.xsl`. Where different formatting is needed, we have updated what was `mermeid/style/mei_to_html_public.xsl` in older MerMEId versions. This imports the more general stylesheet, so any parts that need no specialisation for publishing public websites can simply be omitted.

Since the structure of the MEI header has changed in several important ways since previous versions of MerMEId, the xslt has had to be updated. Further work on this would be useful with two purposes:
 * **Testing**. The current XSLT seems to work on the Delius data, but it has not been substantially tested against other catalogue data
 * **Trimming**. The ideal would be for this file to be as small as possible, so that it tracks the main MerMEId closely, with the minimum of extra effort. To do this, a review of what is in here against what is in `mei_to_html.xsl` would be helpful and would probably shorten the file.

## Keeping database files and customisations between MerMEId updates

MerMEId now supports a separate directory (outside the docker container) that contains the eXist database on which the application is based. Updates to MerMEId would then not rewrite existing catalogue data. This functionality _can_ be used in the following way for DCW:
 1. Extract the database data from an existing container (in our case, `podman cp DCW:/exist/data database` (where `database` is the directory to put the database into.
 2. Get the latest image (`docker pull edirom/mermeid:develop-java11-ShenGC` at the time of writing)
 3. Run docker or podman with the database directory mounted (`docker run --name DCW-persist -p 8080:8080 -d --mount type=bind,source="$(pwd)/database",target=/exist/data edirom/mermeid:develop` is the command this was tested with)
 4. Extend httpd configuration to do some url rewriting (currently some path and extension remapping is done by a bespoke `controller-config.xml`, but this is overwritten in the new approach – this means that top-level paths will need to be passed to `/db/project` type paths, and `html` to `xq` in some contexts.


## Credits:

Catalogue data created and edited by **Joanna Bullivant** and **Daniel Grimley**

Incipits by **Timothy Coombes**, **Alexander Ho** and **Joanna Bullivant**

Web development by David Lewis

Thanks to: The British Library, the Delius Trust, the Danish Centre for Music Editing, the Oxford E-Research Centre, Helen Faulkner, Kevin Page, Andrew Hankinson, Daniel Hulme, Mario Baptiste, Amelie Roper, Richard Chesser, Axel Teich Geertinger, Sigfrid Lundberg, Peter Stadler, Omar Siam, Zsofia Abraham, Daniel Schopper, Clemens Gubsch

