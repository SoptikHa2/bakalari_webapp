if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/offlineServiceWorker.js');
} else {
    console.log('Cannot register service worker. Offline cache won\'t be available.');
}
