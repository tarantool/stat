Name: tarantool-stat
Version: 0.1
Release: 1%{?dist}
Summary: Tarantool Stat module
Group: Applications/Databases
License: BSD
URL: https://github.com/tarantool/stat
Source0: https://github.com/tarantool/stat/archive/%{version}/stat-%{version}.tar.gz
BuildRequires: cmake >= 2.8
BuildRequires: tarantool >= 1.7.2.0
BuildRequires: tarantool-devel
Requires: tarantool >= 1.7.2.0

%description
The human-readable module for getting Tarantool's status

%prep
%setup -q -n stat-%{version}

%build
%cmake . -DCMAKE_BUILD_TYPE=RelWithDebInfo

%install
%make_install

%files
%{_libdir}/tarantool/*/
%{_datarootdir}/tarantool/*/
%doc README.md
%{!?_licensedir:%global license %doc}
%license LICENSE

%changelog
* Mon Dec 04 2017 Alexander Opryshko <alexopryshko@yandex.ru> 0.1
- Initial version of the RPM spec
