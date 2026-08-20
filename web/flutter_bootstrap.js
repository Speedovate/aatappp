{{flutter_js}}
{{flutter_build_config}}

const userAgent = navigator.userAgent || "";
const isSocialInAppBrowser =
  /FBAN|FBAV|Messenger|Instagram|Line\/|Line |MicroMessenger|WeChat|Viber|Telegram|Twitter|X\/|Snapchat|LinkedInApp/i.test(
    userAgent,
  );

window.__AATAPPP_SOCIAL_INAPP__ = isSocialInAppBrowser;

if (isSocialInAppBrowser) {
  document.documentElement.setAttribute("data-social-inapp", "true");
} else {
  _flutter.loader.load({
    config: {
      canvasKitBaseUrl: "canvaskit/",
    },
    onEntrypointLoaded: async function (engineInitializer) {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
    },
  });
}
