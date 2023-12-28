import 'package:flutter/material.dart';

class TextCompletionControler<T extends SearchEntry> {
  List<T> dataSource = [];
  List<T>?
      cacheDataSourceFiltered; // sans ce cache, c'est un peu la misère coté perfs. Pour mémo: pour une recherche sur 7000 contacts (nom et prénoms),
  // SQLite: c'est 4 ms !
  // mySQSL: 15 ms
  // en mémoire c'est 1ms (4 ms avec 20000 contacts) à condition de supprimer les accents et majuscule au chargement.
  // quand à la recherche floue: 50 ms pour 20000 contacts
  List<T>? bestFuzzySearch;
  int nbBestFuzzy = 3;
  List<String>? arCriteria;
  bool fuzzySearch;
  bool selectedFromList = false; // true if selected in list

  /// set text value to TextField
  set value(String value) {
    txtFieldValue.value = value;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    txtFieldValue.notifyListeners();
    // sinon pas de refresh si sélection de la même valeur dans la liste.
  }

  ValueNotifier<String?> txtFieldValue = ValueNotifier(null);

  /// return selected item in [value]
  Function<T>(dynamic value)? onUpdate;
  // bof, j'étais parti sur Function(T value)? onUpdate; mais cela ne marche pas au niveau du call()
  // Il veut absolument déclarer le type avant la function.
  // et lors de l'appel un <Object> fait l'affaire. Ca sent le bug ou moi qui merde quelque part :(
  TextCompletionControler(
      {required this.dataSource, this.fuzzySearch = true, this.onUpdate});

  updateCriteria(String? criteria) {
    criteria ??= "";
    List<String> chunks = criteria
        .removeAccents()
        .toUpperCase()
        .replaceAll(RegExp('\\s+'), ' ')
        .split(' ');
    chunks.removeWhere((element) => element == ' ' || element == '');
    chunks = Set<String>.from(chunks).toList();
    cacheDataSourceFiltered = null;
    bestFuzzySearch = null;
    arCriteria = chunks;
  }

  List<T>? get dataSourceFiltered {
    // final stopwatch = Stopwatch()..start();

    if (cacheDataSourceFiltered == null) {
      cacheDataSourceFiltered = dataSource
          .where((element) => ((element).sText).containsAll(arCriteria ?? []))
          .toList();
      cacheDataSourceFiltered?.forEach((element) {
        (element).fuzzySearch = false;
      });
    }
    if (cacheDataSourceFiltered!.isEmpty && fuzzySearch) {
      List<T>? bestUsers = getNearestEntries() as List<T>;
      cacheDataSourceFiltered!.addAll(bestUsers);
      //print('Best=$bestUser');
    }
    // print('dataSourceFiltered executed in ${stopwatch.elapsed.inMilliseconds}');
    return cacheDataSourceFiltered;
  }

  List<T>? getNearestEntries() {
    if (bestFuzzySearch != null) return bestFuzzySearch;

    SearchEntry entry = SearchEntry(sText: arCriteria!.join(''));

    bestFuzzySearch = [];
    int occu = 0;

    for (T element in dataSource) {
      //assert(element is SearchEntry);
      occu = 0;
      if ((element).qB2.isNotEmpty) {
        occu = (entry.qB2.toSet().intersection(element.qB2.toSet())).length;
      }

      if ((element).qB3.isNotEmpty) {
        occu += (entry.qB3.toSet().intersection(element.qB3.toSet())).length;
      }
      assert(bestFuzzySearch != null);
      (element).fuzzyOccu = occu;
      if (occu > 0) {
        element.fuzzyScore = (occu / (entry.qB2.length + entry.qB3.length));
      } else {
        element.fuzzyScore = 0;
      }
      element.fuzzySearch = true;
      bestFuzzySearch!.add(element);
      bestFuzzySearch!.sort((a, b) => (b).fuzzyOccu!.compareTo((a).fuzzyOccu!));
      if (bestFuzzySearch!.length > nbBestFuzzy) bestFuzzySearch!.removeLast();
    }
    return bestFuzzySearch;
  }

