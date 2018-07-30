# EXCLUDE_FROM_SOURCE="_build,_grisp,config,_elixir_build"
 # see : https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=898744
 # https://www.gnu.org/software/make/manual/html_node/MAKE-Variable.html#MAKE-Variable
 # https://www.gnu.org/software/make/manual/html_node/Options_002fRecursion.html#Options_002fRecursion
 # https://www.gnu.org/software/make/manual/html_node/Instead-of-Execution.html#Instead-of-Execution
 # http://erlang.org/pipermail/erlang-questions/2001-November/004120.html
 # https://www3.ntu.edu.sg/home/ehchua/programming/cpp/gcc_make.html
 # http://erlang.org/pipermail/erlang-questions/2002-January/004295.html
REBAR            ?= $(shell which rebar3)
# REVISION 		    ?= $(shell git rev-parse --short HEAD)
GRISPAPP         ?= $(shell basename `find src -name "*.app.src"` .app.src)
BASE_DIR         ?= $(shell pwd)
CACHE_DIR         ?= $(HOME)/.cache/rebar3
# ERLANG_BIN       ?= $(shell dirname $(shell which erl))
# HOSTNAME         ?= $(shell hostname)
COOKIE           ?= MyCookie
VERSION 	       ?= 0.1.0
# MAKE						 = make
#
# .PHONY: grispbuild rel deps plots dcos logs fpm no-cfg-build tarball-build \
# 	build compile-no-deps test docs xref dialyzer-run dialyzer-quick dialyzer \
# 	cleanplt upload-docs wipeout clean cacheclean rebar3
# EXCLUDE=$(subst src/bar.cpp,,${SRC_FILES})
# SRC_FILES = $(filter-out $(wildcard ./_*))

# .PHONY: grispbuild rel deps test plots dcos logs fpm no-cfg-build tarball-build build

.PHONY: compile shell deploy rel stage \
	# cleaning targets :
	clean buildclean grispclean cacheclean elixirclean checkoutsclean ⁠\
	# currently not working targets :
	build no-cfg-build tarball-build

all: compile

##
## Compilation targets
##


compile:
	$(REBAR) compile

# rebar3_grisp build call to sh(./otp_build boot -a) forces single directory change that make cannot overwrite
# open issue?
build:
	$(REBAR) grisp build

no-cfg-build:
	$(REBAR) grisp build -c false

tarball-build:
	$(REBAR) grisp build -t true

#
# Cleaning targets
#

clean: buildclean grispclean elixirclean checkoutsclean cacheclean
	$(REBAR) clean
	$(REBAR) update
	$(REBAR) unlock
	$(REBAR) upgrade

buildclean:
	rm -rdf $(BASE_DIR)/_build

grispclean:
	rm -rdf $(BASE_DIR)/_grisp

elixirclean:
	$(foreach var,$(shell find $(BASE_DIR)/elixir_libs/ -type d -name "_build"),rm -rdf $(var);)
	rm -rdf $(BASE_DIR)/_elixir_build

cacheclean:
	rm -rdf $(CACHE_DIR)/hex
	rm -rdf $(CACHE_DIR)/plugins/rebar3_grisp
checkoutsclean:
	rm -rdf $(BASE_DIR)/_checkouts/*/ebin/*
#
# Test targets
#

shell:
	$(REBAR) as test shell --sname $(GRISPAPP) --setcookie $(COOKIE)


##
## Release targets
##

rel:
	$(REBAR) release

stage:
	$(REBAR) release -d

deploy:
	$(REBAR) grisp deploy -n $(GRISPAPP) -v $(VERSION)

include tools.mk
