bin: $(PROGRAM) $(WPROGRAM)
lib: $(LIBRUBY)
dll: $(LIBRUBY_SO)

.SUFFIXES: .inc

RUBYOPT       =

STATIC_RUBY   = static-ruby

EXTCONF       = extconf.rb
RBCONFIG      = ./.rbconfig.time
LIBRUBY_EXTS  = ./.libruby-with-ext.time
RDOCOUT       = $(EXTOUT)/rdoc

DMYEXT	      = dmyext.$(OBJEXT)
NORMALMAINOBJ = main.$(OBJEXT)
MAINOBJ       = $(NORMALMAINOBJ)
EXTOBJS	      = 
DLDOBJS	      = $(DMYEXT)

COMMONOBJS    = array.$(OBJEXT) \
		bignum.$(OBJEXT) \
		class.$(OBJEXT) \
		compar.$(OBJEXT) \
		dir.$(OBJEXT) \
		encoding.$(OBJEXT) \
		enum.$(OBJEXT) \
		enumerator.$(OBJEXT) \
		error.$(OBJEXT) \
		eval.$(OBJEXT) \
		load.$(OBJEXT) \
		proc.$(OBJEXT) \
		file.$(OBJEXT) \
		gc.$(OBJEXT) \
		hash.$(OBJEXT) \
		inits.$(OBJEXT) \
		io.$(OBJEXT) \
		marshal.$(OBJEXT) \
		math.$(OBJEXT) \
		numeric.$(OBJEXT) \
		object.$(OBJEXT) \
		pack.$(OBJEXT) \
		parse.$(OBJEXT) \
		process.$(OBJEXT) \
		prec.$(OBJEXT) \
		random.$(OBJEXT) \
		range.$(OBJEXT) \
		re.$(OBJEXT) \
		regcomp.$(OBJEXT) \
		regenc.$(OBJEXT) \
		regerror.$(OBJEXT) \
		regexec.$(OBJEXT) \
		regparse.$(OBJEXT) \
		regsyntax.$(OBJEXT) \
		ruby.$(OBJEXT) \
		signal.$(OBJEXT) \
		sprintf.$(OBJEXT) \
		st.$(OBJEXT) \
		string.$(OBJEXT) \
		struct.$(OBJEXT) \
		time.$(OBJEXT) \
		transcode.$(OBJEXT) \
		util.$(OBJEXT) \
		variable.$(OBJEXT) \
		version.$(OBJEXT) \
		blockinlining.$(OBJEXT) \
		compile.$(OBJEXT) \
		debug.$(OBJEXT) \
		iseq.$(OBJEXT) \
		vm.$(OBJEXT) \
		vm_dump.$(OBJEXT) \
		thread.$(OBJEXT) \
		cont.$(OBJEXT) \
		id.$(OBJEXT) \
		$(BUILTIN_ENCOBJS) \
		$(MISSING)

OBJS          = dln.$(OBJEXT) \
		prelude.$(OBJEXT) \
		$(COMMONOBJS)

GOLFOBJS      = goruby.$(OBJEXT) golf_prelude.$(OBJEXT)

SCRIPT_ARGS   =	--dest-dir="$(DESTDIR)" \
		--extout="$(EXTOUT)" \
		--make="$(MAKE)" \
		--mflags="$(MFLAGS)" \
		--make-flags="$(MAKEFLAGS)"
EXTMK_ARGS    =	$(SCRIPT_ARGS) --extension $(EXTS) --extstatic $(EXTSTATIC) --
INSTRUBY_ARGS =	$(SCRIPT_ARGS) --installed-list $(INSTALLED_LIST)

PRE_LIBRUBY_UPDATE = $(MINIRUBY) -e 'ARGV[1] or File.unlink(ARGV[0]) rescue nil' -- \
			$(LIBRUBY_EXTS) $(LIBRUBY_SO_UPDATE)

TESTSDIR      = $(srcdir)/test
TESTWORKDIR   = testwork

BOOTSTRAPRUBY = $(BASERUBY)

all: $(MKFILES) $(PREP) $(RBCONFIG) $(LIBRUBY) encs
	@$(MINIRUBY) $(srcdir)/ext/extmk.rb $(EXTMK_ARGS)
prog: $(PROGRAM) $(WPROGRAM)

miniruby$(EXEEXT): config.status $(NORMALMAINOBJ) $(MINIOBJS) $(COMMONOBJS) $(DMYEXT) $(ARCHFILE)

GORUBY = go$(RUBY_INSTALL_NAME)
golf: $(LIBRUBY) $(GOLFOBJS)
	$(MAKE) $(MFLAGS) MAINOBJ="$(GOLFOBJS)" PROGRAM=$(GORUBY)$(EXEEXT) program

program: $(PROGRAM)

$(PROGRAM): $(LIBRUBY) $(MAINOBJ) $(OBJS) $(EXTOBJS) $(SETUP) $(PREP)

$(LIBRUBY_A):	$(OBJS) $(DMYEXT) $(ARCHFILE)

$(LIBRUBY_SO):	$(OBJS) $(DLDOBJS) $(LIBRUBY_A) $(PREP) $(LIBRUBY_SO_UPDATE)

