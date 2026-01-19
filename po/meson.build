# Import translations module
i18n = import ('i18n')

# Configure arguments for translations
add_global_arguments ('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()), language:'c')

# Install main translations
i18n.gettext (
    meson.project_name (),
    args: '--directory=' + meson.project_source_root (),
    preset: 'glib'
)

subdir ('extra')