  /// SPLIT [source] in function of [arChunk]
  List<String> splitText(String source, List<String> arChunk) {
    List<String> result = [];

    if (arChunk.isEmpty) {
      result.add(source);
      return result;
    }
    List<String> arChunkTmp = List<String>.from(arChunk);

    arChunkTmp.sort((a, b) => source.indexOf(a).compareTo(source.indexOf(b)));

    int start = 0;

    for (String chunk in arChunkTmp) {
      int index = source
          .removeAccents()
          .toUpperCase()
          .indexOf(chunk.removeAccents().toUpperCase(), start);

      if (index != -1) {
        result.add(source.substring(start, index));
        result.add(source.substring(index, index + chunk.length));
        start = index + chunk.length;
      }
    }

    if (start < source.length && source.substring(start) != '') {
      result.add(source.substring(start));
    }

    if (result.isNotEmpty && result[0] == '') {
      result.removeAt(0);
    }

    return result;
  }

  /// return array of Text() to fill Row()
  List<Widget> hightLightText(String source) {
    List<Widget> results = [];
    arCriteria ??= [];

    List<String> arTmp = splitText(source, arCriteria!);
    arCriteria = arCriteria!
        .map((element) => element.removeAccents().toUpperCase())
        .toList();

    for (var element in arTmp) {
      if (arCriteria!.contains(element.removeAccents().toUpperCase())) {
        results.add(Text(
          element,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              backgroundColor: getBgColor(
                  arCriteria!.indexOf(element.removeAccents().toUpperCase()))),
        ));
      } else {
        results.add(Text(
          element,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ));
      }
    }
    return results;
  }

  List<Color> colorsBackground = [
    Colors.green.shade300,
    Colors.blue.shade300,
    Colors.brown.shade300,
    Colors.pink.shade200,
    Colors.orange.shade300,
    Colors.teal.shade200,
    Colors.grey.shade400,
    Colors.lightGreen.shade500,
    Colors.cyan.shade200,
    Colors.lime.shade500,
    Colors.blueGrey.shade200,
    Colors.yellow.shade500,
  ];

  Color getBgColor(int indice) {
    return colorsBackground[indice % colorsBackground.length];
  }
}

class SearchEntry {
  Widget title(TextCompletionControler controler) =>
      const Text("to be overridden");

  late String sText;
  List<String> qB2 = [];
  List<String> qB3 = [];
  bool fuzzySearch = false; // true si c'est resultat de recherche approximative
  int?
      fuzzyOccu; // le nombre d'occurences trouvée, plus c'est elevé, plus c'est approchant. Sinon si non recherche approx
  double? fuzzyScore; // le pourcentage de résultat occu/occu des critères

  SearchEntry({required String sText}) {
    this.sText = sText.replaceAll(' ', '').removeAccents().toUpperCase();
    qB2 = _quickBlock(this.sText, 2);
    qB3 = _quickBlock(this.sText, 3);
  }
  List<String> _quickBlock(String input, int n) {
    List<String> result = [];

    for (int i = 0; i < input.length - n + 1; i++) {
      result.add(input.substring(i, i + n));
    }
    return result;
  }
}

extension RemoveAccentsExtension on String {
  String removeAccents() {
    return replaceAll(RegExp(r'[àáâãäå]', caseSensitive: true), 'a')
        .replaceAll(RegExp(r'[èéêë]', caseSensitive: true), 'e')
        .replaceAll(RegExp(r'[ìíîï]', caseSensitive: true), 'i')
        .replaceAll(RegExp(r'[òóôõö]', caseSensitive: true), 'o')
        .replaceAll(RegExp(r'[ùúûü]', caseSensitive: true), 'u')
        .replaceAll(RegExp(r'[ýÿ]', caseSensitive: true), 'y')
        .replaceAll(RegExp(r'[ÀÁÂÃÄÅ]', caseSensitive: true), 'A')
        .replaceAll(RegExp(r'[ÈÉÊË]', caseSensitive: true), 'E')
        .replaceAll(RegExp(r'[ÌÍÎÏ]', caseSensitive: true), 'I')
        .replaceAll(RegExp(r'[ÒÓÔÕÖ]', caseSensitive: true), 'O')
        .replaceAll(RegExp(r'[ÙÚÛÜ]', caseSensitive: true), 'U')
        .replaceAll(RegExp(r'[Ý]', caseSensitive: true), 'Y');
  }

  bool containsAny(List<String> keywords) {
    return keywords.any((keyword) => contains(keyword));
  }

  bool containsAll(List<String> keywords) {
    return keywords.every((keyword) => contains(keyword));
  }
}
