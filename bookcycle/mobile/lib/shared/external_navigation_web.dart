// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

bool openExternalUrl(String url, {bool sameTab = false}) {
  html.window.open(url, sameTab ? '_self' : '_blank');
  return true;
}
