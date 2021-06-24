import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:http/browser_client.dart' as http;
import 'settings.dart';

class CryptoClock {
  static const _testClock = false;
  int _testClockOffset = 0;

  late CryptoClockSettings _settings;

  int currentSymbolIdx = 0;
  int currentIntervalForSymbol = -1;
  late List<List<String>> display;
  late List<List<Element>> elements;
  Timer? clockTimer;
  late Timer appTimer;
  late http.BrowserClient client;
  static const monetarySymbols = <String, String>{
    'USD': r'$',
    'GBP': '£',
    'EUR': '€',
    'JPY': '¥',
    'BTC': '₿',
    'LTC': 'Ł',
    'ETH': 'Ξ',
  };

  CryptoClock() {
    // Init late vars
    _clearDisplay();
    elements = List.generate(
        3, (r) => List.generate(7, (c) => querySelector('#c${r}_$c')!));

    client = http.BrowserClient();
    _settings = CryptoClockSettings(client);
    _initDom();
    _start();
  }
  Future _start() async {
    // TODO: intro currently disabled
    final showIntro = false;
    if (showIntro) {
      _displayString(row: 0, end: 'crypto');
      _displayString(row: 1, end: 'clock');
      _displayString(row: 2, end: 'v1.0');
      await _updateDisplay();
      await Future.delayed(Duration(milliseconds: 500));
    }
    appTimer = Timer.periodic(
        Duration(seconds: _settings.interval), (timer) => _tick());
    await _tick();
  }

  void _resetTimer() {
    appTimer.cancel();
    appTimer = Timer.periodic(
        Duration(seconds: _settings.interval), (timer) => _tick());
  }

  void _initDom() {
    // dom ui
    querySelector('#back')!.onClick.listen((event) {
      if (_testClock) {
        _testClockOffset--;
        _tick();
      } else {
        _symbolBackward();
        _tick(forcePrice: true);
      }
      _resetTimer();
    });
    querySelector('#forward')!.onClick.listen((event) {
      if (_testClock) {
        _testClockOffset++;
        _tick();
      } else {
        _symbolForward();
        _tick(forcePrice: true);
      }
      _resetTimer();
    });
    querySelector('#middle')!.onClick.listen((event) {
      querySelector('#settings')!.classes.add('visible');
    });
  }

  /// Called every `interval` either displays the clock or price
  Future _tick({bool forcePrice = false}) async {
    _clearDisplay();

    final now = DateTime.now();
    final afterNextTick =
        DateTime.now().add(Duration(seconds: _settings.interval));
    final showClock =
        [59, 0].contains(now.minute) || now.hour != afterNextTick.hour;

    // Temporary fix for memory lkea, refreshes the device every hour
    final temporaryRefresh = now.minute < 30 && afterNextTick.minute > 30;

    if (!forcePrice && (_testClock || showClock)) {
      _clockScreen();

      // start clock timer if neccessary (updates time at 30s intervals)
      clockTimer ??= Timer.periodic(Duration(seconds: 30), (timer) => _tick());
    } else if (temporaryRefresh) {
      window.location.reload();
    } else {
      // cancel the clock timer if neccessary
      if (clockTimer != null) {
        clockTimer!.cancel();
        clockTimer = null;
      }
      await _tickerScreen();
    }
    await _updateDisplay();
  }

  /// Cycles between symbols forward
  void _symbolForward() {
    currentSymbolIdx++;
    currentIntervalForSymbol = 0;
    if (currentSymbolIdx >= _settings.symbols.length) currentSymbolIdx = 0;
  }

  /// Cycles between symbols backward
  void _symbolBackward() {
    currentSymbolIdx--;
    currentIntervalForSymbol = 0;
    if (currentSymbolIdx < 0) currentSymbolIdx = _settings.symbols.length - 1;
  }

  /// Puts the time on the display
  void _displayClock(int row) {
    final now = _testClock
        ? DateTime.now().add(Duration(hours: _testClockOffset))
        : DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    _displayString(row: row, end: '$hour:$minute ');
  }

  /// Displays the clock and sun/moon
  void _clockScreen() {
    final sunRise = 7;
    final daylight = 12;
    final sunset = 19;
    final nightHours = 24 - daylight;

    final now = _testClock
        ? DateTime.now().add(Duration(hours: _testClockOffset))
        : DateTime.now();

    _displayClock(1);

    var skyObject = '';
    var skyOffset = 0;

    // Randomly adds stars
    void _addStars(int row, int max) {
      List.generate(
          Random().nextInt(max) + 1,
          (i) => _displayString(
              row: row, col: Random().nextInt(7), characterAtCol: '☆'));
    }

    // Frequency of stars depending on how late it is
    if (now.hour >= 23 || now.hour <= 2) {
      _addStars(0, 2);
      _addStars(2, 2);
    } else if (now.hour >= 21 || now.hour <= 4) {
      _addStars(0, 1);
      _addStars(2, 1);
    }

    // calculate the position in the sky for the sun/moon
    if (now.hour >= sunRise && now.hour < sunRise + daylight) {
      skyObject = '☀';
      skyOffset = (((now.hour - sunRise) / daylight) * 10).ceil();
    } else {
      skyObject = '☾';

      final percentageThroughNight = (now.hour <= sunRise
              ? (24 + now.hour - sunset)
              : (now.hour - sunset)) /
          nightHours;
      skyOffset = (10 * percentageThroughNight).ceil();
    }

    // Place the sun/moon at the correct position
    final row =
        [0, 10].contains(skyOffset) ? 2 : ([1, 9].contains(skyOffset) ? 1 : 0);
    final col = [0, 1].contains(skyOffset)
        ? 0
        : ([9, 10].contains(skyOffset) ? 6 : (skyOffset - 2));
    _displayString(row: row, col: col, characterAtCol: skyObject);
  }

