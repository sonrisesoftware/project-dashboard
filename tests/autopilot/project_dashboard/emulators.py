# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2014 Michael Spencer
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

"""Project Dashboard autopilot emulators."""

#import re
#import time

#from autopilot import input
#from autopilot.introspection import dbus

from ubuntuuitoolkit import emulators as toolkit_emulators


class MainView(toolkit_emulators.MainView):

    def get_projects_page(self):
        page = self.wait_select_single(ProjectsPage)
        page.main_view = self
        return page


class ProjectsPage(toolkit_emulators.UbuntuUIToolkitEmulatorBase):
    def get_new_project_dialog(self):
        pass


class SettingsPage(toolkit_emulators.UbuntuUIToolkitEmulatorBase):
    pass
