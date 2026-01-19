# Project name, Languages used and Version
project ('io.github.z0o0p.alohomora', 'vala', 'c', version: '2.0.0', meson_version: '>= 0.57.0')

# Executes build files in given directories
subdir ('src')
subdir ('po')
subdir ('data')

# Executable
executable (
    meson.project_name (),
    sources,
    alohomora_resources,
    dependencies: [
        dependency ('gtk4'),
        dependency ('granite-7'),
        dependency ('libsecret-1')
    ],
    install: true
)

subdir ('test')
