#Project name, Languages used and Version
project ('com.github.z0o0p.alohomora', 'vala', 'c', version: '0.0.1')

# Translation module
i18n = import ('i18n')

# Project arguments
add_project_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()),
    language: 'c'
)

#Executes build files in given directories
subdir ('src')
subdir ('data')

#Executable
executable (
    meson.project_name (),
    sources,
    alohomora_resources,
    dependencies: [
        dependency ('gtk+-3.0'),
        dependency ('granite'),
        dependency ('libsecret-1')
    ],
    install: true
)

subdir ('po')

meson.add_install_script ('meson/post_install.py')
