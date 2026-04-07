import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  Future<void> launchUrlString(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
    }
  }

  Future<void> openHelpAndSupport() async {
    await launchUrlString('https://furiouss.in');
  }
}
