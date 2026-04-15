// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a sk locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'sk';

  static String m0(title) => "Dokumentácia pre: ${title}";

  static String m1(count) =>
      "${Intl.plural(count, one: 'Úspešne spracovaná ${count} fotka.', few: 'Úspešne spracované ${count} fotky.', other: 'Úspešne spracovaných ${count} fotiek.')}";

  static String m2(count) =>
      "${Intl.plural(count, one: 'Úspešne nahraná ${count} nahrávka.', few: 'Úspešne nahrané ${count} nahrávky.', other: 'Úspešne nahraných ${count} nahrávok.')}";

  static String m3(count) => "Naozaj chcete vymazať ${count} položiek?";

  static String m4(name) =>
      "Naozaj chcete vymazať \"${name}\"?\nTáto akcia je nevratná.";

  static String m5(lat, lng) => "Poloha: ${lat}, ${lng}";

  static String m6(name) =>
      "Naozaj chcete vymazať \"${name}\"?\nTáto akcia je nevratná.";

  static String m7(count) => "Priložené médiá (${count})";

  static String m8(count) => "Úspešne nahraných ${count} nahrávok.";

  static String m9(count) => "Úspešne nahraných ${count} videí.";

  static String m10(count) => "Úspešne spracovaných ${count} fotiek.";

  static String m11(count) =>
      "${Intl.plural(count, one: 'Úspešne nahrané ${count} video.', few: 'Úspešne nahrané ${count} videá.', other: 'Úspešne nahraných ${count} videí.')}";

  static String m12(count) => "${count} vybrané";

  static String m13(count) =>
      "${Intl.plural(count, one: 'Naozaj chcete vymazať jednu položku?', few: 'Naozaj chcete vymazať ${count} položky?', other: 'Naozaj chcete vymazať ${count} položiek?')}";

  static String m14(name) => "\"${name}\" bol vymazaný.";

  static String m15(name) => "\"${name}\" bol vymazaný.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Hladanie": MessageLookupByLibrary.simpleMessage("Hľadať v sklade"),
    "RegistraciaV": MessageLookupByLibrary.simpleMessage(
      "Nový v systéme? Zaregistrujte sa",
    ),
    "Zariadenia": MessageLookupByLibrary.simpleMessage("Zariadenia"),
    "anoZmenit": MessageLookupByLibrary.simpleMessage("Áno, zmeniť"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Trezor Bakalárka"),
    "audio": MessageLookupByLibrary.simpleMessage("Audio"),
    "audioIcon": MessageLookupByLibrary.simpleMessage("Zvuk"),
    "bezPripojenia": MessageLookupByLibrary.simpleMessage(
      "Bez pripojenia – zmeny sa uložia lokálne",
    ),
    "biometriaContent": MessageLookupByLibrary.simpleMessage(
      "Vaše údaje boli uložené. Nabudúce sa môžete prihlásiť odtlačkom prsta.",
    ),
    "biometriaTitle": MessageLookupByLibrary.simpleMessage(
      "Biometria dostupná",
    ),
    "biometriaZlyhala": MessageLookupByLibrary.simpleMessage(
      "Biometria zlyhala.",
    ),
    "cameraIcon": MessageLookupByLibrary.simpleMessage("Kamera"),
    "chybaOdhlasenia": MessageLookupByLibrary.simpleMessage(
      "Chyba pri odhlasovaní. Skúste znova.",
    ),
    "chybaTechnika": MessageLookupByLibrary.simpleMessage(
      "Chyba – technika sa nepodarilo odstrániť.",
    ),
    "chybaUkladaniaAudio": MessageLookupByLibrary.simpleMessage(
      "Chyba pri ukladaní nahrávky",
    ),
    "chybaZmenyKodu": MessageLookupByLibrary.simpleMessage(
      "Chyba pri zmene kódu",
    ),
    "dokumentaciaPreTitle": m0,
    "doplnitParametre": MessageLookupByLibrary.simpleMessage(
      "Doplniť parametre",
    ),
    "doplnkoveUdaje": MessageLookupByLibrary.simpleMessage("Doplnkové údaje"),
    "doplnkoveUdajeLabel": MessageLookupByLibrary.simpleMessage(
      "Doplnkové údaje:",
    ),
    "doplnkoveu": MessageLookupByLibrary.simpleMessage("doplnkové údaje"),
    "evidenciaMajjetku": MessageLookupByLibrary.simpleMessage(
      "Evidencia majetku",
    ),
    "evidenciaText": MessageLookupByLibrary.simpleMessage("Evidencia"),
    "evidenciaTextH": MessageLookupByLibrary.simpleMessage("Evidencia"),
    "firemPris": MessageLookupByLibrary.simpleMessage(
      "Firemný prístup (Admin)",
    ),
    "fotky": MessageLookupByLibrary.simpleMessage("Fotky"),
    "fotkySpracovane": m1,
    "foto": MessageLookupByLibrary.simpleMessage("Foto"),
    "galleryIcon": MessageLookupByLibrary.simpleMessage("Galéria"),
    "hesloV": MessageLookupByLibrary.simpleMessage("Heslo"),
    "historiaKText": MessageLookupByLibrary.simpleMessage("História záznamov"),
    "historiaKTextH": MessageLookupByLibrary.simpleMessage("História"),
    "historiaMajjetku": MessageLookupByLibrary.simpleMessage(
      "História majetku",
    ),
    "historiaPrazdna": MessageLookupByLibrary.simpleMessage(
      "História je prázdna.",
    ),
    "historiaTab": MessageLookupByLibrary.simpleMessage("História"),
    "hladatVSklade": MessageLookupByLibrary.simpleMessage("Hľadať v sklade..."),
    "hladatZariadenie": MessageLookupByLibrary.simpleMessage(
      "Hľadať podľa názvu, S/N, modelu...",
    ),
    "hlasovaNahravka": MessageLookupByLibrary.simpleMessage("Hlasová nahrávka"),
    "hodnotaHint": MessageLookupByLibrary.simpleMessage("Hodnota"),
    "homeText": MessageLookupByLibrary.simpleMessage("Domovská obrazovka"),
    "homeTitle": MessageLookupByLibrary.simpleMessage("Domov"),
    "hotovo": MessageLookupByLibrary.simpleMessage("Hotovo"),
    "ico": MessageLookupByLibrary.simpleMessage("IČO"),
    "kodBylZmeneny": MessageLookupByLibrary.simpleMessage("Kód bol zmenený"),
    "kodOdAdmina": MessageLookupByLibrary.simpleMessage("Kód od admina"),
    "kodPreT": MessageLookupByLibrary.simpleMessage(
      "Vstupný kód pre technikov",
    ),
    "kopy": MessageLookupByLibrary.simpleMessage("Kopírovať"),
    "logoutText": MessageLookupByLibrary.simpleMessage("Odhlásiť sa"),
    "mnozstvo": MessageLookupByLibrary.simpleMessage("Množstvo"),
    "mnozstvoP": MessageLookupByLibrary.simpleMessage("Množstvo"),
    "mobilDH": MessageLookupByLibrary.simpleMessage("Mobilné pripojenie"),
    "modelZ": MessageLookupByLibrary.simpleMessage("Model"),
    "mojTrezor": MessageLookupByLibrary.simpleMessage("Môj Trezor"),
    "mojiT": MessageLookupByLibrary.simpleMessage("Moji technici"),
    "nadpisV": MessageLookupByLibrary.simpleMessage("Vítaj v Trezore"),
    "nahravam": MessageLookupByLibrary.simpleMessage("nahrávam"),
    "nahravamV": MessageLookupByLibrary.simpleMessage("Nahrávam"),
    "nahravkyNahrate": m2,
    "najprvManualne": MessageLookupByLibrary.simpleMessage(
      "Najprv sa musíte prihlásiť manuálne.",
    ),
    "naozajO": MessageLookupByLibrary.simpleMessage(
      "Naozaj sa chcete odhlásiť?",
    ),
    "naozajOdstranit": MessageLookupByLibrary.simpleMessage(
      "Naozaj chcete odstrániť ",
    ),
    "naozajVymazat": m3,
    "naozajVymazatZariadenie": m4,
    "nastaveniaH": MessageLookupByLibrary.simpleMessage("Nastavenia"),
    "nazovASerioveCisloPovinne": MessageLookupByLibrary.simpleMessage(
      "Názov a sériové číslo sú povinné.",
    ),
    "nazovCisloRevizie": MessageLookupByLibrary.simpleMessage(
      "Názov / Číslo revízie",
    ),
    "nazovFV": MessageLookupByLibrary.simpleMessage("Názov firmy"),
    "nazovFirmy": MessageLookupByLibrary.simpleMessage("Názov firmy"),
    "nazovHint": MessageLookupByLibrary.simpleMessage("Názov"),
    "nazovP": MessageLookupByLibrary.simpleMessage("Názov položky"),
    "nazovPolozky": MessageLookupByLibrary.simpleMessage(
      "Názov položky (vyber alebo napíš novú)",
    ),
    "nazovZ": MessageLookupByLibrary.simpleMessage("Názov"),
    "nazovZariadenia": MessageLookupByLibrary.simpleMessage(
      "Názov zariadenia *",
    ),
    "neporadiloPrehratNahravku": MessageLookupByLibrary.simpleMessage(
      "Nepodarilo sa dešifrovať alebo prehrať nahrávku.",
    ),
    "neporadiloPrehratVideo": MessageLookupByLibrary.simpleMessage(
      "Nepodarilo sa prehrať video.",
    ),
    "neznamy": MessageLookupByLibrary.simpleMessage("Neznámy"),
    "neznamyEmail": MessageLookupByLibrary.simpleMessage("Neznámy email"),
    "neznamyMajitel": MessageLookupByLibrary.simpleMessage("Neznámy majiteľ"),
    "novePole": MessageLookupByLibrary.simpleMessage("Nové pole"),
    "noveZar": MessageLookupByLibrary.simpleMessage("Nové zariadenie"),
    "noveZarH": MessageLookupByLibrary.simpleMessage("Nové zariadenie"),
    "noveZariadenieFull": MessageLookupByLibrary.simpleMessage(
      "Nové zariadenie",
    ),
    "novyP": MessageLookupByLibrary.simpleMessage("Nový pohyb"),
    "novyPohyb": MessageLookupByLibrary.simpleMessage("Nový pohyb"),
    "oblubeneV": MessageLookupByLibrary.simpleMessage("Obľúbené"),
    "odhlasV": MessageLookupByLibrary.simpleMessage("Odhlásiť sa"),
    "odkazUrl": MessageLookupByLibrary.simpleMessage("Odkaz / URL"),
    "odstranenyT": MessageLookupByLibrary.simpleMessage("Odstránený"),
    "odstranit": MessageLookupByLibrary.simpleMessage("Odstrániť"),
    "odstranitTechnika": MessageLookupByLibrary.simpleMessage(
      "Odstrániť technika?",
    ),
    "odstranitZFirmy": MessageLookupByLibrary.simpleMessage(
      "Odstrániť z firmy",
    ),
    "opravaPred": MessageLookupByLibrary.simpleMessage("Oprava pred"),
    "opravapo": MessageLookupByLibrary.simpleMessage("Oprava po"),
    "osemZV": MessageLookupByLibrary.simpleMessage("8+znakov"),
    "panelText": MessageLookupByLibrary.simpleMessage(
      "Sprava majetku a skladu",
    ),
    "pociatocnyStav": MessageLookupByLibrary.simpleMessage("Počiatočný stav"),
    "pohybyT": MessageLookupByLibrary.simpleMessage("Pohyby"),
    "pohybyTab": MessageLookupByLibrary.simpleMessage("Pohyby"),
    "pohybyText": MessageLookupByLibrary.simpleMessage("Pohyby"),
    "pohybyTextH": MessageLookupByLibrary.simpleMessage("Pohyby"),
    "poloha": m5,
    "popisB": MessageLookupByLibrary.simpleMessage("Popis"),
    "popisStavu": MessageLookupByLibrary.simpleMessage("Popis stavu"),
    "potvrdenieVymazania": m6,
    "potvrditP": MessageLookupByLibrary.simpleMessage("Potvrdit prijem"),
    "potvrditPrijem": MessageLookupByLibrary.simpleMessage("POTVRDIŤ PRÍJEM"),
    "potvrditV": MessageLookupByLibrary.simpleMessage("Potvrdit výdaj"),
    "potvrditVydaj": MessageLookupByLibrary.simpleMessage("POTVRDIŤ VÝDAJ"),
    "povinnePole": MessageLookupByLibrary.simpleMessage("Povinné pole"),
    "poznamkaKServisu": MessageLookupByLibrary.simpleMessage(
      "Poznámka k servisu",
    ),
    "pregeneratKod": MessageLookupByLibrary.simpleMessage("Pregenerovať kód?"),
    "prehladyT": MessageLookupByLibrary.simpleMessage("Prehľady"),
    "pridatB": MessageLookupByLibrary.simpleMessage("Pridat"),
    "pridatP": MessageLookupByLibrary.simpleMessage("Pridat"),
    "pridatZariadenie": MessageLookupByLibrary.simpleMessage(
      "Pridať zariadenie",
    ),
    "prihlasV": MessageLookupByLibrary.simpleMessage("Prihlásiť sa"),
    "prihlasenyPouzivatel": MessageLookupByLibrary.simpleMessage(
      "Prihlásený používateľ",
    ),
    "prijem": MessageLookupByLibrary.simpleMessage("Príjem"),
    "prijemT": MessageLookupByLibrary.simpleMessage("Prijem"),
    "prilozeneMedia": m7,
    "priloztePrst": MessageLookupByLibrary.simpleMessage(
      "Priložte prst pre overenie",
    ),
    "pripojenieT": MessageLookupByLibrary.simpleMessage("Pripojenie"),
    "pripojitZTrezoru": MessageLookupByLibrary.simpleMessage(
      "Pripojiť z trezoru",
    ),
    "profilT": MessageLookupByLibrary.simpleMessage("Profil"),
    "recordAudio": MessageLookupByLibrary.simpleMessage("Nahrávať zvuk"),
    "registrTV": MessageLookupByLibrary.simpleMessage("Registrácia technika"),
    "registrV": MessageLookupByLibrary.simpleMessage("Registrovať"),
    "reviziaOo": MessageLookupByLibrary.simpleMessage("Revízia po"),
    "reviziaPred": MessageLookupByLibrary.simpleMessage("Revízia pred"),
    "rozumiem": MessageLookupByLibrary.simpleMessage("Rozumiem"),
    "serioveCislo": MessageLookupByLibrary.simpleMessage("Sériové číslo *"),
    "servisUprava": MessageLookupByLibrary.simpleMessage("Servis / Úprava"),
    "servisZmenaStavu": MessageLookupByLibrary.simpleMessage("Zmena stavu"),
    "servisneZaznamy": MessageLookupByLibrary.simpleMessage("Servisné záznamy"),
    "setloV": MessageLookupByLibrary.simpleMessage("Svetlá"),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("Nastavenia"),
    "skladH": MessageLookupByLibrary.simpleMessage("Skladové hospodárstvo"),
    "skladJePrazdny": MessageLookupByLibrary.simpleMessage("Sklad je prázdny."),
    "skladText": MessageLookupByLibrary.simpleMessage("Sklad"),
    "skladTextH": MessageLookupByLibrary.simpleMessage("Sklad"),
    "skladoveHospodarstvo": MessageLookupByLibrary.simpleMessage(
      "Skladové hospodárstvo",
    ),
    "skladovyPohyb": MessageLookupByLibrary.simpleMessage("Skladový pohyb"),
    "skopirovaneDo": MessageLookupByLibrary.simpleMessage(
      "Skopírované do schránky",
    ),
    "snZ": MessageLookupByLibrary.simpleMessage("SN"),
    "somAV": MessageLookupByLibrary.simpleMessage("Som Admin"),
    "somAdmin": MessageLookupByLibrary.simpleMessage("Som Admin"),
    "somTV": MessageLookupByLibrary.simpleMessage("Som technik"),
    "somTechnik": MessageLookupByLibrary.simpleMessage("Som Technik"),
    "spravaAudioV": MessageLookupByLibrary.simpleMessage(
      "Audio uložené a zašifrované",
    ),
    "stacV": MessageLookupByLibrary.simpleMessage("Stlač pre nahrávanie"),
    "staryKodPrestan": MessageLookupByLibrary.simpleMessage(
      "Starý kód prestane okamžite fungovať pre nových technikov.",
    ),
    "statusDiscarded": MessageLookupByLibrary.simpleMessage("Vyradené"),
    "statusFaulty": MessageLookupByLibrary.simpleMessage("V poruche"),
    "statusInOperation": MessageLookupByLibrary.simpleMessage("V prevádzke"),
    "statusOutOufOrder": MessageLookupByLibrary.simpleMessage("Odstavené"),
    "statusRequiresService": MessageLookupByLibrary.simpleMessage(
      "Vyžaduje servis",
    ),
    "statusZ": MessageLookupByLibrary.simpleMessage("Stav zásob"),
    "stavSkladuT": MessageLookupByLibrary.simpleMessage("Stav skladu"),
    "stavZText": MessageLookupByLibrary.simpleMessage("Stav zásob"),
    "stavZasob": MessageLookupByLibrary.simpleMessage("Stav zásob"),
    "stlacPreNah": MessageLookupByLibrary.simpleMessage("Stlač pre nahrávanie"),
    "stopRecording": MessageLookupByLibrary.simpleMessage(
      "Zastaviť nahrávanie",
    ),
    "suborNatrvaloOdstraneny": MessageLookupByLibrary.simpleMessage(
      "Tento súbor bude natrvalo odstránený.",
    ),
    "suborNatrvaloOdstraneny2": MessageLookupByLibrary.simpleMessage(
      "Súbor bude natrvalo odstránený.",
    ),
    "systemText": MessageLookupByLibrary.simpleMessage("Systém"),
    "systemV": MessageLookupByLibrary.simpleMessage("Sýstém"),
    "technickeParametre": MessageLookupByLibrary.simpleMessage(
      "Technické parametre",
    ),
    "technickeParametreSection": MessageLookupByLibrary.simpleMessage(
      "Technické parametre",
    ),
    "technikT": MessageLookupByLibrary.simpleMessage("Technik"),
    "temaT": MessageLookupByLibrary.simpleMessage("Téma aplikácie"),
    "tmavoV": MessageLookupByLibrary.simpleMessage("Tmavá"),
    "trezorFotiekPrazdny": MessageLookupByLibrary.simpleMessage(
      "Trezor fotiek je prázdny",
    ),
    "trezorNahravokPrazdny": MessageLookupByLibrary.simpleMessage(
      "Trezor nahrávok je prázdny.",
    ),
    "trezorPrazdny": MessageLookupByLibrary.simpleMessage("Trezor je prázdny"),
    "trezorSystem": MessageLookupByLibrary.simpleMessage("Trezor System"),
    "typP": MessageLookupByLibrary.simpleMessage("Typ"),
    "ulozitB": MessageLookupByLibrary.simpleMessage("Uložiť"),
    "ulozitReport": MessageLookupByLibrary.simpleMessage("Uložiť report"),
    "ulozitZariadenie": MessageLookupByLibrary.simpleMessage(
      "ULOŽIŤ ZARIADENIE",
    ),
    "ulozitZmeny": MessageLookupByLibrary.simpleMessage("ULOŽIŤ ZMENY"),
    "uspesneNahranychNahravok": m8,
    "uspesneNahranychVidei": m9,
    "uspesneSpraovanychFotiek": m10,
    "uzmateUV": MessageLookupByLibrary.simpleMessage(
      "Už máte účet? Prihlásiť sa",
    ),
    "videa": MessageLookupByLibrary.simpleMessage("Videá"),
    "videaNahrate": m11,
    "video": MessageLookupByLibrary.simpleMessage("Video"),
    "videoZasifrovaneUlozene": MessageLookupByLibrary.simpleMessage(
      "Video zašifrované a uložené",
    ),
    "vitajteVTrezore": MessageLookupByLibrary.simpleMessage(
      "Vitajte v Trezore",
    ),
    "vsetkyFilter": MessageLookupByLibrary.simpleMessage("Všetky"),
    "vsetkyT": MessageLookupByLibrary.simpleMessage("Všetky"),
    "vybraneCount": m12,
    "vydaj": MessageLookupByLibrary.simpleMessage("Výdaj"),
    "vydajT": MessageLookupByLibrary.simpleMessage("Výdaj"),
    "vymazat": MessageLookupByLibrary.simpleMessage("Vymazať"),
    "vymazatB": MessageLookupByLibrary.simpleMessage("Vymazať"),
    "vymazatPolozkyPotvrdenie": m13,
    "vymazatVyber": MessageLookupByLibrary.simpleMessage("Vymazať výber?"),
    "vymazatZariadenie": MessageLookupByLibrary.simpleMessage(
      "Vymazať zariadenie?",
    ),
    "vzhladT": MessageLookupByLibrary.simpleMessage("Vyhľad"),
    "wifiT": MessageLookupByLibrary.simpleMessage("Wi-Fi"),
    "zFirmyText": MessageLookupByLibrary.simpleMessage(
      " z firmy?\n\nTechnik stratí prístup k firemným dátam a nebude sa môcť prihlásiť.",
    ),
    "zadajteEmail": MessageLookupByLibrary.simpleMessage(
      "Zadajte platný email",
    ),
    "zadajteHeslo": MessageLookupByLibrary.simpleMessage("Zadajte heslo"),
    "zakladneUdaje": MessageLookupByLibrary.simpleMessage("Základné údaje"),
    "zakladneUdajeReport": MessageLookupByLibrary.simpleMessage(
      "Základné údaje",
    ),
    "zalozFV": MessageLookupByLibrary.simpleMessage("Založiť firmu"),
    "zariadeniaTab": MessageLookupByLibrary.simpleMessage("Zariadenia"),
    "zariadeniaText": MessageLookupByLibrary.simpleMessage("Zariadenia"),
    "zariadenieBylVymazane": m14,
    "zariadenieVymazane": m15,
    "zdielatT": MessageLookupByLibrary.simpleMessage("Zdielať"),
    "ziadnaHistoria": MessageLookupByLibrary.simpleMessage(
      "Žiadna história pohybov.",
    ),
    "ziadneDoplnkove": MessageLookupByLibrary.simpleMessage(
      "Žiadne doplnkové údaje",
    ),
    "ziadneGps": MessageLookupByLibrary.simpleMessage(
      "K tejto fotke nie sú dostupné GPS údaje.",
    ),
    "ziadneParametreKlikni": MessageLookupByLibrary.simpleMessage(
      "Žiadne parametre – kliknite Pridať",
    ),
    "ziadneTechParam2": MessageLookupByLibrary.simpleMessage(
      "Žiadne technické parametre",
    ),
    "ziadneTechnickeParam": MessageLookupByLibrary.simpleMessage(
      "Žiadne technické parametre",
    ),
    "ziadneVidea": MessageLookupByLibrary.simpleMessage(
      "V trezore zatiaľ nie sú žiadne videá.",
    ),
    "ziadneVysledky": MessageLookupByLibrary.simpleMessage(
      "Žiadne výsledky pre zadaný filter.",
    ),
    "ziadniTechnici": MessageLookupByLibrary.simpleMessage(
      "Zatiaľ nemáte žiadnych technikov.",
    ),
    "ziadnyMajjetok": MessageLookupByLibrary.simpleMessage(
      "Žiadny majetok vo firme.",
    ),
    "zmazat": MessageLookupByLibrary.simpleMessage("Zmazať"),
    "zmazatNahravku": MessageLookupByLibrary.simpleMessage("Zmazať nahrávku?"),
    "zmazatVideo": MessageLookupByLibrary.simpleMessage("Zmazať video?"),
    "zmenitT": MessageLookupByLibrary.simpleMessage("Zmeniť"),
    "zobrazitZasoby": MessageLookupByLibrary.simpleMessage("Zobraziť zásoby"),
    "zoraditAZ": MessageLookupByLibrary.simpleMessage("Zoradiť A–Z"),
    "zrusitB": MessageLookupByLibrary.simpleMessage("Zrušiť"),
  };
}
