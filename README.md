Project Dashboard
=================

[![Build Status](https://travis-ci.org/iBeliever/project-dashboard.png?branch=master)](https://travis-ci.org/iBeliever/project-dashboard)

Manage everything about your projects in one app

Developed by Michael Spencer

### Setting up and Running ###

Project Dashboard requires a repository of mine called Ubuntu UI Extras, which must be available in the root directory of the repository. You can either clone it from the project's root directory or if you have my very helpful [devutils](http://github.com/iBeliever/devutils) project in your `$PATH `, you can simply run:

    code use ubuntu-ui-extras
    
I do continue to improve the `ubuntu-ui-extras` repository, so make sure you update it, either by using `git pull` if you manually cloned it, or if you used `devutils`, you can run:

    code update ubuntu-ui-extras

### Installing on Ubuntu 14.04 ###

Project Dashboard is hosted on a PPA for Ubuntu 14.04 through which one can install and receive updates on the desktop.

```
sudo apt-get add-apt-repository ppa:ubuntu-touch-community-dev/ppa
sudo apt-get update
sudo apt-get install project-dashboard
```

### Bugs in the Ubuntu SDK that affect Project Dashboard ###

[LP #1208833](https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1208833) - The pointer on the popover that opens for the sync item isn't correctly positioned when the app's width is too small.

[LP #1304034](https://bugs.launchpad.net/ubuntu/+source/unity-scope-click/+bug/1304034) - App data is not saved when quitting the app from the Apps scope since onDestruction() isn't called when closing from the Apps scope.

### Licensing ###

Project Dashboard is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