$(LIBRUBY_EXTS):
	@exit > $@

$(STATIC_RUBY)$(EXEEXT): $(MAINOBJ) $(DLDOBJS) $(EXTOBJS) $(LIBRUBY_A)
	@$(RM) $@
	$(PURIFY) $(CC) $(MAINOBJ) $(DLDOBJS) $(EXTOBJS) $(LIBRUBY_A) $(MAINLIBS) $(EXTLIBS) $(LIBS) $(OUTFLAG)$@ $(LDFLAGS) $(XLDFLAGS)

ruby.imp: $(COMMONOBJS)
	@$(NM) -Pgp $(COMMONOBJS) | awk 'BEGIN{print "#!"}; $$2~/^[BD]$$/{print $$1}' | sort -u -o $@

install: install-nodoc $(RDOCTARGET)
install-all: install-nodoc install-doc

install-nodoc: pre-install-nodoc do-install-nodoc post-install-nodoc
pre-install-nodoc:: pre-install-local pre-install-ext
do-install-nodoc: 
	$(MINIRUBY) $(srcdir)/instruby.rb $(INSTRUBY_ARGS) --mantype="$(MANTYPE)"
post-install-nodoc:: post-install-local post-install-ext

install-local: pre-install-local do-install-local post-install-local
pre-install-local:: pre-install-bin pre-install-lib pre-install-man
do-install-local:
	$(MINIRUBY) $(srcdir)/instruby.rb $(INSTRUBY_ARGS) --install=local --mantype="$(MANTYPE)"
post-install-local:: post-install-bin post-install-lib post-install-man

install-ext: pre-install-ext do-install-ext post-install-ext
pre-install-ext:: pre-install-ext-arch pre-install-ext-comm
do-install-ext:
	$(MINIRUBY) $(srcdir)/instruby.rb $(INSTRUBY_ARGS) --install=ext
post-install-ext:: post-install-ext-arch post-install-ext-comm

install-arch: pre-install-arch do-install-arch post-install-arch
pre-install-arch:: pre-install-bin pre-install-ext-arch
do-install-arch:
	$(MINIRUBY) $(srcdir)/instruby.rb $(INSTRUBY_ARGS) --install=bin --install=ext-arch
post-install-arch:: post-install-bin post-install-ext-arch

install-comm: pre-install-comm do-install-comm post-install-comm
pre-install-comm:: pre-install-lib pre-install-ext-comm pre-install-man
do-install-comm:
	$(MINIRUBY) $(srcdir)/instruby.rb $(INSTRUBY_ARGS) --install=lib --install=ext-comm --install=man
post-install-comm:: post-install-lib post-install-ext-comm post-install-man

install-bin: pre-install-bin do-install-bin post-install-bin
pre-install-bin:: install-prereq
do-install-bin:
	$(MINIRUBY) $(srcdir)/instruby.rb $(INSTRUBY_ARGS) --install=bin
post-install-bin::
	@$(NULLCMD)

install-lib: pre-install-lib do-install-lib post-install-lib
pre-install-lib:: install-prereq
do-install-lib:
	$(MINIRUBY) $(srcdir)/instruby.rb $(INSTRUBY_ARGS) --install=lib
post-install-lib::
	@$(NULLCMD)

install-ext-comm: pre-install-ext-comm do-install-ext-comm post-install-ext-comm
pre-install-ext-comm:: install-prereq
do-install-ext-comm:
	$(MINIRUBY) $(srcdir)/instruby.rb $(INSTRUBY_ARGS) --install=ext-comm
post-install-ext-comm::
	@$(NULLCMD)

install-ext-arch: pre-install-ext-arch do-install-ext-arch post-install-ext-arch
pre-install-ext-arch:: install-prereq
do-install-ext-arch:
	$(MINIRUBY) $(srcdir)/instruby.rb $(INSTRUBY_ARGS) --install=ext-arch
post-install-ext-arch::
	@$(NULLCMD)

install-man: pre-install-man do-install-man post-install-man
pre-install-man:: install-prereq
do-install-man:
	$(MINIRUBY) $(srcdir)/instruby.rb $(INSTRUBY_ARGS) --install=man --mantype="$(MANTYPE)"
post-install-man::
	@$(NULLCMD)

what-where: no-install
no-install: no-install-nodoc no-install-doc
what-where-all: no-install-all
no-install-all: no-install-nodoc

what-where-nodoc: no-install-nodoc
no-install-nodoc: pre-no-install-nodoc dont-install-nodoc post-no-install-nodoc
pre-no-install-nodoc:: pre-no-install-local pre-no-install-ext
dont-install-nodoc: 
	$(MINIRUBY) $(srcdir)/instruby.rb -n $(INSTRUBY_ARGS) --mantype="$(MANTYPE)"
post-no-install-nodoc:: post-no-install-local post-no-install-ext

what-where-local: no-install-local
no-install-local: pre-no-install-local dont-install-local post-no-install-local
pre-no-install-local:: pre-no-install-bin pre-no-install-lib pre-no-install-man
dont-install-local:
	$(MINIRUBY) $(srcdir)/instruby.rb -n $(INSTRUBY_ARGS) --install=local --mantype="$(MANTYPE)"
