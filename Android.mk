LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := trace-cmd
LOCAL_C_INCLUDES := $(TARGET_OUT_INTERMEDIATES)/include/trace_cmd

LOCAL_SHARED_LIBRARIES := libdl

LOCAL_GENERATED_SOURCES := $(TARGET_OUT_INTERMEDIATES)/include/trace_cmd/tc_version.h
LOCAL_CFLAGS := -Wall -std=gnu99 -fPIC -DPIC -rdynamic

# trace-cmd version
TC_VERSION = 2
TC_PATCHLEVEL = 4
TC_EXTRAVERSION = 0

# we're not building GUI, so this is the only set we care about
# for compatibility, keep both definitions
VERSION = $(TC_VERSION)
PATCHLEVEL = $(TC_PATCHLEVEL)
EXTRAVERSION = $(TC_EXTRAVERSION)

# file format version
FILE_VERSION = 6

define make_version.h
	(echo '/* This file is automatically generated. Do not modify. */';		\
	echo \#define VERSION_CODE $(shell						\
	expr $(VERSION) \* 256 + $(PATCHLEVEL));					\
	echo '#define EXTRAVERSION ' $(EXTRAVERSION);					\
	echo '#define VERSION_STRING "'$(VERSION).$(PATCHLEVEL).$(EXTRAVERSION)'"';	\
	echo '#define FILE_VERSION '$(FILE_VERSION);					\
	) > $1
endef

define update_version.h
	($(call make_version.h, $@.tmp);		\
	if [ -r $@ ] && cmp -s $@ $@.tmp; then		\
		rm -f $@.tmp;				\
	else						\
		echo '  UPDATE                 $@';	\
		mv -f $@.tmp $@;			\
	fi);
endef

.PHONY: force
force:

$(TARGET_OUT_INTERMEDIATES)/include/trace_cmd/tc_version.h: $(TARGET_OUT_INTERMEDIATES)/include/trace_cmd force
	$(call update_version.h)

$(TARGET_OUT_INTERMEDIATES)/include/trace_cmd: force
	mkdir -p $@

# sorce code ot trace parser library
libparse_SRC_FILES = \
	event-parse.c \
	trace-seq.c \
	parse-filter.c \
	parse-utils.c

# sorce code ot trace-cmd library
libtrace_SRC_FILES = \
	$(libparse_SRC_FILES) \
	trace-util.c \
	trace-input.c \
	trace-ftrace.c \
	trace-output.c \
	trace-recorder.c \
	trace-restore.c \
	trace-usage.c \
	trace-blk-hack.c \
	kbuffer-parse.c \
	event-plugin.c

# sorce code ot trace-cmd
trace_SRC_FILES = \
	$(libtrace_SRC_FILES) \
	trace-cmd.c \
	trace-record.c \
	trace-read.c \
	trace-split.c \
	trace-listen.c \
	trace-stack.c \
	trace-hist.c \
	trace-mem.c \
	trace-snapshot.c


ifeq ($(WITH_PLUGINS),y)

# each plugin must be a shared abject;
# plugins build is not yet ready

PLUGIN_OBJS =
PLUGIN_OBJS += plugin_jbd2.c
PLUGIN_OBJS += plugin_hrtimer.c
PLUGIN_OBJS += plugin_kmem.c
PLUGIN_OBJS += plugin_kvm.c
PLUGIN_OBJS += plugin_mac80211.c
PLUGIN_OBJS += plugin_sched_switch.c
PLUGIN_OBJS += plugin_function.c
PLUGIN_OBJS += plugin_xen.c
PLUGIN_OBJS += plugin_scsi.c
PLUGIN_OBJS += plugin_cfg80211.c
PLUGIN_OBJS += plugin_blk.c

LOCAL_SRC_FILES += $(PLUGIN_OBJS)

endif

# extra dependency: glob.c is not part of Bionic as of KK
LOCAL_SRC_FILES = \
	$(trace_SRC_FILES) \
	glob.c

include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)

LOCAL_MODULE := trace-cmd
LOCAL_C_INCLUDES := $(HOST_OUT_INTERMEDIATES)/include/trace_cmd

$(HOST_OUT_INTERMEDIATES)/include/trace_cmd/tc_version.h: $(HOST_OUT_INTERMEDIATES)/include/trace_cmd force
	$(call update_version.h)

$(HOST_OUT_INTERMEDIATES)/include/trace_cmd: force
	mkdir -p $@

LOCAL_CFLAGS := -O2 -g -Wall -Wno-unused-parameter
LOCAL_CFLAGS += -D_XOPEN_SOURCE -D_GNU_SOURCE

LOCAL_GENERATED_SOURCES := $(HOST_OUT_INTERMEDIATES)/include/trace_cmd/tc_version.h
LOCAL_LDLIBS += -lrt -ldl -lpthread

LOCAL_SRC_FILES = $(trace_SRC_FILES)

include $(BUILD_HOST_EXECUTABLE)
