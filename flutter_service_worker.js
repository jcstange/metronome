'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "index.html": "a01d754ff8b2ffe82dd90a96a458fc6b",
"/": "a01d754ff8b2ffe82dd90a96a458fc6b",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"assets/assets/sounds/widefngr.wav": "bab8ce1ebeb920bbb420f18f842e5b9d",
"assets/FontManifest.json": "01700ba55b08a6141f33e168c4a6c22f",
"assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"assets/AssetManifest.json": "ca1de78b6db4bb6a149de6ec7d271fee",
"assets/LICENSE": "ba39bd1e579217bbb79f0c8db26093b5",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"main.dart.js": "9cdb70e97dc03dc802f97fff561860df",
"manifest.json": "dbb41d3745a6a62f6141fed5161a5413"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