post-no-install-local:: post-no-install-bin post-no-install-lib post-no-install-man

what-where-ext: no-install-ext
no-install-ext: pre-no-install-ext dont-install-ext post-no-install-ext
pre-no-install-ext:: pre-no-install-ext-arch pre-no-install-ext-comm
dont-install-ext:
	$(MINIRUBY) $(srcdir)/instruby.rb -n $(INSTRUBY_ARGS) --install=ext
post-no-install-ext:: post-no-install-ext-arch post-no-install-ext-comm

what-where-arch: no-install-arch
no-install-arch: pre-no-install-arch dont-install-arch post-no-install-arch
pre-no-install-arch:: pre-no-install-bin pre-no-install-ext-arch
dont-install-arch:
	$(MINIRUBY) $(srcdir)/instruby.rb -n $(INSTRUBY_ARGS) --install=bin --install=ext-arch
post-no-install-arch:: post-no-install-lib post-no-install-man post-no-install-ext-arch

what-where-comm: no-install-comm
no-install-comm: pre-no-install-comm dont-install-comm post-no-install-comm
pre-no-install-comm:: pre-no-install-lib pre-no-install-ext-comm pre-no-install-man
dont-install-comm:
	$(MINIRUBY) $(srcdir)/instruby.rb -n $(INSTRUBY_ARGS) --install=lib --install=ext-comm --install=man
post-no-install-comm:: post-no-install-lib post-no-install-ext-comm post-no-install-man

what-where-bin: no-install-bin
no-install-bin: pre-no-install-bin dont-install-bin post-no-install-bin
pre-no-install-bin:: install-prereq
dont-install-bin:
	$(MINIRUBY) $(srcdir)/instruby.rb -n $(INSTRUBY_ARGS) --install=bin
post-no-install-bin::
	@$(NULLCMD)

what-where-lib: no-install-lib
no-install-lib: pre-no-install-lib dont-install-lib post-no-install-lib
pre-no-install-lib:: install-prereq
dont-install-lib:
	$(MINIRUBY) $(srcdir)/instruby.rb -n $(INSTRUBY_ARGS) --install=lib
post-no-install-lib::
	@$(NULLCMD)

what-where-ext-comm: no-install-ext-comm
no-install-ext-comm: pre-no-install-ext-comm dont-install-ext-comm post-no-install-ext-comm
pre-no-install-ext-comm:: install-prereq
dont-install-ext-comm:
	$(MINIRUBY) $(srcdir)/instruby.rb -n $(INSTRUBY_ARGS) --install=ext-comm
post-no-install-ext-comm::
	@$(NULLCMD)

what-where-ext-arch: no-install-ext-arch
no-install-ext-arch: pre-no-install-ext-arch dont-install-ext-arch post-no-install-ext-arch
pre-no-install-ext-arch:: install-prereq
dont-install-ext-arch:
	$(MINIRUBY) $(srcdir)/instruby.rb -n $(INSTRUBY_ARGS) --install=ext-arch
post-no-install-ext-arch::
	@$(NULLCMD)

what-where-man: no-install-man
no-install-man: pre-no-install-man dont-install-man post-no-install-man
pre-no-install-man:: install-prereq
dont-install-man:
	$(MINIRUBY) $(srcdir)/instruby.rb -n $(INSTRUBY_ARGS) --install=man --mantype="$(MANTYPE)"
post-no-install-man::
	@$(NULLCMD)

install-doc: rdoc pre-install-doc do-install-doc post-install-doc
pre-install-doc:: install-prereq
do-install-doc: $(PROGRAM)
	$(MINIRUBY) $(srcdir)/instruby.rb $(INSTRUBY_ARGS) --install=rdoc --rdoc-output="$(RDOCOUT)"
post-install-doc::
	@$(NULLCMD)

rdoc: $(PROGRAM) PHONY
	@echo Generating RDoc documentation
	$(RUNRUBY) "$(srcdir)/bin/rdoc" --all --ri --op "$(RDOCOUT)" "$(srcdir)"

what-where-doc: no-install-doc
no-install-doc: pre-no-install-doc dont-install-doc post-no-install-doc
pre-no-install-doc:: install-prereq
dont-install-doc::
	$(MINIRUBY) $(srcdir)/instruby.rb -n $(INSTRUBY_ARGS) --install=rdoc --rdoc-output="$(RDOCOUT)"
post-no-install-doc::
	@$(NULLCMD)

CLEAR_INSTALLED_LIST = clear-installed-list

install-prereq: $(CLEAR_INSTALLED_LIST)

clear-installed-list:
	@exit > $(INSTALLED_LIST)

clean: clean-ext clean-local clean-enc
clean-local::
	@$(RM) $(OBJS) $(MINIOBJS) $(MAINOBJ) $(WINMAINOBJ) $(LIBRUBY_A) $(LIBRUBY_SO) $(LIBRUBY) $(LIBRUBY_ALIASES)
	@$(RM) $(PROGRAM) $(WPROGRAM) miniruby$(EXEEXT) dmyext.$(OBJEXT) $(ARCHFILE) .*.time
	@$(RM) *.inc $(GOLFOBJS)
