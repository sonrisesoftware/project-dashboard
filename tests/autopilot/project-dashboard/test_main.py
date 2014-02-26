# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-

"""Tests for the Hello World"""

import os

from autopilot.matchers import Eventually
from testtools.matchers import Equals

import project-dashboard


class MainViewTestCase(project-dashboard.ClickAppTestCase):
    """Generic tests for the Hello World"""

    def test_initial_label(self):
        label = self.main_view.select_single(objectName='label')
        self.assertThat(label.text, Equals('Hello..'))

    def test_click_button_should_update_label(self):
        button = self.main_view.select_single(objectName='button')
        self.pointing_device.click_object(button)
        label = self.main_view.select_single(objectName='label')
        self.assertThat(label.text, Eventually(Equals('..world!')))
