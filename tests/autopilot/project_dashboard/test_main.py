# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-

"""Tests for the Hello World"""

#import os

from autopilot.matchers import Eventually
from testtools.matchers import Equals
from testtools.matchers import NotEquals

import project_dashboard
import project_dashboard.emulators


class MainViewTestCase(project_dashboard.ClickAppTestCase):
    """Tests for Project Dashboard"""

    def setUp(self):
        super(MainViewTestCase, self).setUp()
        self.assertThat(
                self.main_view.visible, Eventually(Equals(True)))
        page = self.main_view.get_walkthrough()
        self.assertThat(page, NotEquals(None))
        skipButton = page.select_single(objectName='skipButton')
        self.pointing_device.click_object(skipButton)
        self.wait_until_not_exists(self.main_view, project_dashboard.emulators.InitialWalkthrough)

    def test_initial_page(self):
        page = self.main_view.get_projects_page()
        self.assertThat(self.main_view.get_tabs().selectedTabIndex, Equals(0))

    def test_create_project(self):
        page = self.main_view.get_projects_page()
        self.assertThat(page.get_projects_count(), Equals(0))
        
        button = self.main_view.get_toolbar().click_button('createProject')
        
        dialog = self.main_view.get_input_dialog()
        dialog.enter_text("Sample Project")
        dialog.ok()
        
        self.assertThat(page.get_projects_count, Eventually(Equals(1)))


    def test_create_project(self):
        page = self.main_view.get_projects_page()
        self.assertThat(page.get_projects_count(), Equals(0))
        
        button = self.main_view.get_toolbar().click_button('createProject')
        
        dialog = self.main_view.get_input_dialog()
        dialog.enter_text("Sample Project")
        dialog.ok()
        
        self.assertThat(page.get_projects_count, Eventually(Equals(1)))

    def wait_until_not_exists(self, obj, type='*', **kargs):
        self.assertThat(lambda: exists(obj, type, **kargs), Eventually(Equals(False)))
    
def exists(obj, type='*', **kargs):
    return len(obj.select_many(type, **kargs)) > 0