clean-ext:
	@-$(MINIRUBY) $(srcdir)/ext/extmk.rb $(EXTMK_ARGS) clean
clean-enc:
	@-$(MAKE) -f enc.mk $(MFLAGS) clean

distclean: distclean-ext distclean-local distclean-enc
distclean-local:: clean-local
	@$(RM) $(MKFILES) config.h rbconfig.rb yasmdata.rb encdb.h
	@$(RM) config.cache config.log config.status config.status.lineno $(PRELUDES)
	@$(RM) *~ *.bak *.stackdump core *.core gmon.out y.tab.c y.output $(PREP)
distclean-ext:
	@-$(MINIRUBY) $(srcdir)/ext/extmk.rb $(EXTMK_ARGS) distclean
#	-$(RM) $(INSTALLED_LIST) $(arch_hdrdir)/ruby/config.h
#	-rmdir -p $(arch_hdrdir)/ruby
distclean-enc: clean-enc
	@-$(MAKE) -f enc.mk $(MFLAGS) distclean

realclean:: realclean-ext realclean-local realclean-enc
realclean-local:: distclean-local
	@$(RM) parse.c lex.c revision.h
realclean-ext::
	@-$(MINIRUBY) $(srcdir)/ext/extmk.rb $(EXTMK_ARGS) realclean
realclean-enc:: distclean-enc

check: test test-all

btest: miniruby$(EXEEXT) PHONY
	$(BOOTSTRAPRUBY) "$(srcdir)/bootstraptest/runner.rb" --ruby="$(MINIRUBY)" $(OPTS)

btest-miniruby: miniruby$(EXEEXT) $(RBCONFIG) $(PROGRAM) PHONY
	@$(MINIRUBY) "$(srcdir)/bootstraptest/runner.rb" --ruby="$(MINIRUBY)" -q

test-sample: miniruby$(EXEEXT) $(RBCONFIG) $(PROGRAM) PHONY
	@$(MINIRUBY) $(srcdir)/rubytest.rb

test: test-sample btest-miniruby

test-all:
	$(RUNRUBY) "$(srcdir)/test/runner.rb" --basedir="$(TESTSDIR)" --runner=$(TESTUI) $(TESTS)

extconf:
	$(MINIRUBY) -run -e mkdir -- -p "$(EXTCONFDIR)"
	$(RUNRUBY) -C "$(EXTCONFDIR)" $(EXTCONF) $(EXTCONFARGS)

$(RBCONFIG): $(srcdir)/mkconfig.rb config.status $(PREP)
	@$(MINIRUBY) $(srcdir)/mkconfig.rb -timestamp=$@ \
		-install_name=$(RUBY_INSTALL_NAME) \
		-so_name=$(RUBY_SO_NAME) rbconfig.rb

encs: enc.mk
	$(MINIRUBY) -run -e mkdir -- -p "$(EXTOUT)/$(arch)/enc/trans" enc/trans
	$(MAKE) -f enc.mk $(MFLAGS)

enc.mk: $(srcdir)/enc/make_encmake.rb $(srcdir)/enc/Makefile.in $(srcdir)/enc/depend \
	$(srcdir)/lib/mkmf.rb $(RBCONFIG)
	$(MINIRUBY) $(srcdir)/enc/make_encmake.rb --builtin-encs="$(BUILTIN_ENCOBJS)" $@

.PRECIOUS: $(MKFILES)

.PHONY: test install install-nodoc install-doc dist

PHONY:

{$(VPATH)}parse.c: {$(VPATH)}parse.y $(srcdir)/tool/ytab.sed

{$(srcdir)}.y.c:
	$(YACC) $(YFLAGS) -o y.tab.c $<
	sed -f $(srcdir)/tool/ytab.sed -e "/^#/s!y\.tab\.c!$@!" y.tab.c > $@.new
	@$(RM) $@ y.tab.c
	@$(MV) $@.new $@

acosh.$(OBJEXT): {$(VPATH)}acosh.c
alloca.$(OBJEXT): {$(VPATH)}alloca.c {$(VPATH)}config.h
crypt.$(OBJEXT): {$(VPATH)}crypt.c
dup2.$(OBJEXT): {$(VPATH)}dup2.c
erf.$(OBJEXT): {$(VPATH)}erf.c
finite.$(OBJEXT): {$(VPATH)}finite.c
flock.$(OBJEXT): {$(VPATH)}flock.c
memcmp.$(OBJEXT): {$(VPATH)}memcmp.c
memmove.$(OBJEXT): {$(VPATH)}memmove.c
mkdir.$(OBJEXT): {$(VPATH)}mkdir.c
strchr.$(OBJEXT): {$(VPATH)}strchr.c
strdup.$(OBJEXT): {$(VPATH)}strdup.c
strerror.$(OBJEXT): {$(VPATH)}strerror.c
strftime.$(OBJEXT): {$(VPATH)}strftime.c
strstr.$(OBJEXT): {$(VPATH)}strstr.c
strtod.$(OBJEXT): {$(VPATH)}strtod.c
strtol.$(OBJEXT): {$(VPATH)}strtol.c
nt.$(OBJEXT): {$(VPATH)}nt.c
x68.$(OBJEXT): {$(VPATH)}x68.c
os2.$(OBJEXT): {$(VPATH)}os2.c
dl_os2.$(OBJEXT): {$(VPATH)}dl_os2.c
ia64.$(OBJEXT): {$(VPATH)}ia64.s
	$(CC) $(CFLAGS) -c $<

