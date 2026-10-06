import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'licence_config.dart';

class LicenceException implements Exception {
  final String message;
  const LicenceException(this.message);
  @override
  String toString() => message;
}

class LicencePolicy {
  final Map<String, dynamic>? claims;
  const LicencePolicy(this.claims);
  String get tier => claims?['tier']?.toString() ?? '';
  bool get owner => tier == 'owner' && usable;
  bool get usable =>
      claims != null &&
      ['1', '2', '3', '4', 'owner'].contains(tier) &&
      (tier == 'owner'
          ? claims!['exp'] == null
          : (claims!['exp'] is int &&
              (claims!['exp'] as int) >
                  DateTime.now().millisecondsSinceEpoch ~/ 1000));
  bool get breeding => usable && ['3', '4', 'owner'].contains(tier);
  int? get rabbitLimit => tier == '1' ? 1 : null;
  int? get breederLimit => tier == '3' ? 2 : null;
  String get label =>
      {
        '1': 'Adoptant / 1 lapin',
        '2': 'Adoptant illimité',
        '3': 'Complète / 2 reproducteurs actifs',
        '4': 'Complète illimitée',
        'owner': 'PROPRIÉTAIRE / ADMIN'
      }[tier] ??
      'Non activée';
  void requireUsable() {
    if (!usable)
      throw const LicenceException(
          'Active ta licence ou renouvelle son contrôle en ligne. Tes données sont conservées.');
  }

  void requireBreeding() {
    requireUsable();
    if (!breeding)
      throw const LicenceException(
          'Cette fonction nécessite un accès au mode Élevage.');
  }

  static bool active(Map<String, dynamic> r) =>
      r['activeBreeder'] == true &&
      ['Mâle', 'Femelle'].contains(r['sex']) &&
      r['sterilized'] != 'Stérilisé(e)' &&
      r['adoptionStatus'] != 'Adopté / parti';
  void requireWritable(int count) {
    requireUsable();
    if (rabbitLimit != null && count > rabbitLimit!)
      throw const LicenceException(
          'Cette licence permet une seule fiche. Les fiches existantes restent consultables et sauvegardables.');
  }

  void checkRabbits(
      List<Map<String, dynamic>> previous, List<Map<String, dynamic>> next,
      {bool restoring = false}) {
    requireUsable();
    final ids = previous.map((r) => r['id']).toSet();
    final newCount = next.where((r) => !ids.contains(r['id'])).length;
    if (rabbitLimit != null &&
        (next.length > rabbitLimit!) &&
        (restoring || newCount > 0 || next.length >= previous.length))
      throw const LicenceException(
          'Le niveau Adoptant / 1 lapin autorise une seule fiche. Aucune donnée n’a été supprimée.');
    final oldActive = previous.where(active).map((r) => r['id']).toSet();
    final nextActive = next.where(active).toList();
    if (!restoring && nextActive.any((r) => !oldActive.contains(r['id']))) {
      requireBreeding();
      if (breederLimit != null && nextActive.length > breederLimit!)
        throw const LicenceException(
            'Cette licence permet 2 reproducteurs actifs simultanément, mâles et femelles réunis.');
    }
    if (restoring && breederLimit != null && nextActive.length > breederLimit!)
      throw const LicenceException(
          'La sauvegarde contient plus de 2 reproducteurs actifs. Modifie leur statut avec un accès complet avant restauration.');
    if (!breeding && !restoring) {
      const fields = [
        'competitions',
        'adoptionStatus',
        'adopterName',
        'adopterContact',
        'departureDate',
        'adoptionNotes',
        'healthBookGiven',
        'healthCertificateGiven',
        'adoptionInfoGiven',
        'engagementRecipientName',
        'engagementRecipientAddress',
        'engagementRecipientEmail',
        'engagementDeliveryDate',
        'engagementSignedDate',
        'engagementPlace',
        'engagementIssuerName',
        'engagementIssuerQualification',
        'engagementIssuerReference',
        'engagementMentionImage',
        'engagementSignatureImage',
        'engagementCertificatePdf',
        'engagementAccepted'
      ];
      for (final r in next) {
        final old = previous.where((e) => e['id'] == r['id']).firstOrNull;
        if (old == null) continue;
        for (final f in fields) {
          if (jsonEncode(old[f]) != jsonEncode(r[f]))
            throw const LicenceException(
                'Cette modification nécessite un accès au mode Élevage.');
        }
      }
    }
  }

