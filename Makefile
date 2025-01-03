# simple makefile to simplify repetitive build env management tasks under posix

PYTHON ?= python
VENV_DIR = .venv
DEFAULT_MESON_BUILD_DIR = build/cp$(shell $(PYTHON) -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor}")' )

all:
	@echo "Please use 'make <target>' where <target> is one of"
	@echo "  dev                  build scikit-learn with Meson"
	@echo "  clean                clean scikit-learn Meson build. Very rarely needed,"
	@echo "                       since meson-python recompiles on import."

.PHONY: all

$(VENV_DIR)/bin/activate: requirements.txt
	$(PYTHON) -m venv $(VENV_DIR)
	. $(VENV_DIR)/bin/activate && pip install --upgrade pip && pip install -r requirements.txt

dev: dev-meson

dev-meson: $(VENV_DIR)/bin/activate
	. $(VENV_DIR)/bin/activate && pip install --verbose --no-build-isolation --editable . --config-settings editable-verbose=true

clean: clean-meson

clean-meson:
	. $(VENV_DIR)/bin/activate && pip uninstall -y scikit-learn
	# It seems in some cases removing the folder avoids weird compilation
	# errors (e.g. when switching from numpy>=2 to numpy<2). For some
	# reason ninja clean -C $(DEFAULT_MESON_BUILD_DIR) is not
	# enough.
	rm -rf $(DEFAULT_MESON_BUILD_DIR)