# when I use -I., there is confliction at "OpenFile" 
# so, set . into environment varible "include"
win32.$(OBJEXT): {$(VPATH)}win32.c

###

array.$(OBJEXT): {$(VPATH)}array.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}util.h
bignum.$(OBJEXT): {$(VPATH)}bignum.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h
class.$(OBJEXT): {$(VPATH)}class.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}signal.h {$(VPATH)}node.h
compar.$(OBJEXT): {$(VPATH)}compar.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h
dir.$(OBJEXT): {$(VPATH)}dir.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}util.h
dln.$(OBJEXT): {$(VPATH)}dln.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}dln.h
dmydln.$(OBJEXT): {$(VPATH)}dmydln.c {$(VPATH)}dln.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}dln.h
dmyext.$(OBJEXT): {$(VPATH)}dmyext.c
encoding.$(OBJEXT): {$(VPATH)}encoding.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}encoding.h \
  {$(VPATH)}oniguruma.h {$(VPATH)}regenc.h {$(VPATH)}encdb.h
enum.$(OBJEXT): {$(VPATH)}enum.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}node.h {$(VPATH)}util.h
enumerator.$(OBJEXT): {$(VPATH)}enumerator.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}debug.h {$(VPATH)}node.h
error.$(OBJEXT): {$(VPATH)}error.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}vm_core.h {$(VPATH)}signal.h {$(VPATH)}node.h \
  {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h
eval.$(OBJEXT): {$(VPATH)}eval.c {$(VPATH)}eval_intern.h \
  {$(VPATH)}ruby.h {$(VPATH)}config.h {$(VPATH)}defines.h \
  {$(VPATH)}missing.h {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}node.h \
  {$(VPATH)}util.h {$(VPATH)}signal.h {$(VPATH)}vm_core.h \
  {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h {$(VPATH)}dln.h \
  {$(VPATH)}eval_error.c {$(VPATH)}eval_method.c {$(VPATH)}eval_safe.c \
  {$(VPATH)}eval_jump.c
load.$(OBJEXT): {$(VPATH)}load.c {$(VPATH)}eval_intern.h \
  {$(VPATH)}ruby.h {$(VPATH)}config.h {$(VPATH)}defines.h \
  {$(VPATH)}missing.h {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}node.h \
  {$(VPATH)}util.h {$(VPATH)}signal.h {$(VPATH)}vm_core.h \
  {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h {$(VPATH)}dln.h
file.$(OBJEXT): {$(VPATH)}file.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}io.h {$(VPATH)}encoding.h {$(VPATH)}oniguruma.h \
  {$(VPATH)}signal.h {$(VPATH)}util.h {$(VPATH)}dln.h
gc.$(OBJEXT): {$(VPATH)}gc.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}signal.h {$(VPATH)}node.h {$(VPATH)}re.h \
  {$(VPATH)}regex.h {$(VPATH)}oniguruma.h {$(VPATH)}io.h \
  {$(VPATH)}encoding.h {$(VPATH)}vm_core.h {$(VPATH)}debug.h \
  {$(VPATH)}vm_opts.h {$(VPATH)}id.h {$(VPATH)}thread_$(THREAD_MODEL).h \
  {$(VPATH)}gc.h
hash.$(OBJEXT): {$(VPATH)}hash.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}util.h {$(VPATH)}signal.h
inits.$(OBJEXT): {$(VPATH)}inits.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h
io.$(OBJEXT): {$(VPATH)}io.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}io.h {$(VPATH)}encoding.h {$(VPATH)}oniguruma.h \
  {$(VPATH)}signal.h {$(VPATH)}util.h
main.$(OBJEXT): {$(VPATH)}main.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h
marshal.$(OBJEXT): {$(VPATH)}marshal.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}io.h {$(VPATH)}encoding.h \
  {$(VPATH)}oniguruma.h {$(VPATH)}util.h
math.$(OBJEXT): {$(VPATH)}math.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h
numeric.$(OBJEXT): {$(VPATH)}numeric.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}encoding.h \
  {$(VPATH)}oniguruma.h
object.$(OBJEXT): {$(VPATH)}object.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}util.h {$(VPATH)}debug.h {$(VPATH)}node.h
pack.$(OBJEXT): {$(VPATH)}pack.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h
parse.$(OBJEXT): {$(VPATH)}parse.c {$(VPATH)}parse.y {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}node.h {$(VPATH)}encoding.h \
  {$(VPATH)}oniguruma.h {$(VPATH)}id.h {$(VPATH)}regenc.h \
  {$(VPATH)}regex.h {$(VPATH)}util.h {$(VPATH)}lex.c {$(VPATH)}keywords \
  {$(VPATH)}debug.h
