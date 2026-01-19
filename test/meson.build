# Unit tests
unit_tests = executable (
    meson.project_name () + '-unit-tests',
    'ApplicationTest.vala',
    'Helpers/CipherManagerTest.vala',
    meson.project_source_root () + '/src/Helpers/CipherManager.vala',
    dependencies: [
        dependency ('gtk4')
    ],
    install: true
)

test ('Unit tests', unit_tests)
