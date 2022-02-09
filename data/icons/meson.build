icondir = join_paths(get_option('datadir'), 'icons/hicolor')

install_data(
  '@0@.svg'.format(app_id),
  install_dir: join_paths(icondir, 'scalable/apps'),
)

install_data(
  meson.project_name() + '-symbolic.svg',
  install_dir: join_paths(icondir, 'symbolic/apps'),
  rename: '@0@-symbolic.svg'.format(app_id),
)

subdir('hicolor')