prec.$(OBJEXT): {$(VPATH)}prec.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h
proc.$(OBJEXT): {$(VPATH)}proc.c {$(VPATH)}eval_intern.h \
  {$(VPATH)}ruby.h {$(VPATH)}config.h {$(VPATH)}defines.h \
  {$(VPATH)}missing.h {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}node.h \
  {$(VPATH)}util.h {$(VPATH)}signal.h {$(VPATH)}vm_core.h \
  {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h {$(VPATH)}dln.h {$(VPATH)}gc.h
process.$(OBJEXT): {$(VPATH)}process.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}signal.h {$(VPATH)}vm_core.h \
  {$(VPATH)}node.h {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h
random.$(OBJEXT): {$(VPATH)}random.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h
range.$(OBJEXT): {$(VPATH)}range.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h
re.$(OBJEXT): {$(VPATH)}re.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}re.h {$(VPATH)}regex.h {$(VPATH)}oniguruma.h \
  {$(VPATH)}encoding.h {$(VPATH)}util.h {$(VPATH)}regint.h \
  {$(VPATH)}regenc.h
regcomp.$(OBJEXT): {$(VPATH)}regcomp.c {$(VPATH)}regparse.h \
  {$(VPATH)}regint.h {$(VPATH)}config.h {$(VPATH)}defines.h \
  {$(VPATH)}regenc.h {$(VPATH)}oniguruma.h {$(VPATH)}st.h
regenc.$(OBJEXT): {$(VPATH)}regenc.c {$(VPATH)}regint.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}regenc.h \
  {$(VPATH)}oniguruma.h {$(VPATH)}st.h
regerror.$(OBJEXT): {$(VPATH)}regerror.c {$(VPATH)}regint.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}regenc.h \
  {$(VPATH)}oniguruma.h {$(VPATH)}st.h
regexec.$(OBJEXT): {$(VPATH)}regexec.c {$(VPATH)}regint.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}regenc.h \
  {$(VPATH)}oniguruma.h {$(VPATH)}st.h
regparse.$(OBJEXT): {$(VPATH)}regparse.c {$(VPATH)}regparse.h \
  {$(VPATH)}regint.h {$(VPATH)}config.h {$(VPATH)}defines.h \
  {$(VPATH)}regenc.h {$(VPATH)}oniguruma.h {$(VPATH)}st.h
regsyntax.$(OBJEXT): {$(VPATH)}regsyntax.c {$(VPATH)}regint.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}regenc.h \
  {$(VPATH)}oniguruma.h {$(VPATH)}st.h
ruby.$(OBJEXT): {$(VPATH)}ruby.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}node.h {$(VPATH)}encoding.h \
  {$(VPATH)}oniguruma.h {$(VPATH)}eval_intern.h {$(VPATH)}util.h \
  {$(VPATH)}signal.h {$(VPATH)}vm_core.h {$(VPATH)}debug.h \
  {$(VPATH)}vm_opts.h {$(VPATH)}id.h {$(VPATH)}thread_$(THREAD_MODEL).h \
  {$(VPATH)}dln.h
signal.$(OBJEXT): {$(VPATH)}signal.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}signal.h {$(VPATH)}node.h {$(VPATH)}vm_core.h \
  {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h
sprintf.$(OBJEXT): {$(VPATH)}sprintf.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}re.h {$(VPATH)}regex.h \
  {$(VPATH)}oniguruma.h {$(VPATH)}encoding.h {$(VPATH)}vsnprintf.c
st.$(OBJEXT): {$(VPATH)}st.c {$(VPATH)}config.h {$(VPATH)}defines.h \
  {$(VPATH)}st.h
string.$(OBJEXT): {$(VPATH)}string.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}re.h {$(VPATH)}regex.h {$(VPATH)}oniguruma.h \
  {$(VPATH)}encoding.h
struct.$(OBJEXT): {$(VPATH)}struct.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h
thread.$(OBJEXT): {$(VPATH)}thread.c {$(VPATH)}eval_intern.h \
  {$(VPATH)}ruby.h {$(VPATH)}config.h {$(VPATH)}defines.h \
  {$(VPATH)}missing.h {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}node.h \
  {$(VPATH)}util.h {$(VPATH)}signal.h {$(VPATH)}vm_core.h \
  {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h {$(VPATH)}dln.h {$(VPATH)}vm.h \
  {$(VPATH)}gc.h {$(VPATH)}thread_$(THREAD_MODEL).c
transcode.$(OBJEXT): {$(VPATH)}transcode.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}encoding.h \
  {$(VPATH)}oniguruma.h {$(VPATH)}transcode_data.h
cont.$(OBJEXT): {$(VPATH)}cont.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}vm_core.h {$(VPATH)}signal.h {$(VPATH)}node.h \
  {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h {$(VPATH)}gc.h \
  {$(VPATH)}eval_intern.h {$(VPATH)}util.h {$(VPATH)}dln.h
time.$(OBJEXT): {$(VPATH)}time.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h
util.$(OBJEXT): {$(VPATH)}util.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}util.h
variable.$(OBJEXT): {$(VPATH)}variable.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}node.h {$(VPATH)}util.h
version.$(OBJEXT): {$(VPATH)}version.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}version.h \
  {$(VPATH)}revision.h

