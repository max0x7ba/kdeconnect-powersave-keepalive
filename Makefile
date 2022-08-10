# Copyright (c) 2022 Maxim Egorushkin. MIT License. See the full licence in file LICENSE.

SHELL := /bin/bash

kdeconnectd := /usr/lib/x86_64-linux-gnu/libexec/kdeconnectd
$(if $(shell test -f ${kdeconnectd} && echo yes),,$(error ${kdeconnectd} is not found))
$(if $(shell type -f patchelf),,$(error Install patchelf with "sudo apt-get --yes install patchelf"))
$(if $(shell type -f readelf),,$(error Install readelf with "sudo apt-get --yes install binutils"))

BUILD := release
TOOLSET := gcc
build_dir := ${BUILD}/${TOOLSET}

cxx.gcc := g++
ld.gcc := g++
ar.gcc := gcc-ar

cxx.clang := clang++
ld.clang := clang++
ar.clang := ar

CXX := ${cxx.${TOOLSET}}
LD := ${ld.${TOOLSET}}
AR := $(or ${ar.${TOOLSET}},ar)

cxxflags.gcc.debug := -Og -fstack-protector-all # -D_GLIBCXX_DEBUG
cxxflags.gcc.release := -Os -DNDEBUG
cxxflags.gcc := -pthread -m{arch,tune}=native -W{all,extra,error} -g -fmessage-length=0 ${cxxflags.gcc.${BUILD}}

cxxflags.clang.debug := -Og -fstack-protector-all
cxxflags.clang.release := -Os -DNDEBUG
cxxflags.clang := -std=stdlibc++ -pthread -m{arch,tune}=native -W{all,extra,error} -g -fmessage-length=0 ${cxxflags.clang.${BUILD}}
ldflags.clang := ${ldflags.clang.${BUILD}}

# Additional CPPFLAGS, CXXFLAGS, LDLIBS, LDFLAGS can come from the command line, e.g. make CXXFLAGS='-march=skylake -mtune=skylake'.
# However, a clean build is required when changing the flags in the command line.
cxxflags := ${cxxflags.${TOOLSET}} ${CXXFLAGS}
cppflags := ${CPPFLAGS}
ldflags := -pthread -g ${ldflags.${TOOLSET}} ${LDFLAGS}
ldlibs := ${LDLIBS}

compile.cxx = ${CXX} -o $@ -c ${cppflags} ${cxxflags} -MD -MP $<
link.exe = ${LD} -o $@ $(ldflags) $(filter-out Makefile,$^) $(ldlibs)
link.so = ${LD} -o $@ -shared $(ldflags) $(filter-out Makefile,$^) $(ldlibs)
link.a = ${AR} rscT $@ $(filter-out Makefile,$^)

all : run_test

${build_dir}/force_tcp_keepalive_seconds_min.so : cxxflags += -fno-exceptions
${build_dir}/force_tcp_keepalive_seconds_min.so : ldlibs += -ldl
${build_dir}/force_tcp_keepalive_seconds_min.so : ${build_dir}/force_tcp_keepalive_seconds_min.o
-include ${build_dir}/force_tcp_keepalive_seconds_min.d

${build_dir}/test : ${build_dir}/test.o
	$(strip ${link.exe})
-include ${build_dir}/test.d

${build_dir}/test2 : ${build_dir}/test ${build_dir}/force_tcp_keepalive_seconds_min.so
	cp -f $< $@
	patchelf --add-needed ${build_dir}/force_tcp_keepalive_seconds_min.so $@

run_test : ${build_dir}/test ${build_dir}/test2
	${build_dir}/test | grep -qFxe "new TCP_KEEPIDLE 1"
	FORCE_TCP_KEEPALIVE_SECONDS_MIN=2 ${build_dir}/test2 | grep -qFxe "new TCP_KEEPIDLE 2"

patch := $(dir ${kdeconnectd})force_tcp_keepalive_seconds_min.so

${patch} : ${build_dir}/force_tcp_keepalive_seconds_min.so
	cp -f $< $@

${kdeconnectd}.original :
	cp -n --preserve=all ${kdeconnectd} $@

${kdeconnectd} : ${patch} | ${kdeconnectd}.original
	while pgrep kdeconnectd; do pkill kdeconnectd; sleep 1; done
	cp -f --preserve=all ${kdeconnectd}.original $@
	patchelf --add-needed ${patch} $@
	@echo "KDE Connect was terminated and patched. Start it again, please."

install : ${kdeconnectd}

uninstall :
	while pgrep kdeconnectd; do pkill kdeconnectd; sleep 1; done
	patchelf --remove-needed ${patch} ${kdeconnectd}
	rm -f ${patch}
	@echo "KDE Connect was terminated and unpatched. Start it again, please."

status :
	@grep -qFe ${patch} <(readelf -d ${kdeconnectd}) && echo "KDE Connect patch is installed." || echo "KDE Connect patch is not installed."

${build_dir} :
	mkdir -p $@

${build_dir}/%.so : cxxflags += -fPIC
${build_dir}/%.so : Makefile | ${build_dir}
	$(strip ${link.so})

${build_dir}/%.a : Makefile | ${build_dir}
	$(strip ${link.a})

${build_dir}/%.o : %.cc Makefile | ${build_dir}
	$(strip ${compile.cxx})

rtags : clean
	${MAKE} -nk all | rtags-rc -c -; :

clean :
	rm -rf ${build_dir}

%.d:;
%.cc:;
Makefile:;
.SUFFIXES:
.PHONY: clean all rtags run_test install uninstall status
