.PHONY: all setup clean

# Name of the virtual environment directory
VENV := venv

# Path to the requirements file
REQUIREMENTS := requirements.txt

# Default target executed when no arguments are given to make
all: setup

# Target for setting up the project dependencies, including creating the virtual environment
setup:
	@test -d $(VENV) || python3 -m venv $(VENV)
	@$(VENV)/bin/pip install --upgrade pip
	@$(VENV)/bin/pip install -r $(REQUIREMENTS)

# Target for cleaning up the project
clean:
	rm -rf _pycache_
	rm -rf $(VENV)