compile.$(OBJEXT): {$(VPATH)}compile.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}node.h {$(VPATH)}vm_core.h \
  {$(VPATH)}signal.h {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h {$(VPATH)}compile.h \
  {$(VPATH)}insns.inc {$(VPATH)}insns_info.inc {$(VPATH)}optinsn.inc
iseq.$(OBJEXT): {$(VPATH)}iseq.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}node.h {$(VPATH)}gc.h {$(VPATH)}vm_core.h \
  {$(VPATH)}signal.h {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h {$(VPATH)}insns.inc \
  {$(VPATH)}insns_info.inc {$(VPATH)}node_name.inc
vm.$(OBJEXT): {$(VPATH)}vm.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}node.h {$(VPATH)}encoding.h \
  {$(VPATH)}oniguruma.h {$(VPATH)}gc.h {$(VPATH)}insnhelper.h \
  {$(VPATH)}eval_intern.h {$(VPATH)}util.h {$(VPATH)}signal.h \
  {$(VPATH)}vm_core.h {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h {$(VPATH)}dln.h {$(VPATH)}vm.h \
  {$(VPATH)}vm_insnhelper.c {$(VPATH)}insns.inc {$(VPATH)}vm_evalbody.c \
  {$(VPATH)}vmtc.inc {$(VPATH)}vm.inc {$(VPATH)}insns.def
vm_dump.$(OBJEXT): {$(VPATH)}vm_dump.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}node.h {$(VPATH)}vm_core.h \
  {$(VPATH)}signal.h {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h {$(VPATH)}vm.h
debug.$(OBJEXT): {$(VPATH)}debug.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}encoding.h {$(VPATH)}oniguruma.h \
  {$(VPATH)}debug.h {$(VPATH)}node.h {$(VPATH)}vm_core.h \
  {$(VPATH)}signal.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h
blockinlining.$(OBJEXT): {$(VPATH)}blockinlining.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}node.h {$(VPATH)}vm_core.h \
  {$(VPATH)}signal.h {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h
id.$(OBJEXT): {$(VPATH)}id.c {$(VPATH)}ruby.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}missing.h {$(VPATH)}intern.h \
  {$(VPATH)}st.h {$(VPATH)}id.h
miniprelude.$(OBJEXT): {$(VPATH)}miniprelude.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}vm_core.h {$(VPATH)}signal.h \
  {$(VPATH)}node.h {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h
prelude.$(OBJEXT): {$(VPATH)}prelude.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}vm_core.h {$(VPATH)}signal.h \
  {$(VPATH)}node.h {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h
golf_prelude.$(OBJEXT): {$(VPATH)}golf_prelude.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h {$(VPATH)}vm_core.h {$(VPATH)}signal.h \
  {$(VPATH)}node.h {$(VPATH)}debug.h {$(VPATH)}vm_opts.h {$(VPATH)}id.h \
  {$(VPATH)}thread_$(THREAD_MODEL).h
goruby.$(OBJEXT): {$(VPATH)}goruby.c {$(VPATH)}main.c {$(VPATH)}ruby.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}missing.h \
  {$(VPATH)}intern.h {$(VPATH)}st.h

ascii.$(OBJEXT): {$(VPATH)}ascii.c {$(VPATH)}regenc.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}oniguruma.h
euc_jp.$(OBJEXT): {$(VPATH)}euc_jp.c {$(VPATH)}regint.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}regenc.h \
  {$(VPATH)}oniguruma.h {$(VPATH)}st.h
shift_jis.$(OBJEXT): {$(VPATH)}shift_jis.c {$(VPATH)}regint.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}regenc.h {$(VPATH)}oniguruma.h \
  {$(VPATH)}st.h
unicode.$(OBJEXT): {$(VPATH)}unicode.c {$(VPATH)}regint.h \
  {$(VPATH)}config.h {$(VPATH)}defines.h {$(VPATH)}regenc.h \
  {$(VPATH)}oniguruma.h {$(VPATH)}st.h
utf8.$(OBJEXT): {$(VPATH)}utf8.c {$(VPATH)}regenc.h {$(VPATH)}config.h \
  {$(VPATH)}defines.h {$(VPATH)}oniguruma.h

INSNS	= opt_sc.inc optinsn.inc optunifs.inc insns.inc \
	  vmtc.inc vm.inc

INSNS2VMOPT = --srcdir="$(srcdir)"

$(INSNS): $(srcdir)/insns.def {$(VPATH)}vm_opts.h
	$(RM) $(PROGRAM)
	$(BASERUBY) $(srcdir)/tool/insns2vm.rb $(INSNS2VMOPT)

minsns.inc: $(srcdir)/template/minsns.inc.tmpl

opt_sc.inc: $(srcdir)/template/opt_sc.inc.tmpl

optinsn.inc: $(srcdir)/template/optinsn.inc.tmpl

optunifs.inc: $(srcdir)/template/optunifs.inc.tmpl

insns.inc: $(srcdir)/template/insns.inc.tmpl

