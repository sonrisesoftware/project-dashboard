# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-

"""Tests for the Hello World"""

#import os

from autopilot.matchers import Eventually
from testtools.matchers import Equals
from testtools.matchers import NotEquals

import project_dashboard
import project_dashboard.emulators

import time

from ubuntuuitoolkit import emulators as toolkit_emulators


class ProjectsPageTestCase(project_dashboard.ClickAppTestCase):
    """Tests for Project Dashboard"""

    def setUp(self):
        super(ProjectsPageTestCase, self).setUp()
        self.assertThat(
            self.main_view.visible, Eventually(Equals(True)))
        page = self.main_view.get_walkthrough()
        self.assertThat(page, NotEquals(None))
        skipButton = page.select_single(objectName='skipButton')
        self.pointing_device.click_object(skipButton)
        self.wait_until_not_exists(self.main_view, project_dashboard.
                                   emulators.InitialWalkthrough)

    def test_initial_page(self):
        self.assertThat(self.main_view.get_tabs().selectedTabIndex, Equals(0))

    def test_create_project(self):
        page = self.main_view.get_projects_page()
        self.assertThat(page.get_projects_count(), Equals(0))
        self.create_project("Sample Project")

    def test_delete_project(self):
        self.create_project("Project 1")
        self.main_view.get_toolbar().click_back_button()
        self.delete_project(0)

    def create_project(self, name):
        page = self.main_view.get_projects_page()
        count = page.get_projects_count()

        self.main_view.get_toolbar().click_button('createProject')

        dialog = self.main_view.get_input_dialog()
        dialog.enter_text(name)
        dialog.ok()

        self.assertThat(page.get_projects_count, Eventually(Equals(count+1)))

    def delete_project(self, index):
        page = self.main_view.get_projects_page()
        count = page.get_projects_count()
        listItem = page.select_many(toolkit_emulators.SingleValue)[0]
        self.long_press(listItem)
        menu = page.get_action_popover()
        menu.click_button_by_text('Delete')
        self.assertThat(page.get_projects_count, Eventually(Equals(count-1)))

    def wait_until_not_exists(self, obj, type='*', **kargs):
        self.assertThat(lambda: exists(obj, type, **kargs),
                        Eventually(Equals(False)))

    def long_press(self, obj):
        self.pointing_device.move_to_object(obj)
        self.pointing_device.press()
        time.sleep(1)
        self.pointing_device.release()


def exists(obj, type='*', **kargs):
    return len(obj.select_many(type, **kargs)) > 0
