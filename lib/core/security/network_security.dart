import 'package:http/http.dart' as http;

// Certificate pinning placeholder — wire up when VPS is ready.
// To enable: replace createClient() body with the commented block below
// and place the server certificate at assets/certs/server.crt.
class SecureHttpClient {
  static http.Client createClient() {
    /*
    final context = SecurityContext(withTrustedRoots: false);
    context.setTrustedCertificatesBytes(
      File('assets/certs/server.crt').readAsBytesSync(),
    );
    final httpClient = HttpClient(context: context)
      ..badCertificateCallback = (cert, host, port) => false;
    return IOClient(httpClient);
    */
    return http.Client();
  }
}
