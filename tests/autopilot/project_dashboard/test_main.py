# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-

"""Tests for the Hello World"""

#import os

#from autopilot.matchers import Eventually
#from testtools.matchers import Equals
from testtools.matchers import NotEquals

import project_dashboard
import project_dashboard.emulators


class MainViewTestCase(project_dashboard.ClickAppTestCase):
    """Tests for Project Dashboard"""

    def test_initial_page(self):
        page = self.main_view.get_projects_page()
        self.assertThat(page, NotEquals(None))

    def test_create_project(self):
        page = self.main_view.get_projects_page()
        button = self.main_view.select_single(objectName='createProject')
        self.pointing_device.click_object(button)
        self.assertThat(page, NotEquals(None))

    #def test_click_button_should_update_label(self):
     #   button = self.main_view.select_single(objectName='button')
      #  self.pointing_device.click_object(button)
       # label = self.main_view.select_single(objectName='label')
        #self.assertThat(label.text, Eventually(Equals('..world!')))
