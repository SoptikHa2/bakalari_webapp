// NOTE: This has to be placed in / (root directory), 
// Service workers can only work in current directory (or subdirectories).
// By placing this file here, we can ensure it'll work for every page.
// TODO: This doesn't work

self.addEventListener('install', function (e) {
    e.waitUntil(
        caches.open('bakalari').then(function (cache) {
            return cache.addAll([
                '/',
                '/student',
                '/js/ui.js',
                '/js/buttonSwitch.js',
                '/css/pure-custom.css',
                '/css/pure-grids-responsive-min.css',
                '/css/pure-min.css',
                '/css/pure-sidemenu.css'])
        }))
});