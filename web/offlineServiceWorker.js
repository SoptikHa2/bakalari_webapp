// NOTE: This has to be placed in / (root directory), 
// Service workers can only work in current directory (or subdirectories).
// By placing this file here, we can ensure it'll work for every page.

// https://jakearchibald.com/2014/offline-cookbook/

self.addEventListener('install', function (e) {
    e.waitUntil(
        caches.open('bakalari').then(function (cache) {
            return cache.addAll([
                '/',
                '/student',
                '/js/studentRefresh.js',
                '/js/subjectDetails.js',
                '/js/switchTimetableDisplay.js',
                '/css/pure-custom.css',
                '/css/pure-grids-responsive-min.css',
                '/css/pure-min.css',
                '/css/google-material-design-icons.css',
                '/other/google-material-design-icons.woff2',
                '/other/signout-icon.png',
                '/css/pure-sidemenu.css',
                '/favicon.ico'])
        }))
});

self.addEventListener('fetch', (event) => {
    event.respondWith(async function() {
      try {
        return await fetch(event.request);
      } catch (err) {
        return caches.match(event.request);
      }
    }());
  });
