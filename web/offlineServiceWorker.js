// NOTE: This has to be placed in / (root directory), 
// as service workers can only work in current directory (or subdirectories).
// By placing this file here, we can ensure it'll work for every page.

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