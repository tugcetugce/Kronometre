import 'dart:async';
import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const StopwatchApp());

class StopwatchApp extends StatelessWidget {
  const StopwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
        Locale('de'),
        Locale('fr'),
        Locale('zh'),
        Locale('ru'),
        Locale('el'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const StopwatchPage(),
       locale: const Locale('el'),
    );
  }
}

class L10n {
  final String code;
  L10n(this.code);

  factory L10n.of(BuildContext context) {
    final lc = Localizations.localeOf(context).languageCode.toLowerCase();
    return L10n(lc);
  }

  bool get tr => code == 'tr';
  bool get de => code == 'de';
  bool get fr => code == 'fr';
  bool get zh => code == 'zh';
  bool get ru => code == 'ru';
  bool get el => code == 'el';

  String get appTitle =>
      zh ? '秒表'
    : ru ? 'Секундомер'
    : el ? 'Χρονόμετρο'
    : fr ? 'Chronomètre'
    : de ? 'Stoppuhr'
    : tr ? 'Kronometre'
    : 'Stopwatch';

  String get start =>
      zh ? '开始'
    : ru ? 'Старт'
    : el ? 'Έναρξη'
    : fr ? 'Démarrer'
    : de ? 'Start'
    : tr ? 'Başlat'
    : 'Start';

  String get pause =>
      zh ? '暂停'
    : ru ? 'Пауза'
    : el ? 'Παύση'
    : fr ? 'Pause'
    : de ? 'Pause'
    : tr ? 'Duraklat'
    : 'Pause';

  String get reset =>
      zh ? '重置'
    : ru ? 'Сброс'
    : el ? 'Επαναφορά'
    : fr ? 'Réinitialiser'
    : de ? 'Zurücksetzen'
    : tr ? 'Sıfırla'
    : 'Reset';

  String get lap =>
      zh ? '圈'
    : ru ? 'Круг'
    : el ? 'Γύρος'
    : fr ? 'Tour'
    : de ? 'Runde'
    : tr ? 'Tur'
    : 'Lap';

  String get noLaps =>
      zh ? '暂无圈数'
    : ru ? 'Пока нет кругов'
    : el ? 'Δεν υπάρχουν γύροι ακόμη'
    : fr ? 'Pas encore de tours'
    : de ? 'Noch keine Runden'
    : tr ? 'Henüz tur yok'
    : 'No laps yet';
}

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  final List<Duration> _laps = [];

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _ticker ??= Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  void _pause() {
    _stopwatch.stop();
    setState(() {});
  }

  void _reset() {
    _stopwatch
      ..stop()
      ..reset();
    _laps.clear();
    setState(() {});
  }

  void _lap() {
    if (_stopwatch.isRunning) {
      _laps.insert(0, _stopwatch.elapsed);
      setState(() {});
    }
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final ms = (d.inMilliseconds.remainder(1000) / 10).floor(); // 2 hane
    final hh = h > 0 ? '${h.toString().padLeft(2, '0')}:' : '';
    return '$hh${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}.'
        '${ms.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    final elapsed = _stopwatch.elapsed;
    final running = _stopwatch.isRunning;

    return Scaffold(
      appBar: AppBar(title: Text(t.appTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            FittedBox(
              child: Text(
                _format(elapsed),
                style: const TextStyle(
                  fontSize: 72,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonalIcon(
                  onPressed: running ? _pause : _start,
                  icon: Icon(running ? Icons.pause : Icons.play_arrow),
                  label: Text(running ? t.pause : t.start),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.restart_alt),
                  label: Text(t.reset),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: running ? _lap : null,
                  icon: const Icon(Icons.flag),
                  label: Text(t.lap),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _laps.isEmpty
                  ? Center(
                      child: Text(
                        t.noLaps,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _laps.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final lap = _laps[index];
                        final lapNo = _laps.length - index;
                        return ListTile(
                          dense: true,
                          leading: Text('#$lapNo'),
                          title: Text(_format(lap)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}