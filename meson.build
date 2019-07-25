# Name our project
project('com.github.lainsce.dot-matrix', ['vala', 'c'],
    version: '1.2.2'
)

# Import main lib files
gnome = import('gnome')
i18n = import('i18n')

# Compile the GResources for this project
asresources = gnome.compile_resources(
    'as-resources', 'data/style.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

# Set this for convenience
conf = configuration_data()

# Get the package data directory under Meson
pkgdatadir = join_paths([ get_option('prefix'),
                          get_option('datadir'),
                          'com.github.lainsce.dot-matrix' ])

conf.set_quoted('PKGDATADIR', pkgdatadir)

# Other configs
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf
add_global_arguments('-DDATADIR="' + get_option('datadir') + '"', language: 'c')
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

# Arguments for C
c_args = [
  '-include', 'config.h',
  '-w'
]

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required: true)

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
                      language: 'vala')

# Let's define our executable
executable(
    meson.project_name(),
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/Constants/AppSettings.vala',
    'src/Widgets/UI.vala',
    'src/Widgets/EditableLabel.vala',
    asresources,
    c_args: c_args,
    dependencies: [
        dependency('granite'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        m_dep,
    ],
    vala_args: [
        meson.source_root() + '/vapi/config.vapi',
        '--vapidir=' + meson.source_root() + '/vapi/',
    ],
    install : true
)

# Add in a post install script
meson.add_install_script('meson/post_install.py')

# Add subfolders for Meson to look
subdir('data')
subdir('po')
