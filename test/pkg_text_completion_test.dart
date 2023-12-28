import 'package:flutter_test/flutter_test.dart';

import 'package:pkg_text_completion/controler.dart';

void main() {
  test("removeAccents", () {
    expect("école".removeAccents(), "ecole");
    expect("école".toUpperCase().removeAccents(), "ECOLE");
    expect("école Noël".removeAccents(), "ecole Noel");
  });

  test("containsAny", () {
    expect("ceci est une exemple".containsAny(["es"]), true);
    expect("ceci est une exemple".containsAny(["yy"]), false);
    expect("ceci est une exemple".containsAny(["yy", "es"]), true);
    expect("ceci est une exemple".containsAny(["es", "yy"]), true);
    expect("ceci est une exemple".containsAny(["exemples", "yy"]), false);
    expect("Ceci est une exemple".containsAny(["Ceci", "yy"]), true);
    expect("Ceci est une exemple".containsAny(["ceci", "yy"]), false);
    expect("Ceci est une exemple".containsAny(["uu", "ceci", "yy"]), false);
  });

  test("containsAll", () {
    expect("ceci est une exemple".containsAll(["es"]), true);
    expect("ceci est une exemple".containsAll(["yy"]), false);
    expect("ceci est une exemple".containsAll(["ex", "es"]), true);
    expect("ceci est une exemple".containsAll(["es", "le"]), true);
    expect("ceci est une exemple".containsAll(["le", "ce"]), true);
    expect("ceci est une exemple".containsAll(["le", "CE"]), false);
    expect("ceci est une exemple".containsAll(["le", "ce", "e"]), true);
  });
}
