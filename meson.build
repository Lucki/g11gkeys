project('g11gkeys', 'vala', 'c')

vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gio-2.0'),
    dependency('macro-manager'),
    meson.get_compiler('vala').find_library('posix'),
    meson.get_compiler('c').find_library('libg15'),
    meson.get_compiler('vala').find_library('libg15', dirs: vapi_dir),
]

subdir('src')

executable('g11gkeys',
    sources,
    dependencies: dependencies,
    install: true,
)
