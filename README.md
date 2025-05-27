# sor_inventory
Disable service worker
--
```dart
      window.addEventListener("load", function (ev) {
        // Download main.dart.js
        _flutter.loader
          .loadEntrypoint({
            //fx: disable service worker
            //serviceWorker: {
            //  serviceWorkerVersion: serviceWorkerVersion,
            //}
          })
          .then(function (engineInitializer) {
            return engineInitializer.initializeEngine();
          })
          .then(function (appRunner) {
            return appRunner.runApp();
          });
      });
```
