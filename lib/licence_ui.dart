part of 'main.dart';

class LicenceGate extends StatefulWidget {
  const LicenceGate({super.key});
  @override
  State<LicenceGate> createState() => _LicenceGateState();
}

class _LicenceGateState extends State<LicenceGate> with WidgetsBindingObserver {
  final service = LicenceService.instance;
  bool ready = false;
  Timer? timer;
  DateTime refreshed = DateTime.now();
  GlobalKey<NavigatorState> navigator = GlobalKey();
  String generation = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    service.addListener(changed);
    service.load().whenComplete(() {
      if (mounted) setState(() => ready = true);
    });
    timer = Timer.periodic(const Duration(seconds: 30), (_) {
      service.recheck();
      if (DateTime.now().difference(refreshed) > const Duration(days: 1)) {
        refreshed = DateTime.now();
        service.refresh();
      }
    });
  }

  void changed() {
    final p = service.policy;
    final g =
        '${p.usable}:${p.claims?['id']}:${p.tier}:${p.claims?['revision']}';
    if (g != generation) {
      generation = g;
      navigator = GlobalKey();
    }
    if (mounted) setState(() => ready = ready || p.usable);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      service.recheck();
      refreshed = DateTime.now();
      service.refresh();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    service.removeListener(changed);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ready)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!service.policy.usable) return const LicencePage();
    return NavigatorPopHandler(
        onPopWithResult: (_) => navigator.currentState?.maybePop(),
        child: Navigator(
            key: navigator,
            onGenerateRoute: (_) =>
                MaterialPageRoute(builder: (_) => const HomePage())));
  }
}

class LicencePage extends StatefulWidget {
  const LicencePage({super.key});
  @override
  State<LicencePage> createState() => _LicencePageState();
}

class _LicencePageState extends State<LicencePage> {
  final keyInput = TextEditingController();
  bool busy = false;
  String? message;
  Future<void> run(Future<void> Function() fn) async {
    setState(() => busy = true);
    try {
      await fn();
      if (mounted) setState(() => message = 'Accès vérifié.');
    } catch (e) {
      if (mounted) setState(() => message = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    keyInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LicenceService.instance;
    final p = s.policy;
    return Scaffold(
        appBar: AppBar(title: const Text('Mon accès LapiGestion')),
        body: Scenic(
            child: ListView(padding: const EdgeInsets.all(16), children: [
          LapiSurface(
              kind: LapiFrameKind.panel,
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('LapiGestion',
                            style: TextStyle(
                                fontFamily: 'LapiEditorial',
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        Text(p.label,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        const Text(
                            'Accès offert en remerciement d’une donation vérifiée manuellement par Les Lapibreizh. Aucun paiement dans l’application.'),
                        if (!s.configured)
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                  'Le service de licences n’est pas encore configuré dans cette version. Lis LIRE_AVANT_INSTALLATION.md avant de générer l’APK.',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold))),
                        if (!p.owner) ...[
                          const SizedBox(height: 16),
                          TextField(
                              controller: keyInput,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                  labelText: 'Clé personnelle')),
                          FilledButton(
                              onPressed: busy
                                  ? null
                                  : () => run(() => s.activate(keyInput.text)),
                              child: const Text('Activer ma clé'))
                        ],
                        OutlinedButton(
                            onPressed: busy ? null : () => run(s.refresh),
                            child: const Text('Vérifier mon accès en ligne')),
                        const SizedBox(height: 12),
                        const Text(
                            'Après réinstallation : demande aux Lapibreizh de libérer ton ancienne installation et de te transmettre une nouvelle clé. Les mises à jour conservent l’activation.'),
                        if (message != null || s.error != null)
                          Text(message ?? s.error!,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                            onPressed: busy
                                ? null
                                : () => run(() async {
                                      final f =
                                          await BackupService.createBackup();
                                      await Share.shareXFiles([XFile(f.path)],
                                          text: 'Sauvegarde LapiGestion');
                                    }),
                            icon: const Icon(Icons.backup_outlined),
                            label: const Text('Sauvegarder mes données')),
                        if (busy) const LinearProgressIndicator()
                      ])))
        ])));
  }
}