  /// Makes a API request and updates display with latest price
  Future _tickerScreen() async {
    if (++currentIntervalForSymbol >= _settings.intervalsPerSymbol) {
      _symbolForward();
    }
    final symbol = _settings.symbols[currentSymbolIdx];
    Map<String, dynamic> data = {};
    try {
      var response = await client.get(Uri.parse(
          'https://api.binance.com/api/v3/ticker/24hr?symbol=${symbol['symbol']}'));
      data = json.decode(response.body);

      // Replacing the above with this mock request resolves the listeners leak
      // data = json.decode(
      //     '{"symbol":"BTCUSDT","priceChangePercent":"${Random().nextInt(7)}","lastPrice":"${Random().nextInt(2000)}"}');

      // Handle network error
    } catch (e) {
      _displayClock(0);
      _displayString(row: 1, end: 'NETWORK');
      _displayString(row: 2, end: ' ERROR ');
      return;
    } finally {
      client.close();
    }

    // Handle data shape error
    if (data.isEmpty ||
        ['lastPrice', 'priceChangePercent']
            .where((e) => !data.containsKey(e))
            .isNotEmpty) {
      _displayClock(0);
      _displayString(row: 1, end: ' PARSE ');
      _displayString(row: 2, end: ' ERROR ');
      return;
    }

    // Display symbol on the top row
    final price = _parsePrice(data['lastPrice']);
    if (symbol['symbol'].length == 7) {
      _displayString(row: 0, end: symbol['symbol']);
    } else if (symbol['symbol'].length < 7) {
      _displayString(row: 0, start: symbol['baseAsset']);
      _displayString(row: 0, end: symbol['quoteAsset']);
    } else {
      _displayString(row: 0, end: symbol['baseAsset']);
    }

    // Display price on the middle row
    _displayString(row: 1, end: price);
    final mSymbol = monetarySymbol(symbol['quoteAsset']);
    if (price.length < 7 && mSymbol != null) {
      _displayString(row: 1, start: mSymbol);
    }

    // Display price change on the bottom row
    final percentChange =
        min(max(double.parse(data['priceChangePercent']).toInt(), -99), 99);
    _displayString(row: 2, start: '24h');
    _displayString(
        row: 2, end: (percentChange > 0 ? '+' : '') + '$percentChange%');
  }

  void _clearDisplay() {
    display = List.generate(3, (r) => List.generate(7, (i) => ''));
  }

  Future _updateDisplay() async {
    final futures = <Future>[];

    for (var r = 0, rl = 3; r < rl; r++) {
      for (var c = 0, cl = 7; c < cl; c++) {
        final character = display[r][c] == ' ' ? '' : display[r][c];
        if (elements[r][c].innerText != character) {
          // The CSS method alternative method, doesn't resolve node leak
          // querySelector('#c${r}_$c')!
          //   ..innerText = display[r][c]
          //   ..classes.remove('refreshAnimation');
          // await Future.delayed(Duration(milliseconds: 70));

          // querySelector('#c${r}_$c')!
          //   ..innerText = display[r][c]
          //   ..classes.add('refreshAnimation');

          await Future.delayed(Duration(milliseconds: 100));
          elements[r][c]
            ..classes.add('refresh')
            ..innerText = character;

          futures.add((int r, int c) async {
            await Future.delayed(Duration(milliseconds: 300));
            elements[r][c].classes.remove('refresh');
          }(r, c));
        }
      }
    }
    await Future.wait(futures);
  }

  String _parsePrice(String priceString) {
    final price = double.parse(priceString);
    if (price < 0.0001) {
      return price.toStringAsFixed(5).substring(1);
    } else if (price < 1) {
      return price.toStringAsFixed(4);
    } else if (price < 10) {
      return price.toStringAsFixed(3);
    } else if (price < 100) {
      return price.toStringAsFixed(2);
    } else if (price < 1000) {
      return price.toStringAsFixed(1);
    } else {
      return price.toInt().toString();
    }
  }

  /// Returns a currency symbol if known
  String? monetarySymbol(String currency) {
    for (final c in monetarySymbols.keys) {
      if (currency.contains(c)) return monetarySymbols[c];
    }
  }

  /// Updates `display` with text
  void _displayString(
      {required int row,
      String? start,
      String? end,
      int? col,
      String? characterAtCol}) {
    if (start != null) {
      display[row] = start.split('')
        ..addAll(display[row].sublist(start.length));
    }
    if (end != null) {
      final c = 7 - end.length;
      display[row] = display[row].sublist(0, c)..addAll(end.split(''));
    }

    if (col != null && characterAtCol != null) {
      display[row][col] = characterAtCol;
    }
  }
}

void main() async {
  CryptoClock();
}
