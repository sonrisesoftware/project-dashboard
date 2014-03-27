Building and Uploading to PPA
=============================

It is quite simple to upload new versions of Project-dashboard to the PPA since the debian packaging is already implemented. The steps below illustrate how to publish a new update to the PPA.

_Note: You will need to ensure that your PGP key has already been uploaded to Launchpad. This only needs to be done once and will be used to sign the package that you upload to Launchpad._

### Step 1: Preparing the source folder ###

Clone the main project-dashboard repository and also its children repositories like ubuntu-ui-extras by,

```
git clone git@github.com:iBeliever/project-dashboard.git
cd project-dashboard
git clone git@github.com:iBeliever/ubuntu-ui-extras.git
```

Navigate into the ubuntu-ui-extras folder and remove the **.git**, **.gitignore** and the **COPYING** file, otherwise while building the deb package, debian will complain about a git repository being present in the ubuntu-ui-extras folder.

### Step 2: Update the changelog ###

While in the root folder, type

    dch

This will open the changelog in the terminal. Fill it with the changes in this new version. Also ensure that the release is set to trusty or other ubuntu version and finally set the version number to a unique number. If the PPA has version 0.2, then the update can be any other version like 0.2ubuntu1, 0.2.1, etc etc.

### Step 3: Build and test the .deb package ###

While in the root folder, building the debian package is a one line command,

    debuild -us -uc

This will build and create the debian package outside the root folder. Install the debian package using the **dpkg** command and check if it installed in your system properly.

### Step 4: Upload source to the PPA ###

While in the root folder execute the following command,

    debuild -S -sa

This will create a file project-dashboard_version_all.changes outside the root folder. We need to upload this file to the PPA. This can be done by,

    dput ppa:ubuntu-touch-community-dev/ppa project-dashboard_version_all.changes

