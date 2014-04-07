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
        page = self.get_tabs().select_single(ProjectsPage)
        page.main_view = self
        return page

    def get_walkthrough(self):
        page = self.select_single(InitialWalkthrough)
        page.main_view = self
        return page
    
    def get_input_dialog(self):
        return self.wait_select_single(InputDialog)

class ProjectsPage(toolkit_emulators.UbuntuUIToolkitEmulatorBase):
    def get_new_project_dialog(self):
        pass
    
    def get_projects_count(self):
        return len(self.select_many(toolkit_emulators.SingleValue))
    
    def get_action_popover(self):
        return self.select_single(toolkit_emulators.ActionSelectionPopover)

class InitialWalkthrough(toolkit_emulators.UbuntuUIToolkitEmulatorBase):
        pass

class SettingsPage(toolkit_emulators.UbuntuUIToolkitEmulatorBase):
    pass

class ConfirmDialog(toolkit_emulators.UbuntuUIToolkitEmulatorBase):
    """ConfirmDialog Autopilot emulator."""

    def __init__(self, *args):
        super(ConfirmDialog, self).__init__(*args)
        self.pointing_device = toolkit_emulators.get_pointing_device()

    def ok(self):
        okButton = self.select_single('Button', objectName='okButton')
        self.pointing_device.click_object(okButton)

    def cancel(self):
        cancel_button = self.select_single('Button', objectName='cancelButton')
        self.pointing_device.click_object(cancel_button)

class InputDialog(ConfirmDialog):
    """ConfirmDialogWithInput Autopilot emulator."""

    def __init__(self, *args):
        super(InputDialog, self).__init__(*args)
        self.textfield = self.select_single(toolkit_emulators.TextField)

    def enter_text(self, text, clear=True):
        self.textfield.write(text, clear)

    def clear_text(self):
        self.textfield.clear()
