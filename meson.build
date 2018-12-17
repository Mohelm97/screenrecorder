# project name and programming language
project('com.github.mohelm97.screenrecorder', 'vala', 'c')
# Include the translations module
i18n = import('i18n')
gnome = import('gnome')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

icon_res = gnome.compile_resources(
    'screenrecorder-icon-resources',
    'data/' + meson.project_name() + '.gresource.xml',
    source_dir: 'data'
)

# Adding deps
message ('Listing dependencies')

dependencies = [
    dependency('granite'),
    dependency('gtk+-3.0'),
    dependency('x11'),
    dependency('gdk-x11-3.0'),
    dependency('gstreamer-1.0'),
    dependency('clutter-gst-3.0'),
    dependency('clutter-gtk-1.0')
]

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    icon_res,
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/FFmpegWrapper.vala',
    'src/SaveDialog.vala',
    'src/Widgets/SelectionArea.vala',
    'src/Widgets/VideoPlayer.vala',
    'src/Widgets/FormatComboBox.vala',
    'src/Utils/KeybindingManager.vala',
    dependencies: dependencies,
    install: true
)

#Translate and install our .desktop file
i18n.merge_file(
    input: join_paths('data', meson.project_name() + '.desktop.in'),
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

#Translate and install our .appdata file
i18n.merge_file(
    input: join_paths('data', meson.project_name() + '.appdata.xml.in'),
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

install_data(
    join_paths('data',  meson.project_name() + '.gschema.xml'),
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)

#Install Icons
icon_sizes = ['32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        join_paths('data/icons', i, 'com.github.mohelm97.screenrecorder.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
endforeach

subdir('po')
meson.add_install_script('meson/post_install.py')
