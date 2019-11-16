project('com.github.mohelm97.screenrecorder', 'vala', 'c', version: '0.2.1')

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

asresources = gnome.compile_resources(
    'as-resources',
    join_paths('data', meson.project_name()) + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

dependencies = [
    dependency('gee-0.8'),
    dependency('granite'),
    dependency('gtk+-3.0'),
    dependency('x11'),
    dependency('gdk-x11-3.0'),
    dependency('gstreamer-1.0'),
    dependency('clutter-gst-3.0'),
    dependency('clutter-gtk-1.0')
]

subdir('src')

executable(
    meson.project_name(),
    asresources,
    sources,
    dependencies: dependencies,
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
