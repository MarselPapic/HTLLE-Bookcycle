import 'external_navigation_stub.dart'
    if (dart.library.html) 'external_navigation_web.dart' as impl;

bool openExternalUrl(String url, {bool sameTab = false}) {
  return impl.openExternalUrl(url, sameTab: sameTab);
}
