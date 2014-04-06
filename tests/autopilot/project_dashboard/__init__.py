# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-

"""Ubuntu Touch App autopilot tests."""

# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2013 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Authored by: Renato Araujo Oliveira Filho <renato@canonical.com>


"""clock-app autopilot tests."""

import os.path
import os
import shutil
import logging

from autopilot import input
from autopilot.platform import model
from ubuntuuitoolkit import (
    base,
    emulators as toolkit_emulators
)

from project_dashboard import emulators

logger = logging.getLogger(__name__)


class ClickAppTestCase(base.UbuntuUIToolkitAppTestCase):

    """A common test case class that provides several useful methods for
    calendar-app tests.

    """
    local_location = "../../project-dashboard.qml"
    installed_location = "/usr/share/project-dashboard/project-dashboard.qml"
    sqlite_dir = os.path.expanduser(
        "~/.local/share/com.ubuntu.developer.mdspencer.project-dashboard")
    backup_dir = sqlite_dir + ".backup"

    def setUp(self):
        super(ClickAppTestCase, self).setUp()
        self.pointing_device = input.Pointer(self.input_device_class.create())

        #backup and wipe db's before testing
        self.temp_move_sqlite_db()
        self.addCleanup(self.restore_sqlite_db)

        #turn off the OSK so it doesn't block screen elements
        if model() != 'Desktop':
            os.system("stop maliit-server")
            # adding cleanup step seems to restart
            # service immediately; disabling for now
            # self.addCleanup(os.system("start maliit-server"))

        if os.path.exists(self.local_location):
            self.launch_test_local()
        elif os.path.exists(self.installed_location):
            self.launch_test_installed()
        else:
            self.launch_test_click()

    def launch_test_local(self):
        self.app = self.launch_test_application(
            base.get_qmlscene_launch_command(),
            self.local_location,
            app_type='qt',
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase)

    def launch_test_installed(self):
        self.app = self.launch_test_application(
            base.get_qmlscene_launch_command(),
            self.installed_location,
            "--desktop_file_hint=/usr/share/applications/"
            "project-dashboard.desktop",
            app_type='qt',
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase)

    def launch_test_click(self):
        self.app = self.launch_click_package(
            "com.ubuntu.clock",
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase)

    def temp_move_sqlite_db(self):
        try:
            shutil.rmtree(self.backup_dir)
        except:
            pass
        else:
            logger.warning("Prexisting backup database found and removed")

        try:
            shutil.move(self.sqlite_dir, self.backup_dir)
        except:
            logger.warning("No current database found")
        else:
            logger.debug("Backed up database")

    def restore_sqlite_db(self):
        if os.path.exists(self.backup_dir):
            if os.path.exists(self.sqlite_dir):
                try:
                    shutil.rmtree(self.sqlite_dir)
                except:
                    logger.error("Failed to remove test database and restore" /
                                 "database")
                    return
            try:
                shutil.move(self.backup_dir, self.sqlite_dir)
            except:
                logger.error("Failed to restore database")

    @property
    def main_view(self):
        return self.app.select_single(emulators.MainView)
