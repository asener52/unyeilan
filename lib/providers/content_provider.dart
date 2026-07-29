import 'package:flutter/material.dart';
import '../models/icerik.dart';
import '../models/kategori.dart';
import '../models/mahalle.dart';
import '../models/eczane.dart';
import '../models/harita.dart';
import '../services/api_service.dart';

class ContentProvider extends ChangeNotifier {
  List<Icerik> _icerikler = [];
  List<Kategori> _kategoriler = [];
  List<Mahalle> _mahalles = [];
  List<Map<String, dynamic>> _bildirimler = [];
  List<Eczane> _eczaneler = [];
  List<HaritaKategori> _haritaKategoriler = [];
  List<HaritaNokta> _haritaNoktalar = [];
  Set<int> _engelliKategoriIds = {};

  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _sayfa = 1;
  int _toplamSayfa = 1;
  String? _aktifKategori;

  List<Icerik> get icerikler => _icerikler;
  List<Kategori> get kategoriler => _kategoriler;
  List<Mahalle> get mahalles => _mahalles;
  List<Map<String, dynamic>> get bildirimler => _bildirimler;
  List<Eczane> get eczaneler => _eczaneler;
  List<HaritaKategori> get haritaKategoriler => _haritaKategoriler;
  List<HaritaNokta> get haritaNoktalar => _haritaNoktalar;
  Set<int> get engelliKategoriIds => _engelliKategoriIds;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  bool get hasMore => _sayfa < _toplamSayfa;
  String? get aktifKategori => _aktifKategori;

  int get okunmamisBildirimSayisi =>
      _bildirimler.where((b) => b['okundu'] == false).length;

  Future<void> loadKategoriler() async {
    try {
      _kategoriler = await ApiService().getKategoriler();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadMahalles() async {
    try {
      _mahalles = await ApiService().getMahalles();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadIcerikler({
    String? kategori,
    int? mahalleId,
    bool refresh = false,
  }) async {
    if (refresh || kategori != _aktifKategori) {
      _icerikler = [];
      _sayfa = 1;
      _aktifKategori = kategori;
    }
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final resp = await ApiService().getIcerikler(
        kategori: kategori,
        mahalleId: mahalleId,
        sayfa: _sayfa,
      );
      _icerikler = resp.data;
      _toplamSayfa = resp.toplamSayfa;
    } catch (e) {
      _error = 'İçerikler yüklenemedi';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore({int? mahalleId}) async {
    if (!hasMore || _loadingMore) return;
    _loadingMore = true;
    _sayfa++;
    notifyListeners();
    try {
      final resp = await ApiService().getIcerikler(
        kategori: _aktifKategori,
        mahalleId: mahalleId,
        sayfa: _sayfa,
      );
      _icerikler.addAll(resp.data);
      _toplamSayfa = resp.toplamSayfa;
    } catch (_) {
      _sayfa--;
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadBildirimler() async {
    try {
      _bildirimler = await ApiService().getBildirimler();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> bildirimOku(int id) async {
    final idx = _bildirimler.indexWhere((b) => b['id'] == id);
    if (idx != -1) {
      _bildirimler[idx] = {..._bildirimler[idx], 'okundu': true};
      notifyListeners();
    }
    await ApiService().bildirimOku(id);
  }

  Future<void> bildirimSil(int id) async {
    _bildirimler.removeWhere((b) => b['id'] == id);
    notifyListeners();
    await ApiService().bildirimSil(id);
  }

  Future<void> bildirimlerTumunuOku() async {
    for (int i = 0; i < _bildirimler.length; i++) {
      _bildirimler[i] = {..._bildirimler[i], 'okundu': true};
    }
    notifyListeners();
    try { await ApiService().bildirimlerTumunuOku(); } catch (_) {}
  }

  Future<void> loadKategoriEngelleme() async {
    try {
      final data = await ApiService().getKategoriEngelleme();
      _engelliKategoriIds = data.map((e) => e['id'] as int).toSet();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updateKategoriEngelleme(Set<int> ids) async {
    _engelliKategoriIds = ids;
    notifyListeners();
    await ApiService().updateKategoriEngelleme(ids.toList());
  }

  Future<void> loadEczaneler({String? tarih}) async {
    try {
      _eczaneler = await ApiService().getEczaneler(tarih: tarih);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadHarita({int? kategoriId}) async {
    try {
      if (_haritaKategoriler.isEmpty) {
        _haritaKategoriler = await ApiService().getHaritaKategoriler();
      }
      _haritaNoktalar = await ApiService().getHaritaNoktalar(kategoriId: kategoriId);
      notifyListeners();
    } catch (_) {}
  }

  Future<Icerik?> getIcerikDetail(int id) async {
    try {
      return await ApiService().getIcerik(id);
    } catch (_) {
      return null;
    }
  }
}