insns_info.inc: $(srcdir)/template/insns_info.inc.tmpl

vmtc.inc: $(srcdir)/template/vmtc.inc.tmpl

vm.inc: $(srcdir)/template/vm.inc.tmpl

srcs: {$(VPATH)}parse.c {$(VPATH)}lex.c $(srcdir)/ext/ripper/ripper.c

incs: $(INSNS) {$(VPATH)}node_name.inc {$(VPATH)}encdb.h {$(VPATH)}revision.h

node_name.inc: {$(VPATH)}node.h
	$(BASERUBY) -n $(srcdir)/tool/node_name.rb $? > $@

encdb.h: $(srcdir)/enc/make_encdb.rb
	$(BASERUBY) $(srcdir)/enc/make_encdb.rb $(srcdir)/enc

miniprelude.c: $(srcdir)/tool/compile_prelude.rb $(srcdir)/prelude.rb
	$(BASERUBY) -I$(srcdir) $(srcdir)/tool/compile_prelude.rb $(srcdir)/prelude.rb $@

prelude.c: $(srcdir)/tool/compile_prelude.rb $(srcdir)/prelude.rb $(srcdir)/gem_prelude.rb $(RBCONFIG)
	$(MINIRUBY) -I$(srcdir) -rrbconfig $(srcdir)/tool/compile_prelude.rb $(srcdir)/prelude.rb $(srcdir)/gem_prelude.rb $@

golf_prelude.c: $(srcdir)/tool/compile_prelude.rb $(srcdir)/prelude.rb $(srcdir)/golf_prelude.rb
	$(MINIRUBY) -I$(srcdir) -rrbconfig $(srcdir)/tool/compile_prelude.rb $(srcdir)/golf_prelude.rb $@

prereq: incs srcs preludes

preludes: {$(VPATH)}miniprelude.c
preludes: {$(srcdir)}golf_prelude.c
PRELUDES = prelude.c miniprelude.c golf_prelude.c

docs:
	$(BASERUBY) -I$(srcdir) $(srcdir)/tool/makedocs.rb $(INSNS2VMOPT)

revision.h:
	exit > $@

$(srcdir)/ext/ripper/ripper.c:
	cd $(srcdir)/ext/ripper && exec $(MAKE) -f depend $(MFLAGS) top_srcdir=../.. srcdir=.

##

run: miniruby$(EXEEXT) PHONY
	$(MINIRUBY) $(srcdir)/test.rb $(RUNOPT)

runruby: $(PROGRAM) PHONY
	$(RUNRUBY) $(srcdir)/test.rb

parse: miniruby$(EXEEXT) PHONY
	$(MINIRUBY) $(srcdir)/tool/parse.rb $(srcdir)/test.rb

COMPARE_RUBY = $(BASERUBY)
ITEM = 
OPTS = 

benchmark: $(PROGRAM) PHONY
	$(BASERUBY) $(srcdir)/benchmark/driver.rb -v \
	            --executables="$(COMPARE_RUBY); $(RUNRUBY)" \
	            --pattern='bm_' --directory=$(srcdir)/benchmark $(OPTS)

benchmark-each: $(PROGRAM) PHONY
	$(BASERUBY) $(srcdir)/benchmark/driver.rb -v \
	            --executables="$(COMPARE_RUBY); $(RUNRUBY)" \
	            --pattern=$(ITEM) --directory=$(srcdir)/benchmark $(OPTS)

tbench: $(PROGRAM) PHONY
	$(BASERUBY) $(srcdir)/benchmark/driver.rb -v \
	            --executables="$(COMPARE_RUBY); $(RUNRUBY)" \
	            --pattern='bmx_' --directory=$(srcdir)/benchmark $(OPTS)

aotc: $(PROGRAM) PHONY
	./$(PROGRAM) -I$(srcdir)/lib $(srcdir)/bin/ruby2cext $(srcdir)/test.rb

vmasm: vm.$(ASMEXT)

# vm.o : CFLAGS += -fno-crossjumping

run.gdb:
	echo b ruby_debug_breakpoint           > run.gdb
	echo '# handle SIGINT nostop'         >> run.gdb
	echo '# handle SIGPIPE nostop'        >> run.gdb
	echo '# b rb_longjmp'                 >> run.gdb
	echo source $(srcdir)/breakpoints.gdb >> run.gdb
	echo source $(srcdir)/.gdbinit        >> run.gdb
	echo run                              >> run.gdb

gdb: miniruby$(EXEEXT) run.gdb PHONY
	gdb -x run.gdb --quiet --args $(MINIRUBY) $(srcdir)/test.rb

# Intel VTune

vtune: miniruby$(EXEEXT)
	vtl activity -c sampling -app ".\miniruby$(EXEEXT)","-I$(srcdir)/lib $(srcdir)/test.rb" run
	vtl view -hf -mn miniruby$(EXEEXT) -sum -sort -cd
	vtl view -ha -mn miniruby$(EXEEXT) -sum -sort -cd | $(RUNRUBY) $(srcdir)/tool/vtlh.rb > ha.lines

dist: $(PROGRAM)
	$(RUNRUBY) $(srcdir)/distruby.rb
