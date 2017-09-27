.PHONY: all

ifndef PREFIX
$(error PREFIX is not set)
endif

CONFIG_DRIVES :=				\
	$(PREFIX)-vm-1-ds.iso			\
	$(PREFIX)-vm-2-ds.iso			\
	$(PREFIX)-vm-3-ds.iso			\
	$(PREFIX)-vm-4-ds.iso

IMAGE_DIR := /var/lib/libvirt/images

all: install

config: $(CONFIG_DRIVES)

%.iso: user-data meta-data create-config-drive Makefile
	@echo generating $@
	@./create-config-drive -h $(patsubst %-ds.iso,%,$@) -k ~/.ssh/id_rsa.pub -u user-data $@

install: $(patsubst %,$(IMAGE_DIR)/%,$(CONFIG_DRIVES))

$(IMAGE_DIR)/%.iso: %.iso
	sudo cp $< $@

clean:
	$(RM) $(CONFIG_DRIVES)

redo-net: remove-net
	virsh net-define $(PREFIX).xml
	virsh net-start $(PREFIX)

remove-net:
	-virsh net-undefine $(PREFIX)
	-virsh net-destroy $(PREFIX)
