import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class HavaWidget extends StatefulWidget {
  const HavaWidget({super.key});

  @override
  State<HavaWidget> createState() => _HavaWidgetState();
}

class _HavaWidgetState extends State<HavaWidget> {
  Map<String, dynamic>? _hava;
  Map<String, dynamic>? _deniz;
  bool _loading = true;

  // Ünye koordinatları
  static const double _lat = 41.1339;  // Ünye merkez
  static const double _lon = 37.2679;  // Ünye merkez

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dio = Dio();
      final futures = await Future.wait([
        dio.get('https://api.open-meteo.com/v1/forecast', queryParameters: {
          'latitude': _lat, 'longitude': _lon,
          'current': 'temperature_2m,apparent_temperature,precipitation,wind_speed_10m,weathercode',
          'timezone': 'Europe/Istanbul',
        }),
        dio.get('https://marine-api.open-meteo.com/v1/marine', queryParameters: {
          'latitude': _lat, 'longitude': _lon,
          'current': 'wave_height,wind_wave_height',
          'timezone': 'Europe/Istanbul',
        }),
      ]);
      if (mounted) {
        setState(() {
          _hava = futures[0].data['current'];
          _deniz = futures[1].data['current'];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _ikon(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 57) return '🌦️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    if (code <= 82) return '🌦️';
    if (code <= 86) return '🌨️';
    return '⛈️';
  }

  String _durum(int code) {
    if (code == 0) return 'Açık';
    if (code <= 3) return 'Parçalı bulutlu';
    if (code <= 48) return 'Sisli';
    if (code <= 57) return 'Çisenti';
    if (code <= 67) return 'Yağmurlu';
    if (code <= 77) return 'Karlı';
    if (code <= 82) return 'Sağanak';
    return 'Fırtınalı';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 80,
        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16)),
        child: const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    if (_hava == null) return const SizedBox();

    final temp = _hava!['temperature_2m']?.toStringAsFixed(0) ?? '--';
    final hisTemp = _hava!['apparent_temperature']?.toStringAsFixed(0) ?? '--';
    final wind = _hava!['wind_speed_10m']?.toStringAsFixed(0) ?? '--';
    final code = (_hava!['weathercode'] as num?)?.toInt() ?? 0;
    final dalga = _deniz?['wave_height']?.toStringAsFixed(1) ?? '--';

    return GestureDetector(
      onTap: _load,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue[600]!, Colors.blue[400]!]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Text(_ikon(code), style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ünye Hava Durumu', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  Text('${temp}°C  ${_durum(code)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Hissedilen: ${hisTemp}°C', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(children: [
                  const Icon(Icons.air, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text('$wind km/s', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.waves, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text('$dalga m', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
