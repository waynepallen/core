# First file: libruby.stp

mkfiles () {
echo > $RPMDUILD/SOURCES/libruby.stp <<EOF
/* SystemTap tapset to make it easier to trace Ruby 2.0
 *
 * All probes provided by Ruby can be listed using following command
 * (the path to the library must be adjuste appropriately):
 *
 * stap -L 'process("@LIBRARY_PATH@").mark("*")'
 */

/**
 * probe ruby.array.create - Allocation of new array.
 *
 * @size: Number of elements (an int)
 * @file: The file name where the method is being called (string)
 * @line: The line number where the method is being called (int)
 */
probe ruby.array.create =
      process("@LIBRARY_PATH@").mark("array__create")
{
	size = $arg1
	file = user_string($arg2)
	line = $arg3
}

/**
 * probe ruby.cmethod.entry - Fired just before a method implemented in C is entered.
 *
 * @classname: Name of the class (string)
 * @methodname: The method about bo be executed (string)
 * @file: The file name where the method is being called (string)
 * @line: The line number where the method is being called (int)
 */
probe ruby.cmethod.entry =
      process("@LIBRARY_PATH@").mark("cmethod__entry")
{
	classname  = user_string($arg1)
	methodname = user_string($arg2)
	file = user_string($arg3)
	line = $arg4
}

/**
 * probe ruby.cmethod.return - Fired just after a method implemented in C has returned.
 *
 * @classname: Name of the class (string)
 * @methodname: The executed method (string)
 * @file: The file name where the method is being called (string)
 * @line: The line number where the method is being called (int)
 */
probe ruby.cmethod.return =
      process("@LIBRARY_PATH@").mark("cmethod__return")
{
	classname  = user_string($arg1)
	methodname = user_string($arg2)
	file = user_string($arg3)
	line = $arg4
}

/**
 * probe ruby.find.require.entry - Fired when require starts to search load
 * path for suitable file to require.
 *
 * @requiredfile: The name of the file to be required (string)
 * @file: The file name where the method is being called (string)
 * @line: The line number where the method is being called (int)
 */
probe ruby.find.require.entry =
      process("@LIBRARY_PATH@").mark("find__require__entry")
{
	requiredfile = user_string($arg1)
	file = user_string($arg2)
	line = $arg3
}

/**
 * probe ruby.find.require.return - Fired just after require has finished
 * search of load path for suitable file to require.
 *
 * @requiredfile: The name of the file to be required (string)
 * @file: The file name where the method is being called (string)
 * @line: The line number where the method is being called (int)
 */
probe ruby.find.require.return =
      process("@LIBRARY_PATH@").mark("find__require__return")
{
	requiredfile = user_string($arg1)
	file = user_string($arg2)
	line = $arg3
}

/**
 * probe ruby.gc.mark.begin - Fired when a GC mark phase is about to start.
 *
 * It takes no arguments.
 */
probe ruby.gc.mark.begin =
      process("@LIBRARY_PATH@").mark("gc__mark__begin")
{
}

/**
 * probe ruby.gc.mark.end - Fired when a GC mark phase has ended.
 *
 * It takes no arguments.
 */
probe ruby.gc.mark.end =
      process("@LIBRARY_PATH@").mark("gc__mark__end")
{
}

/**
 * probe ruby.gc.sweep.begin - Fired when a GC sweep phase is about to start.
 *
 * It takes no arguments.
 */
probe ruby.gc.sweep.begin =
      process("@LIBRARY_PATH@").mark("gc__sweep__begin")
{
}

/**
 * probe ruby.gc.sweep.end - Fired when a GC sweep phase has ended.
 *
 * It takes no arguments.
 */
probe ruby.gc.sweep.end =
      process("@LIBRARY_PATH@").mark("gc__sweep__end")
{
}

/**
 * probe ruby.hash.create - Allocation of new hash.
 *
 * @size: Number of elements (int)
 * @file: The file name where the method is being called (string)
 * @line: The line number where the method is being called (int)
 */
probe ruby.hash.create =
      process("@LIBRARY_PATH@").mark("hash__create")
{
	size = $arg1
	file = user_string($arg2)
	line = $arg3
}

/**
 * probe ruby.load.entry - Fired when calls to "load" are made.
 *
 * @loadedfile: The name of the file to be loaded (string)
 * @file: The file name where the method is being called (string)
 * @line: The line number where the method is being called (int)
 */
probe ruby.load.entry =
      process("@LIBRARY_PATH@").mark("load__entry")
{
	loadedfile = user_string($arg1)
	file = user_string($arg2)
	line = $arg3
}

/**
 * probe ruby.load.return - Fired just after require has finished
 * search of load path for suitable file to require.
 *
 * @loadedfile: The name of the file that was loaded (string)
 */
probe ruby.load.return =
      process("@LIBRARY_PATH@").mark("load__return")
{
	loadedfile = user_string($arg1)
}

/**
 * probe ruby.method.entry - Fired just before a method implemented in Ruby is entered.
 *
 * @classname: Name of the class (string)
 * @methodname: The method about bo be executed (string)
 * @file: The file name where the method is being called (string)
 * @line: The line number where the method is being called (int)
 */
probe ruby.method.entry =
      process("@LIBRARY_PATH@").mark("method__entry")
{
	classname  = user_string($arg1)
	methodname = user_string($arg2)
	file = user_string($arg3)
	line = $arg4
}

/**
 * probe ruby.method.return - Fired just after a method implemented in Ruby has returned.
 *
 * @classname: Name of the class (string)
 * @methodname: The executed method (string)
 * @file: The file name where the method is being called (string)
 * @line: The line number where the method is being called (int)
 */
probe ruby.method.return =
      process("@LIBRARY_PATH@").mark("method__return")
{
	classname  = user_string($arg1)
	methodname = user_string($arg2)
	file = user_string($arg3)
	line = $arg4
}

/**
 * probe ruby.object.create - Allocation of new object.
 *
 * @classname: Name of the class (string)
 * @file: The file name where the method is being called (string)
 * @line: The line number where the method is being called (int)
 */
probe ruby.object.create =
      process("@LIBRARY_PATH@").mark("object__create")
{
	classname = user_string($arg1)
	file = user_string($arg2)
	line = $arg3
}

/**
 * probe ruby.parse.begin - Fired just before a Ruby source file is parsed.
 *
 * @parsedfile: The name of the file to be parsed (string)
 * @parsedline: The line number of beginning of parsing (int)
 */
probe ruby.parse.begin =
      process("@LIBRARY_PATH@").mark("parse__begin")
{
	parsedfile = user_string($arg1)
	parsedline = $arg2
}

/**
 * probe ruby.parse.end - Fired just after a Ruby source file was parsed.
 *
 * @parsedfile: The name of parsed the file (string)
 * @parsedline: The line number of beginning of parsing (int)
 */
probe ruby.parse.end =
      process("@LIBRARY_PATH@").mark("parse__end")
{
	parsedfile = user_string($arg1)
	parsedline = $arg2
}

/**
 * probe ruby.raise - Fired when an exception is raised.
 *
 * @classname: The class name of the raised exception (string)
 * @file: The name of the file where the exception was raised (string)
 * @line: The line number in the file where the exception was raised (int)
 */
probe ruby.raise =
      process("@LIBRARY_PATH@").mark("raise")
{
	classname  = user_string($arg1)
	file = user_string($arg2)
	line = $arg3
}

/**
 * probe ruby.require.entry - Fired on calls to rb_require_safe (when a file
 * is required).
 *
 * @requiredfile: The name of the file to be required (string)
 * @file: The file that called "require" (string)
 * @line: The line number where the call to require was made(int)
 */
probe ruby.require.entry =
      process("@LIBRARY_PATH@").mark("require__entry")
{
	requiredfile = user_string($arg1)
	file = user_string($arg2)
	line = $arg3
}

/**
 * probe ruby.require.return - Fired just after require has finished
 * search of load path for suitable file to require.
 *
 * @requiredfile: The file that was required (string)
 */
probe ruby.require.return =
      process("@LIBRARY_PATH@").mark("require__return")
{
	requiredfile = user_string($arg1)
}

/**
 * probe ruby.string.create - Allocation of new string.
 *
 * @size: Number of elements (an int)
 * @file: The file name where the method is being called (string)
 * @line: The line number where the method is being called (int)
 */
probe ruby.string.create =
      process("@LIBRARY_PATH@").mark("string__create")
{
	size = $arg1
	file = user_string($arg2)
	line = $arg3
}
EOF

# Second File: macros.ruby
echo >  $RPMBUILD/SOURCES/macros.ruby <<EOF
%ruby_libdir %{_datadir}/%{name}
%ruby_libarchdir %{_libdir}/%{name}

# This is the local lib/arch and should not be used for packaging.
%ruby_sitedir site_ruby
%ruby_sitelibdir %{_prefix}/local/share/%{name}/%{ruby_sitedir}
%ruby_sitearchdir %{_prefix}/local/%{_lib}/%{name}/%{ruby_sitedir}

# This is the general location for libs/archs compatible with all
# or most of the Ruby versions available in the Fedora repositories.
%ruby_vendordir vendor_ruby
%ruby_vendorlibdir %{ruby_libdir}/%{ruby_vendordir}
%ruby_vendorarchdir %{ruby_libarchdir}/%{ruby_vendordir}

# For ruby packages we want to filter out any provides caused by private
# libs in %%{ruby_vendorarchdir}/%%{ruby_sitearchdir}.
#
# Note that this must be invoked in the spec file, preferably as
# "%{?ruby_default_filter}", before any %description block.
%ruby_default_filter %{expand: \
%global __provides_exclude_from %{?__provides_exclude_from:%{__provides_exclude_from}|}^(%{ruby_vendorarchdir}|%{ruby_sitearchdir})/.*\\\\.so$ \
}
EOF

# Second File: macros.rubygems
echo >  macros.rubygems <<EOF
# The RubyGems root folder.
%gem_dir %{_datadir}/gems
%gem_archdir %{_libdir}/gems

# Common gem locations and files.
%gem_instdir %{gem_dir}/gems/%{gem_name}-%{version}
%gem_extdir_mri %{gem_archdir}/%{name}/%{gem_name}-%{version}
%gem_libdir %{gem_instdir}/lib
%gem_cache %{gem_dir}/cache/%{gem_name}-%{version}.gem
%gem_spec %{gem_dir}/specifications/%{gem_name}-%{version}.gemspec
%gem_docdir %{gem_dir}/doc/%{gem_name}-%{version}

# Install gem into appropriate directory.
# -n<gem_file>      Overrides gem file name for installation.
# -d<install_dir>   Set installation directory.
%gem_install(d:n:) \
mkdir -p %{-d*}%{!?-d:.%{gem_dir}} \
\
CONFIGURE_ARGS="--with-cflags='%{optflags}' $CONFIGURE_ARGS" \\\
gem install \\\
        -V \\\
        --local \\\
        --install-dir %{-d*}%{!?-d:.%{gem_dir}} \\\
        --bindir .%{_bindir} \\\
        --force \\\
        --document=ri,rdoc \\\
        %{-n*}%{!?-n:%{gem_name}-%{version}.gem} \
%{nil}

# For rubygems packages we want to filter out any provides caused by private
# libs in %%{gem_archdir}.
#
# Note that this must be invoked in the spec file, preferably as
# "%{?rubygems_default_filter}", before any %description block.
%rubygems_default_filter %{expand: \
%global __provides_exclude_from %{?__provides_exclude_from:%{__provides_exclude_from}|}^%{gem_extdir_mri}/.*\\\\.so$ \
}
EOF

#Third File: operating_system.rb
echo > $RPMBUILD/SOURCES/operating_system.rb <<EOF
module Gem
  class << self

    ##
    # Returns full path of previous but one directory of dir in path
    # E.g. for '/usr/share/ruby', 'ruby', it returns '/usr'

    def previous_but_one_dir_to(path, dir)
      split_path = path.split(File::SEPARATOR)
      File.join(split_path.take_while { |one_dir| one_dir !~ /^#{dir}$/ }[0..-2])
    end
    private :previous_but_one_dir_to

    ##
    # Default gems locations allowed on FHS system (/usr, /usr/share).
    # The locations are derived from directories specified during build
    # configuration.

    def default_locations
      @default_locations ||= {
        :system => previous_but_one_dir_to(ConfigMap[:vendordir], ConfigMap[:RUBY_INSTALL_NAME]),
        :local => previous_but_one_dir_to(ConfigMap[:sitedir], ConfigMap[:RUBY_INSTALL_NAME])
      }
    end

    ##
    # For each location provides set of directories for binaries (:bin_dir)
    # platform independent (:gem_dir) and dependent (:ext_dir) files.

    def default_dirs
      @libdir ||= ConfigMap[:sitelibdir] == ConfigMap[:sitearchdir] ? ConfigMap[:datadir] : ConfigMap[:libdir]
      @default_dirs ||= Hash[default_locations.collect do |destination, path|
        [destination, {
          :bin_dir => File.join(path, ConfigMap[:bindir].split(File::SEPARATOR).last),
          :gem_dir => File.join(path, ConfigMap[:datadir].split(File::SEPARATOR).last, 'gems'),
          :ext_dir => File.join(path, @libdir.split(File::SEPARATOR).last, 'gems')
        }]
      end]
    end

    ##
    # Remove methods we are going to override. This avoids "method redefined;"
    # warnings otherwise issued by Ruby.

    remove_method :default_dir if method_defined? :default_dir
    remove_method :default_path if method_defined? :default_path
    remove_method :default_bindir if method_defined? :default_bindir
    remove_method :default_ext_dir_for if method_defined? :default_ext_dir_for

    ##
    # RubyGems default overrides.

    def default_dir
      if Process.uid == 0
        Gem.default_dirs[:local][:gem_dir]
      else
        Gem.user_dir
      end
    end

    def default_path
      path = default_dirs.collect {|location, paths| paths[:gem_dir]}
      path.unshift Gem.user_dir if File.exist? Gem.user_home
    end

    def default_bindir
      if Process.uid == 0
        Gem.default_dirs[:local][:bin_dir]
      else
        File.join [Dir.home, 'bin']
      end
    end

    def default_ext_dir_for base_dir
      dirs = Gem.default_dirs.detect {|location, paths| paths[:gem_dir] == base_dir}
      dirs && File.join(dirs.last[:ext_dir], RbConfig::CONFIG['RUBY_INSTALL_NAME'])
    end
  end
end
EOF

# Forth File: ruby-exercises.stp
echo > $RPMBUILD/SOURCES/ruby-exercises.stp <<EOF
/* Example tapset file.
 *
 * You can execute the tapset using following command (please adjust the path
 * prior running the command, if needed):
 * 
 * stap /usr/share/doc/ruby-2.0.0.0/ruby-exercise.stp -c "ruby -e \"puts 'test'\""
 */

probe ruby.cmethod.entry {
  printf("%d -> %s::%s %s:%d\n", tid(), classname, methodname, file, line);
}

probe ruby.cmethod.return {
  printf("%d <- %s::%s %s:%d\n", tid(), classname, methodname, file, line);
}

probe ruby.method.entry {
  printf("%d -> %s::%s %s:%d\n", tid(), classname, methodname, file, line);
}

probe ruby.method.return {
  printf("%d <- %s::%s %s:%d\n", tid(), classname, methodname, file, line);
}

probe ruby.gc.mark.begin { printf("%d gc.mark.begin\n", tid()); }

probe ruby.gc.mark.end { printf("%d gc.mark.end\n", tid()); }

probe ruby.gc.sweep.begin { printf("%d gc.sweep.begin\n", tid()); }

probe ruby.gc.sweep.end { printf("%d gc.sweep.end\n", tid()); }

probe ruby.object.create{
  printf("%d obj.create %s %s:%d\n", tid(), classname, file, line);
}

probe ruby.raise {
  printf("%d raise %s %s:%d\n", tid(), classname, file, line);
}
EOF

# Fifth File: ruby.spec
echo > $RPMBUILD/SPECS/ruby.spec << EOF
%global major_version 2
%global minor_version 0
%global teeny_version 0
%global patch_level $RUBYPL

%global major_minor_version %{major_version}.%{minor_version}

%global ruby_version %{major_minor_version}.%{teeny_version}
%global ruby_version_patch_level %{major_minor_version}.%{teeny_version}.%{patch_level}
%global ruby_release %{ruby_version}
%global ruby_archive %{name}-%{ruby_version}

# If revision and milestone are removed/commented out, the official release build is expected.
%if 0%{?milestone:1}%{?revision:1} != 0
%global development_release %{?milestone}%{?!milestone:%{?revision:r%{revision}}}
%global ruby_archive %{ruby_archive}-%{?milestone}%{?!milestone:%{?revision:r%{revision}}}
%else
%global ruby_archive %{ruby_archive}-p%{patch_level}
%endif


%global release 1
%{!?release_string:%global release_string %{?development_release:0.}%{release}%{?development_release:.%{development_release}}%{?dist}}

%global rubygems_version 2.0.2

# The RubyGems library has to stay out of Ruby directory tree, since the
# RubyGems should be shared by all Ruby implementations.
%global rubygems_dir %{_datadir}/rubygems

%global rake_version 0.9.6
%global irb_version %{ruby_version_patch_level}
%global rdoc_version 4.0.0
%global bigdecimal_version 1.2.0
%global io_console_version 0.4.2
%global json_version 1.7.7
%global minitest_version 4.3.2
%global psych_version 2.0.0

%global tapset_root %{_datadir}/systemtap
%global tapset_dir %{tapset_root}/tapset
%global tapset_libdir %(echo %{_libdir} | sed 's/64//')*


Summary: An interpreter of object-oriented scripting language
Name: ruby
Version: %{ruby_version_patch_level}
Release: %{release_string}
Group: Development/Languages
# Public Domain for example for: include/ruby/st.h, strftime.c, ...
License: (Ruby or BSD) and Public Domain
URL: http://ruby-lang.org/
Source0: ftp://ftp.ruby-lang.org/pub/%{name}/%{major_minor_version}/%{ruby_archive}.tar.bz2
Source1: operating_system.rb
Source2: libruby.stp
Source3: ruby-exercise.stp
Source4: macros.ruby
Source5: macros.rubygems


# Include the constants defined in macros files.
# http://rpm.org/ticket/866
%{lua:

function source_macros(file)
  local macro = nil

  for line in io.lines(file) do
    if not macro and line:match("^%%") then
      macro = line:match("^%%(.*)$")
      line = nil
    end

    if macro then
      if line and macro:match("^.-%s*\\%s*$") then
        macro = macro .. '\n' .. line
      end

      if not macro:match("^.-%s*\\%s*$") then
        rpm.define(macro)
        macro = nil
      end
    end
  end
end

source_macros(rpm.expand("%{SOURCE4}"))
source_macros(rpm.expand("%{SOURCE5}"))

}

Requires: %{name}-libs%{?_isa} = %{version}-%{release}
Requires: ruby(rubygems) >= %{rubygems_version}
Requires: rubygem(bigdecimal) >= %{bigdecimal_version}

BuildRequires: autoconf
BuildRequires: gdbm-devel
BuildRequires: ncurses-devel
BuildRequires: db4-devel
BuildRequires: libffi-devel
BuildRequires: openssl-devel
BuildRequires: libyaml-devel
BuildRequires: readline-devel
BuildRequires: tk-devel
# Needed to pass test_set_program_name(TestRubyOptions)
BuildRequires: procps
BuildRequires: %{_bindir}/dtrace

# This package provides %%{_bindir}/ruby-mri therefore it is marked by this
# virtual provide. It can be installed as dependency of rubypick.
Provides: ruby(runtime_executable) = %{ruby_release}

%global __provides_exclude_from ^(%{ruby_libarchdir}|%{gem_archdir})/.*\\.so$

%description
Ruby is the interpreted scripting language for quick and easy
object-oriented programming.  It has many features to process text
files and to do system management tasks (as in Perl).  It is simple,
straight-forward, and extensible.


%package devel
Summary:    A Ruby development environment
Group:      Development/Languages
# Requires:   %{name}-libs = %{version}-%{release}
Requires:   %{name}%{?_isa} = %{version}-%{release}

%description devel
Header files and libraries for building an extension library for the
Ruby or an application embedding Ruby.

%package libs
Summary:    Libraries necessary to run Ruby
Group:      Development/Libraries
License:    Ruby or BSD
Provides:   ruby(release) = %{ruby_release}

%description libs
This package includes the libruby, necessary to run Ruby.

# TODO: Rename or not rename to ruby-rubygems?
%package -n rubygems
Summary:    The Ruby standard for packaging ruby libraries
Version:    %{rubygems_version}
Group:      Development/Libraries
License:    Ruby or MIT
Requires:   ruby(release)
Requires:   rubygem(rdoc) >= %{rdoc_version}
Requires:   rubygem(io-console) >= %{io_console_version}
Requires:   rubygem(psych) >= %{psych_version}
Provides:   gem = %{version}-%{release}
Provides:   ruby(rubygems) = %{version}-%{release}
BuildArch:  noarch

%description -n rubygems
RubyGems is the Ruby standard for publishing and managing third party
libraries.


%package -n rubygems-devel
Summary:    Macros and development tools for packaging RubyGems
Version:    %{rubygems_version}
Group:      Development/Libraries
License:    Ruby or MIT
Requires:   ruby(rubygems) = %{version}-%{release}
BuildArch:  noarch

%description -n rubygems-devel
Macros and development tools for packaging RubyGems.


%package -n rubygem-rake
Summary:    Ruby based make-like utility
Version:    %{rake_version}
Group:      Development/Libraries
License:    Ruby or MIT
Requires:   ruby(release)
Requires:   ruby(rubygems) >= %{rubygems_version}
Provides:   rake = %{version}-%{release}
Provides:   rubygem(rake) = %{version}-%{release}
BuildArch:  noarch

%description -n rubygem-rake
Rake is a Make-like program implemented in Ruby. Tasks and dependencies are
specified in standard Ruby syntax.


%package irb
Summary:    The Interactive Ruby
Version:    %{irb_version}
Group:      Development/Libraries
Requires:   %{name}-libs = %{ruby_version_patch_level}
Provides:   irb = %{version}-%{release}
Provides:   ruby(irb) = %{version}-%{release}
BuildArch:  noarch

%description irb
The irb is acronym for Interactive Ruby.  It evaluates ruby expression
from the terminal.


%package -n rubygem-rdoc
Summary:    A tool to generate HTML and command-line documentation for Ruby projects
Version:    %{rdoc_version}
Group:      Development/Libraries
License:    GPLv2 and Ruby and MIT
Requires:   ruby(release)
Requires:   ruby(rubygems) >= %{rubygems_version}
Requires:   ruby(irb) = %{irb_version}
Requires:   rubygem(json) >= %{json_version}
Provides:   rdoc = %{version}-%{release}
Provides:   ri = %{version}-%{release}
Provides:   rubygem(rdoc) = %{version}-%{release}
Obsoletes:  ruby-rdoc < %{version}
Obsoletes:  ruby-ri < %{version}
BuildArch:  noarch

%description -n rubygem-rdoc
RDoc produces HTML and command-line documentation for Ruby projects.  RDoc
includes the 'rdoc' and 'ri' tools for generating and displaying online
documentation.


%package doc
Summary:    Documentation for %{name}
Group:      Documentation
Requires:   %{_bindir}/ri
BuildArch:  noarch

%description doc
This package contains documentation for %{name}.


%package -n rubygem-bigdecimal
Summary:    BigDecimal provides arbitrary-precision floating point decimal arithmetic
Version:    %{bigdecimal_version}
Group:      Development/Libraries
License:    GPL+ or Artistic
Requires:   ruby(release)
Requires:   ruby(rubygems) >= %{rubygems_version}
Provides:   rubygem(bigdecimal) = %{version}-%{release}

%description -n rubygem-bigdecimal
Ruby provides built-in support for arbitrary precision integer arithmetic.
For example:

42**13 -> 1265437718438866624512

BigDecimal provides similar support for very large or very accurate floating
point numbers. Decimal arithmetic is also useful for general calculation,
because it provides the correct answers people expect–whereas normal binary
floating point arithmetic often introduces subtle errors because of the
conversion between base 10 and base 2.


%package -n rubygem-io-console
Summary:    IO/Console is a simple console utilizing library
Version:    %{io_console_version}
Group:      Development/Libraries
Requires:   ruby(release)
Requires:   ruby(rubygems) >= %{rubygems_version}
Provides:   rubygem(io-console) = %{version}-%{release}

%description -n rubygem-io-console
IO/Console provides very simple and portable access to console. It doesn't
provide higher layer features, such like curses and readline.


%package -n rubygem-json
Summary:    This is a JSON implementation as a Ruby extension in C
Version:    %{json_version}
Group:      Development/Libraries
License:    Ruby or GPLv2
Requires:   ruby(release)
Requires:   ruby(rubygems) >= %{rubygems_version}
Provides:   rubygem(json) = %{version}-%{release}

%description -n rubygem-json
This is a implementation of the JSON specification according to RFC 4627.
You can think of it as a low fat alternative to XML, if you want to store
data to disk or transmit it over a network rather than use a verbose
markup language.


%package -n rubygem-minitest
Summary:    Minitest provides a complete suite of testing facilities
Version:    %{minitest_version}
Group:      Development/Libraries
License:    MIT
Requires:   ruby(release)
Requires:   ruby(rubygems) >= %{rubygems_version}
Provides:   rubygem(minitest) = %{version}-%{release}
BuildArch:  noarch

%description -n rubygem-minitest
minitest/unit is a small and incredibly fast unit testing framework.

minitest/spec is a functionally complete spec engine.

minitest/benchmark is an awesome way to assert the performance of your
algorithms in a repeatable manner.

minitest/mock by Steven Baker, is a beautifully tiny mock object
framework.

minitest/pride shows pride in testing and adds coloring to your test
output.


%package -n rubygem-psych
Summary:    A libyaml wrapper for Ruby
Version:    %{psych_version}
Group:      Development/Libraries
License:    MIT
Requires:   ruby(release)
Requires:   ruby(rubygems) >= %{rubygems_version}
Provides:   rubygem(psych) = %{version}-%{release}

%description -n rubygem-psych
Psych is a YAML parser and emitter. Psych leverages
libyaml[http://pyyaml.org/wiki/LibYAML] for its YAML parsing and emitting
capabilities. In addition to wrapping libyaml, Psych also knows how to
serialize and de-serialize most Ruby objects to and from the YAML format.

# TODO:
# %%pacakge -n rubygem-test-unit


%package tcltk
Summary:    Tcl/Tk interface for scripting language Ruby
Group:      Development/Languages
Requires:   %{name}-libs%{?_isa} = %{ruby_version_patch_level}
Provides:   ruby(tcltk) = %{ruby_version_patch_level}-%{release}

%description tcltk
Tcl/Tk interface for the object-oriented scripting language Ruby.

%prep
%setup -q -n %{ruby_archive}

# Provide an example of usage of the tapset:
cp -a %{SOURCE3} .

%build
autoconf

%configure \
        --with-rubylibprefix='%{ruby_libdir}' \
        --with-rubyarchprefix='%{ruby_libarchdir}' \
        --with-sitedir='%{ruby_sitelibdir}' \
        --with-sitearchdir='%{ruby_sitearchdir}' \
        --with-vendordir='%{ruby_vendorlibdir}' \
        --with-vendorarchdir='%{ruby_vendorarchdir}' \
        --with-rubyhdrdir='%{_includedir}' \
        --with-ruby-pc='%{name}.pc' \
        --disable-rpath \
        --enable-shared \
        --with-ruby-version='' \
        --enable-multiarch 



# Q= makes the build output more verbose and allows to check Fedora
# compiler options.
make %{?_smp_mflags} COPY="cp -p" Q=

%install
rm -rf %{buildroot}
make install DESTDIR=%{buildroot}

# Version is empty if --with-ruby-version is specified.
# http://bugs.ruby-lang.org/issues/7807
sed -i 's/Version: \${ruby_version}/Version: %{ruby_version}/' %{buildroot}%{_libdir}/pkgconfig/%{name}.pc

# Move macros file insto proper place and replace the %%{name} macro, since it
# would be wrongly evaluated during build of other packages.
mkdir -p %{buildroot}%{_sysconfdir}/rpm
install -m 644 %{SOURCE4} %{buildroot}%{_sysconfdir}/rpm/macros.ruby
sed -i "s/%%{name}/%{name}/" %{buildroot}%{_sysconfdir}/rpm/macros.ruby
install -m 644 %{SOURCE5} %{buildroot}%{_sysconfdir}/rpm/macros.rubygems
sed -i "s/%%{name}/%{name}/" %{buildroot}%{_sysconfdir}/rpm/macros.rubygems

# Install custom operating_system.rb.
mkdir -p %{buildroot}%{rubygems_dir}/rubygems/defaults
cp %{SOURCE1} %{buildroot}%{rubygems_dir}/rubygems/defaults

### JHT ### foodbar.spec came from here

# Install a tapset and fix up the path to the library.
mkdir -p %{buildroot}%{tapset_dir}
sed -e "s|@LIBRARY_PATH@|%{tapset_libdir}/libruby.so.%{ruby_version}|" \
  %{SOURCE2} > %{buildroot}%{tapset_dir}/libruby.so.%{ruby_version}.stp
# Escape '*/' in comment.
sed -i -r "s|( \*.*\*)\/(.*)|\1\\\/\2|" %{buildroot}%{tapset_dir}/libruby.so.%{ruby_version}.stp

%check
DISABLE_TESTS=""

# The TestRbConfig errors, which does not respect configuration options.
# http://bugs.ruby-lang.org/issues/7912
DISABLE_TESTS="-x test_rbconfig.rb $DISABLE_TESTS"
#make check TESTS="-v $DISABLE_TESTS"

%post libs -p /sbin/ldconfig

%postun libs -p /sbin/ldconfig

%files
%doc COPYING
%lang(ja) %doc COPYING.ja
%doc GPL
%doc LEGAL
%{_bindir}/erb
%{_bindir}/%{name}%{?with_rubypick:-mri}
%{_bindir}/testrb
%{_mandir}/man1/erb*
%{_mandir}/man1/ruby*

# http://fedoraproject.org/wiki/Packaging:Guidelines#Packaging_Static_Libraries
%exclude %{_libdir}/libruby-static.a

%files devel
%doc COPYING*
%doc GPL
%doc LEGAL
%doc README.EXT
%lang(ja) %doc README.EXT.ja

%{_sysconfdir}/rpm/macros.ruby

%{_includedir}/*
%{_libdir}/libruby.so
%{_libdir}/pkgconfig/%{name}.pc

%files libs
%doc COPYING
%lang(ja) %doc COPYING.ja
%doc GPL
%doc LEGAL
%doc README
%lang(ja) %doc README.ja
%doc NEWS
%doc doc/NEWS-*
# Exclude /usr/local directory since it is supposed to be managed by
# local system administrator.
%exclude %{ruby_sitelibdir}
%exclude %{ruby_sitearchdir}
%{ruby_vendorlibdir}
%{ruby_vendorarchdir}

# List all these files explicitly to prevent surprises
# Platform independent libraries.
%dir %{ruby_libdir}
%{ruby_libdir}/*.rb
%exclude %{ruby_libdir}/*-tk.rb
%exclude %{ruby_libdir}/irb.rb
%exclude %{ruby_libdir}/tcltk.rb
%exclude %{ruby_libdir}/tk*.rb
%{ruby_libdir}/cgi
%{ruby_libdir}/date
%{ruby_libdir}/digest
%{ruby_libdir}/dl
%{ruby_libdir}/drb
%{ruby_libdir}/fiddle
%exclude %{ruby_libdir}/gems
%exclude %{ruby_libdir}/irb
%{ruby_libdir}/matrix
%{ruby_libdir}/net
%{ruby_libdir}/openssl
%{ruby_libdir}/optparse
%{ruby_libdir}/racc
%{ruby_libdir}/rbconfig
%{ruby_libdir}/rexml
%{ruby_libdir}/rinda
%{ruby_libdir}/ripper
%{ruby_libdir}/rss
%{ruby_libdir}/shell
%{ruby_libdir}/syslog
%{ruby_libdir}/test
%exclude %{ruby_libdir}/tk
%exclude %{ruby_libdir}/tkextlib
%{ruby_libdir}/uri
%{ruby_libdir}/webrick
%{ruby_libdir}/xmlrpc
%{ruby_libdir}/yaml

# Platform specific libraries.
%{_libdir}/libruby.so.*
%dir %{ruby_libarchdir}
%{ruby_libarchdir}/continuation.so
%{ruby_libarchdir}/coverage.so
%{ruby_libarchdir}/curses.so
%{ruby_libarchdir}/date_core.so
%{ruby_libarchdir}/dbm.so
%dir %{ruby_libarchdir}/digest
%{ruby_libarchdir}/digest.so
%{ruby_libarchdir}/digest/bubblebabble.so
%{ruby_libarchdir}/digest/md5.so
%{ruby_libarchdir}/digest/rmd160.so
%{ruby_libarchdir}/digest/sha1.so
%{ruby_libarchdir}/digest/sha2.so
%dir %{ruby_libarchdir}/dl
%{ruby_libarchdir}/dl.so
%{ruby_libarchdir}/dl/callback.so
%dir %{ruby_libarchdir}/enc
%{ruby_libarchdir}/enc/big5.so
%{ruby_libarchdir}/enc/cp949.so
%{ruby_libarchdir}/enc/emacs_mule.so
%{ruby_libarchdir}/enc/encdb.so
%{ruby_libarchdir}/enc/euc_jp.so
%{ruby_libarchdir}/enc/euc_kr.so
%{ruby_libarchdir}/enc/euc_tw.so
%{ruby_libarchdir}/enc/gb18030.so
%{ruby_libarchdir}/enc/gb2312.so
%{ruby_libarchdir}/enc/gbk.so
%{ruby_libarchdir}/enc/iso_8859_1.so
%{ruby_libarchdir}/enc/iso_8859_10.so
%{ruby_libarchdir}/enc/iso_8859_11.so
%{ruby_libarchdir}/enc/iso_8859_13.so
%{ruby_libarchdir}/enc/iso_8859_14.so
%{ruby_libarchdir}/enc/iso_8859_15.so
%{ruby_libarchdir}/enc/iso_8859_16.so
%{ruby_libarchdir}/enc/iso_8859_2.so
%{ruby_libarchdir}/enc/iso_8859_3.so
%{ruby_libarchdir}/enc/iso_8859_4.so
%{ruby_libarchdir}/enc/iso_8859_5.so
%{ruby_libarchdir}/enc/iso_8859_6.so
%{ruby_libarchdir}/enc/iso_8859_7.so
%{ruby_libarchdir}/enc/iso_8859_8.so
%{ruby_libarchdir}/enc/iso_8859_9.so
%{ruby_libarchdir}/enc/koi8_r.so
%{ruby_libarchdir}/enc/koi8_u.so
%{ruby_libarchdir}/enc/shift_jis.so
%dir %{ruby_libarchdir}/enc/trans
%{ruby_libarchdir}/enc/trans/big5.so
%{ruby_libarchdir}/enc/trans/chinese.so
%{ruby_libarchdir}/enc/trans/emoji.so
%{ruby_libarchdir}/enc/trans/emoji_iso2022_kddi.so
%{ruby_libarchdir}/enc/trans/emoji_sjis_docomo.so
%{ruby_libarchdir}/enc/trans/emoji_sjis_kddi.so
%{ruby_libarchdir}/enc/trans/emoji_sjis_softbank.so
%{ruby_libarchdir}/enc/trans/escape.so
%{ruby_libarchdir}/enc/trans/gb18030.so
%{ruby_libarchdir}/enc/trans/gbk.so
%{ruby_libarchdir}/enc/trans/iso2022.so
%{ruby_libarchdir}/enc/trans/japanese.so
%{ruby_libarchdir}/enc/trans/japanese_euc.so
%{ruby_libarchdir}/enc/trans/japanese_sjis.so
%{ruby_libarchdir}/enc/trans/korean.so
%{ruby_libarchdir}/enc/trans/single_byte.so
%{ruby_libarchdir}/enc/trans/transdb.so
%{ruby_libarchdir}/enc/trans/utf8_mac.so
%{ruby_libarchdir}/enc/trans/utf_16_32.so
%{ruby_libarchdir}/enc/utf_16be.so
%{ruby_libarchdir}/enc/utf_16le.so
%{ruby_libarchdir}/enc/utf_32be.so
%{ruby_libarchdir}/enc/utf_32le.so
%{ruby_libarchdir}/enc/windows_1251.so
%{ruby_libarchdir}/enc/windows_31j.so
%{ruby_libarchdir}/etc.so
%{ruby_libarchdir}/fcntl.so
%{ruby_libarchdir}/fiber.so
%{ruby_libarchdir}/fiddle.so
%{ruby_libarchdir}/gdbm.so
%dir %{ruby_libarchdir}/io
%{ruby_libarchdir}/io/nonblock.so
%{ruby_libarchdir}/io/wait.so
%dir %{ruby_libarchdir}/mathn
%{ruby_libarchdir}/mathn/complex.so
%{ruby_libarchdir}/mathn/rational.so
%{ruby_libarchdir}/nkf.so
%{ruby_libarchdir}/objspace.so
%{ruby_libarchdir}/openssl.so
%{ruby_libarchdir}/pathname.so
%{ruby_libarchdir}/pty.so
%dir %{ruby_libarchdir}/racc
%{ruby_libarchdir}/racc/cparse.so
%{ruby_libarchdir}/rbconfig.rb
%{ruby_libarchdir}/readline.so
%{ruby_libarchdir}/ripper.so
%{ruby_libarchdir}/sdbm.so
%{ruby_libarchdir}/socket.so
%{ruby_libarchdir}/stringio.so
%{ruby_libarchdir}/strscan.so
%{ruby_libarchdir}/syslog.so
%exclude %{ruby_libarchdir}/tcltklib.so
%exclude %{ruby_libarchdir}/tkutil.so
%{ruby_libarchdir}/zlib.so

%{tapset_root}

%dir %{ruby_libdir}/gems
%dir %{ruby_libdir}/gems/specifications
%dir %{ruby_libdir}/gems/specifications/default
%{ruby_libdir}/gems/specifications/default/test-unit-*.gemspec

%files -n rubygems
%{_bindir}/gem
%{rubygems_dir}
%{ruby_libdir}/gems/*
%{ruby_libdir}/rubygems/*

%files -n rubygems-devel
%{_sysconfdir}/rpm/macros.rubygems

%files -n rubygem-rake
%{_bindir}/rake
%{ruby_libdir}/rake
%{ruby_libdir}/gems/specifications/default/rake-%{rake_version}.gemspec
%{_mandir}/man1/rake.1*

%files irb
%{_bindir}/irb
%{ruby_libdir}/irb.rb
%{ruby_libdir}/irb
%{_mandir}/man1/irb.1*

%files -n rubygem-rdoc
%{_bindir}/rdoc
%{_bindir}/ri
%{ruby_libdir}/rdoc
%{ruby_libdir}/gems/specifications/default/rdoc-%{rdoc_version}.gemspec
%{_mandir}/man1/ri*

%files doc
%doc README
%lang(ja) %doc README.ja
%doc ChangeLog
%doc doc/ChangeLog-*
%doc ruby-exercise.stp
%{_datadir}/ri/*
%{_datadir}/doc/ruby/capi/*

%files -n rubygem-bigdecimal
%{ruby_libdir}/bigdecimal
%{ruby_libarchdir}/bigdecimal.so
%{ruby_libdir}/gems/specifications/default/bigdecimal-%{bigdecimal_version}.gemspec

%files -n rubygem-io-console
%{ruby_libdir}/io
%{ruby_libarchdir}/io/console.so
%{ruby_libdir}/gems/specifications/default/io-console-%{io_console_version}.gemspec

%files -n rubygem-json
%{_libdir}/ruby/json
%{ruby_libdir}/json
%{ruby_libdir}/gems/specifications/default/json-%{json_version}.gemspec

%files -n rubygem-minitest
%{ruby_libdir}/minitest
%{ruby_libdir}/gems/specifications/default/minitest-%{minitest_version}.gemspec

%files -n rubygem-psych
%{_libdir}/ruby/psych.so
%{ruby_libdir}/psych
%{ruby_libdir}/gems/specifications/default/psych-%{psych_version}.gemspec

%files tcltk
%{ruby_libdir}/*-tk.rb
%{ruby_libdir}/tcltk.rb
%{ruby_libdir}/tk*.rb
%{ruby_libarchdir}/tcltklib.so
%{ruby_libarchdir}/tkutil.so
%{ruby_libdir}/tk
%{ruby_libdir}/tkextlib

%changelog
* Thu Jan 23 2014 John Terpstra <John_Terpstra@dell.com>
- Packaged patches in an awkward way
EOF
