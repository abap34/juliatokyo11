SRC_DIR = slides
BUILD_DIR = build
SRC_FILES = $(wildcard $(SRC_DIR)/*[0-9]_*.md)
OUTPUT_FILE = $(BUILD_DIR)/slide.md
MARPRC_FILE = .marprc.yml

all: clean compile pdf html

compile: $(OUTPUT_FILE)
	@echo "Compiling slides..."

$(OUTPUT_FILE): $(SRC_FILES)
	@mkdir -p $(BUILD_DIR)
	@echo "Clone theme..."
	@git clone https://github.com/abap34/honwaka-theme
	@mv honwaka-theme $(BUILD_DIR)/
	@echo "Creating slide file..."
	@cat $(SRC_DIR)/header.md > $(OUTPUT_FILE)
	@echo "N_SECTION = $(words $(SRC_FILES))"
	@for file in $(SRC_FILES); do \
		echo "### section: $$file"; \
		tail -n +7 "$$file" >> $(OUTPUT_FILE); \
	done

pdf: compile
	@echo "Creating PDF..."
	@marp $(OUTPUT_FILE) --config-file $(MARPRC_FILE) --output $(BUILD_DIR)/slide.pdf

html: compile
	@echo "Creating HTML..."
	@marp $(OUTPUT_FILE) --config-file $(MARPRC_FILE) --output $(BUILD_DIR)/slide.html

preview: compile
	@echo "Previewing slides..."
	@marp $(OUTPUT_FILE) --config-file $(MARPRC_FILE) --preview

clean:
	@echo "Cleaning up..."
	@rm -rf $(BUILD_DIR)
	@rm -rf honwaka-theme

.PHONY: all compile pdf html preview clean
