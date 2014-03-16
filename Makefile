# More information: https://wiki.ubuntu.com/Touch/Testing
#
# Notes for autopilot tests:
# -----------------------------------------------------------
# In order to run autopilot tests:
# sudo apt-add-repository ppa:autopilot/ppa
# sudo apt-get update
# sudo apt-get install python-autopilot autopilot-qt
#############################################################

all:

autopilot:
	chmod +x tests/autopilot/run
	tests/autopilot/run

check:
	time qmltestrunner -input tests/unit

python_check:
	pep8 tests/autopilot/project_dashboard/
	pyflakes tests/autopilot/project_dashboard/

run:
	/usr/bin/qmlscene $@ project-dashboard.qml

clean:
	rm ~/.local/share/com.ubuntu.developer.mdspencer.project-dashboard/ -R

backup: 
	cp ~/.local/share/com.ubuntu.developer.mdspencer.project-dashboard/*.db .

restore:
	cp *.db ~/.local/share/com.ubuntu.developer.mdspencer.project-dashboard/