  void checkReproduction(List<Map<String, dynamic>> previous,
      List<Map<String, dynamic>> next, List<Map<String, dynamic>> rabbits,
      {bool restoring = false}) {
    requireUsable();
    if (restoring) return;
    if (!breeding) {
      if (next.every(
          (n) => previous.any((p) => jsonEncode(n) == jsonEncode(p)))) return;
      requireBreeding();
    }
    if (breederLimit == null) return;
    for (final r in next) {
      final old = previous.where((p) => p['id'] == r['id']).firstOrNull;
      final newPair = old == null ||
          ['maleId', 'femaleId', 'matingDate'].any((f) => old[f] != r[f]);
      if (!newPair) continue;
      final live = rabbits.where(active).toList();
      if (live.length > breederLimit! ||
          !live.any((e) => e['id'] == r['maleId']) ||
          !live.any((e) => e['id'] == r['femaleId']))
        throw const LicenceException(
            'Choisis deux reproducteurs actifs dans Identité & filiation avant une nouvelle saillie.');
    }
  }
}

class LicenceService extends ChangeNotifier {
  LicenceService._();
  static final instance = LicenceService._();
  static const channel = MethodChannel('fr.leslapibreizh.carnetsante/licences');
  Map<String, dynamic>? _claims;
  String? _id;
  String? error;
  LicencePolicy get policy => LicencePolicy(_claims);
  bool get configured =>
      licenceApiOrigin.startsWith('https://') && licenceSignerSpki.isNotEmpty;
  Future<void> load() async {
    error = null;
    try {
      final p = await channel.invokeMapMethod<String, dynamic>(
          'load', {'signer': licenceSignerSpki});
      _claims = p;
      _id = p?['id']?.toString() ??
          await channel.invokeMethod<String>('identifier');
    } catch (e) {
      _claims = null;
      _id = await channel.invokeMethod<String>('identifier');
      error = 'Contrôle en ligne nécessaire.';
    }
    notifyListeners();
    if (_id != null && configured) await refresh();
  }

  Future<void> recheck() async {
    try {
      _claims = await channel.invokeMapMethod<String, dynamic>(
          'load', {'signer': licenceSignerSpki});
    } catch (_) {
      _claims = null;
    }
    notifyListeners();
  }

  Future<void> activate(String key) async {
    if (policy.owner)
      throw const LicenceException(
          'Ton accès propriétaire permanent est déjà actif.');
    await _request('activate', key.trim());
  }

  Future<void> refresh() async {
    if (_id == null) return;
    try {
      await _request('refresh', _id!);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> value,
      {bool invalidate = false}) async {
    final r = await http
        .post(Uri.parse('$licenceApiOrigin$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(value))
        .timeout(const Duration(seconds: 15));
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    if (r.statusCode >= 400) {
      if (invalidate &&
          path == '/api/authorize' &&
          [403, 404, 409].contains(r.statusCode) &&
          !policy.owner) {
        await channel.invokeMethod('clear', {'signer': licenceSignerSpki});
        _claims = null;
        notifyListeners();
      }
      throw LicenceException((j['error'] ?? 'Licence non activée.').toString());
    }
    return j;
  }

  Future<void> _request(String action, String credential) async {
    if (!configured)
      throw const LicenceException(
          'Le service doit être configuré avant la génération de cette APK. Consulte les instructions de livraison.');
    try {
      final spki = await channel.invokeMethod<String>('identity');
      final challenge = await _post('/api/challenge', {});
      final nonce = challenge['nonce'];
      final message = '$nonce\n$action\n$credential\n$spki';
      final proof =
          await channel.invokeMethod<String>('sign', {'message': message});
      final token = await _post(
          '/api/authorize',
          {
            'action': action,
            'credential': credential,
            'spki': spki,
            'nonce': nonce,
            'proof': proof
          },
          invalidate: action == 'refresh');
      _claims = await channel.invokeMapMethod<String, dynamic>(
          'accept', {'signer': licenceSignerSpki, 'token': token});
      _id = _claims?['id']?.toString();
      error = null;
      notifyListeners();
    } on LicenceException {
      rethrow;
    } catch (_) {
      throw const LicenceException(
          'Connexion ou vérification indisponible. Réessaie avec Internet et une date/heure correctes.');
    }
  }
}
