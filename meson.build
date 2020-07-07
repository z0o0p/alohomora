#Project name, Languages used and Version
project('com.github.z0o0p.alohomora', 'vala', 'c', version: '0.0.1')

# Project arguments
add_project_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()),
    language: 'c'
)

subdir('src')

#Executable
executable(
    meson.project_name(),
    sources,
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('granite'),
        dependency('libsecret-1')
    ],
    install: true
)
