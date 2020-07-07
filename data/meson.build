#GNOME module
gnome = import ('gnome')

#Compiling GResources
alohomora_resources = gnome.compile_resources (
    'alohomora-resources',
    meson.project_name () + '.gresource.xml',
)

#Schema configiration
install_data(
    meson.project_name () + '.gschema.xml',
    install_dir: join_paths (get_option ('datadir'), 'glib-2.0', 'schemas'),
)
