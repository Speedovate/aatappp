{{flutter_js}}
{{flutter_build_config}}

const userAgent = navigator.userAgent || "";
const isMetaInAppBrowser = /FBAN|FBAV|Messenger|Instagram/i.test(userAgent);

_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
  },
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
  },
});

if (isMetaInAppBrowser) {
  document.documentElement.setAttribute("data-meta-inapp", "true");
}
