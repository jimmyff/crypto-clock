import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'dart:convert';

import 'package:http/browser_client.dart' as http;

/// Handles loading & saving of settings and settings UI
class CryptoClockSettings {
  http.BrowserClient client;
  //settings
  late List<Map<String, dynamic>> symbols;
  late List<Map<String, dynamic>> symbolsDraft;
  late int interval;
  late int intervalDraft;
  List<int> intervalOptions = [5, 10, 20, 30, 45, 60, 90, 120, 240, 300, 600];
  late int intervalsPerSymbol;
  late int intervalsPerSymbolDraft;
  List<int> intervalsPerSymbolDraftOptions = List.generate(20, (i) => i + 1);

  // UI
  late Element intervalElement;
  late Element intervalsPerSymbolElement;

  // Defaults
  static const _defaultInterval = 60;
  static const _defaultIntervalsPerSymbol = 2;
  static const List<Map<String, dynamic>> _defaultSymbols = [
    {
      'symbol': 'BTCUSDT',
      'baseAsset': 'BTC',
      'quoteAsset': 'USDT',
    },
    {
      'symbol': 'ETHUSDT',
      'baseAsset': 'ETH',
      'quoteAsset': 'USDT',
    },
    {
      'symbol': 'BTCGBP',
      'baseAsset': 'BTC',
      'quoteAsset': 'GBP',
    },
    {
      'symbol': 'ETHBTC',
      'baseAsset': 'ETH',
      'quoteAsset': 'BTC',
    },
  ];
  CryptoClockSettings(this.client) {
    symbols = [];
    _initSettingsFromStorage();
  }

  void _saveSettings() {
    window.localStorage['symbols'] = json.encode(symbolsDraft);
    window.localStorage['interval'] = intervalElement.text!;
    window.localStorage['intervalsPerSymbol'] = intervalsPerSymbolElement.text!;
    window.location.reload();
  }

  void _initSettingsFromStorage() {
    // Load settings/defaults
    window.localStorage['symbols'] ??= json.encode(_defaultSymbols);
    window.localStorage['interval'] ??= _defaultInterval.toString();
    window.localStorage['intervalsPerSymbol'] ??=
        _defaultIntervalsPerSymbol.toString();
    symbols = (json.decode(window.localStorage['symbols']!) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    symbolsDraft =
        (json.decode(window.localStorage['symbols']!) as List<dynamic>)
            .cast<Map<String, dynamic>>();
    interval = int.parse(window.localStorage['interval']!);
    intervalsPerSymbol = int.parse(window.localStorage['intervalsPerSymbol']!);

    _initDom();
  }

  Future _loadAllSymbols() async {
    List<Map<String, dynamic>> allSymbols = [];
    try {
      var response = await client
          .get(Uri.parse('https://api.binance.com/api/v3/exchangeInfo'));
      final data = json.decode(response.body);
      allSymbols = (data['symbols'] as List)
          .cast<Map<String, dynamic>>()
          .where((s) => s['status'] == 'TRADING')
          .toList();
      allSymbols.sort((s1, s2) => s1['symbol'].compareTo(s2['symbol']));
    } finally {
      client.close();
    }

    querySelector('#symbols_all')!
        .children
        .addAll(allSymbols.map((s) => ButtonElement()
          ..innerHtml = s['symbol']
          ..classes.add('symbol')
          ..onClick.listen((e) {
            if (window.confirm('Add symbol ${s['symbol']}?')) {
              symbolsDraft.add(s);
              _refreshSymbolsDraft();
            }
          })));
  }

  void _refreshSymbolsDraft() {
    querySelector('#symbols_current')!.children = symbolsDraft
        .map((s) => ButtonElement()
          ..innerHtml = s['symbol']
          ..classes.add('symbol')
          ..onClick.listen((e) {
            if (window.confirm('Remove symbol ${s['symbol']}?')) {
              symbolsDraft.removeWhere((sd) => sd['symbol'] == s['symbol']);
              _refreshSymbolsDraft();
            }
          }))
        .toList();
  }

  void _initDom() {
    querySelector('#reset')!.onClick.listen((event) {
      window.localStorage['symbols'] = json.encode(_defaultSymbols);
      window.localStorage['interval'] = _defaultInterval.toString();
      window.localStorage['intervalsPerSymbol'] =
          _defaultIntervalsPerSymbol.toString();
      window.location.reload();
    });
    querySelector('#close')!.onClick.listen((event) {
      querySelector('#settings')!.classes.remove('visible');
    });
    querySelector('#save')!.onClick.listen((event) {
      _saveSettings();
    });

    querySelector('#refresh')!.onClick.listen((event) {
      window.location.reload();
    });

    querySelector('#load_symbols')!.onClick.listen((event) {
      _loadAllSymbols();
      querySelector('#load_symbols')!.style.display = 'none';
    });

    _refreshSymbolsDraft();

    intervalElement = querySelector('#interval')!
      ..innerText = interval.toString();
    intervalsPerSymbolElement = querySelector('#intervals_per_element')!
      ..innerText = intervalsPerSymbol.toString();

    T _changeValue<T>(T opt, List<T> opts, int change) {
      final idx = opts.indexOf(opt);
      if (change == 1) {
        return idx >= opts.length - 1 ? opt : opts[idx + 1];
      } else if (change == -1) {
        return idx == 0 ? opt : opts[idx - 1];
      }
      return opt;
    }

    // picker: intervals_per_element
    querySelector('#intervals_per_element_back')!.onClick.listen((event) {
      intervalsPerSymbolElement.innerText = _changeValue(
              int.parse(intervalsPerSymbolElement.innerText),
              intervalsPerSymbolDraftOptions,
              -1)
          .toString();
    });
    querySelector('#intervals_per_element_forward')!.onClick.listen((event) {
      intervalsPerSymbolElement.innerText = _changeValue(
              int.parse(intervalsPerSymbolElement.innerText),
              intervalsPerSymbolDraftOptions,
              1)
          .toString();
    });

    // picker: interval
    querySelector('#interval_back')!.onClick.listen((event) {
      intervalElement.innerText = _changeValue(
              int.parse(intervalElement.innerText), intervalOptions, -1)
          .toString();
    });
    querySelector('#interval_forward')!.onClick.listen((event) {
      intervalElement.innerText =
          _changeValue(int.parse(intervalElement.innerText), intervalOptions, 1)
              .toString();
    });
  }
}
