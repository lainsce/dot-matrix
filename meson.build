project('io.github.lainsce.DotMatrix', 'vala',
        version: '3.1.4',
        meson_version: '>= 0.59.0'
)
gnome = import('gnome')
i18n = import('i18n')

add_project_arguments([
		'--target-glib=2.68',
	],
	language: 'vala',
)

if get_option('development')
  app_id = 'io.github.lainsce.DotMatrix.Devel'
  name_suffix = ' (Development)'
else
  app_id = 'io.github.lainsce.DotMatrix'
  name_suffix = ''
endif

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('NAME_SUFFIX', name_suffix)
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', app_id)
conf.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
conf.set10('DEVELOPMENT', get_option('development'))
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

add_project_arguments(
  '-include', 'config.h',
  '-DGETTEXT_PACKAGE="@0@"'.format(app_id),
  language: 'c'
)

asresources = gnome.compile_resources(
  'as-resources', 'data/io.github.lainsce.DotMatrix.gresource.xml',
  source_dir: 'data',
  c_name: 'as'
)

sources = [
  'src/Application.vala',
  'src/MainWindow.vala',
  'src/Services/SettingsManager.vala',
  'src/Widgets/Prefs.vala',
  'src/Widgets/UI.vala',
  'src/Widgets/Menu.vala',
]

dependencies = [
  dependency('gtk4'),
  dependency('gee-0.8'),
  dependency('libadwaita-1'),
  meson.get_compiler('c').find_library('m', required: true)
]

executable(
  meson.project_name(),
  sources,
  asresources,
  dependencies: dependencies,
  vala_args: [meson.project_source_root() + '/src/Config.vapi'],
  install : true
)

subdir('data')
subdir('po')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true
)
