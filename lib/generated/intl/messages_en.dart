// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(title) => "Documentation for: ${title}";

  static String m1(count) =>
      "${Intl.plural(count, one: 'Successfully processed ${count} photo.', other: 'Successfully processed ${count} photos.')}";

  static String m2(count) =>
      "${Intl.plural(count, one: 'Successfully uploaded ${count} recording.', other: 'Successfully uploaded ${count} recordings.')}";

  static String m3(count) => "Are you sure you want to delete ${count} items?";

  static String m4(name) =>
      "Are you sure you want to delete \"${name}\"?\nThis action cannot be undone.";

  static String m5(lat, lng) => "Location: ${lat}, ${lng}";

  static String m6(name) =>
      "Do you really want to delete \"${name}\"?\nThis action is irreversible.";

  static String m7(count) => "Attached Media (${count})";

  static String m8(count) => "Successfully uploaded ${count} recordings.";

  static String m9(count) => "Successfully uploaded ${count} videos.";

  static String m10(count) => "Successfully processed ${count} photos.";

  static String m11(count) =>
      "${Intl.plural(count, one: 'Successfully uploaded ${count} video.', other: 'Successfully uploaded ${count} videos.')}";

  static String m12(count) => "${count} selected";

  static String m13(count) =>
      "${Intl.plural(count, one: 'Do you really want to delete one item?', other: 'Do you really want to delete ${count} items?')}";

  static String m14(name) => "\"${name}\" has been deleted.";

  static String m15(name) => "\"${name}\" has been deleted.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Hladanie": MessageLookupByLibrary.simpleMessage("Search Warehouse"),
    "RegistraciaV": MessageLookupByLibrary.simpleMessage(
      "New to the system? Register",
    ),
    "Zariadenia": MessageLookupByLibrary.simpleMessage("Devices"),
    "anoZmenit": MessageLookupByLibrary.simpleMessage("Yes, change"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Trezor"),
    "audio": MessageLookupByLibrary.simpleMessage("Audio"),
    "audioIcon": MessageLookupByLibrary.simpleMessage("Audio"),
    "bezPripojenia": MessageLookupByLibrary.simpleMessage(
      "Offline – changes will be saved locally",
    ),
    "biometriaContent": MessageLookupByLibrary.simpleMessage(
      "Your credentials have been saved. Next time you can log in with your fingerprint.",
    ),
    "biometriaTitle": MessageLookupByLibrary.simpleMessage(
      "Biometrics Available",
    ),
    "biometriaZlyhala": MessageLookupByLibrary.simpleMessage(
      "Biometrics failed.",
    ),
    "cameraIcon": MessageLookupByLibrary.simpleMessage("Camera"),
    "chybaOdhlasenia": MessageLookupByLibrary.simpleMessage(
      "Error logging out. Please try again.",
    ),
    "chybaTechnika": MessageLookupByLibrary.simpleMessage(
      "Error – technician could not be removed.",
    ),
    "chybaUkladaniaAudio": MessageLookupByLibrary.simpleMessage(
      "Error saving recording",
    ),
    "chybaZmenyKodu": MessageLookupByLibrary.simpleMessage(
      "Error changing code",
    ),
    "dokumentaciaPreTitle": m0,
    "doplnitParametre": MessageLookupByLibrary.simpleMessage("Add Parameters"),
    "doplnkoveUdaje": MessageLookupByLibrary.simpleMessage("Additional Data"),
    "doplnkoveUdajeLabel": MessageLookupByLibrary.simpleMessage(
      "Additional data:",
    ),
    "doplnkoveu": MessageLookupByLibrary.simpleMessage("Additional Info"),
    "evidenciaMajjetku": MessageLookupByLibrary.simpleMessage(
      "Asset Management",
    ),
    "evidenciaText": MessageLookupByLibrary.simpleMessage("Evidence"),
    "evidenciaTextH": MessageLookupByLibrary.simpleMessage("Evidence"),
    "firemPris": MessageLookupByLibrary.simpleMessage("Company Access (Admin)"),
    "fotky": MessageLookupByLibrary.simpleMessage("Photos"),
    "fotkySpracovane": m1,
    "foto": MessageLookupByLibrary.simpleMessage("Photo"),
    "galleryIcon": MessageLookupByLibrary.simpleMessage("Gallery"),
    "hesloV": MessageLookupByLibrary.simpleMessage("Password"),
    "historiaKText": MessageLookupByLibrary.simpleMessage("Records History"),
    "historiaKTextH": MessageLookupByLibrary.simpleMessage("History"),
    "historiaMajjetku": MessageLookupByLibrary.simpleMessage("Asset History"),
    "historiaPrazdna": MessageLookupByLibrary.simpleMessage(
      "History is empty.",
    ),
    "historiaTab": MessageLookupByLibrary.simpleMessage("History"),
    "hladatVSklade": MessageLookupByLibrary.simpleMessage(
      "Search warehouse...",
    ),
    "hladatZariadenie": MessageLookupByLibrary.simpleMessage(
      "Search by name, S/N, model...",
    ),
    "hlasovaNahravka": MessageLookupByLibrary.simpleMessage("Voice Recording"),
    "hodnotaHint": MessageLookupByLibrary.simpleMessage("Value"),
    "homeText": MessageLookupByLibrary.simpleMessage("Home Screen"),
    "homeTitle": MessageLookupByLibrary.simpleMessage("Home"),
    "hotovo": MessageLookupByLibrary.simpleMessage("Done"),
    "ico": MessageLookupByLibrary.simpleMessage("Company ID"),
    "kodBylZmeneny": MessageLookupByLibrary.simpleMessage(
      "Code has been changed",
    ),
    "kodOdAdmina": MessageLookupByLibrary.simpleMessage("Code from Admin"),
    "kodPreT": MessageLookupByLibrary.simpleMessage(
      "Entry Code for Technicians",
    ),
    "kopy": MessageLookupByLibrary.simpleMessage("Copy"),
    "logoutText": MessageLookupByLibrary.simpleMessage("Log Out"),
    "mnozstvo": MessageLookupByLibrary.simpleMessage("Quantity"),
    "mnozstvoP": MessageLookupByLibrary.simpleMessage("Quantity"),
    "mobilDH": MessageLookupByLibrary.simpleMessage("Mobile Connection"),
    "modelZ": MessageLookupByLibrary.simpleMessage("Model"),
    "mojTrezor": MessageLookupByLibrary.simpleMessage("My Vault"),
    "mojiT": MessageLookupByLibrary.simpleMessage("My Technicians"),
    "nadpisV": MessageLookupByLibrary.simpleMessage("Welcome to Trezor"),
    "nahravam": MessageLookupByLibrary.simpleMessage("recording"),
    "nahravamV": MessageLookupByLibrary.simpleMessage("Recording"),
    "nahravkyNahrate": m2,
    "najprvManualne": MessageLookupByLibrary.simpleMessage(
      "You must log in manually first.",
    ),
    "naozajO": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to log out?",
    ),
    "naozajOdstranit": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to remove ",
    ),
    "naozajVymazat": m3,
    "naozajVymazatZariadenie": m4,
    "nastaveniaH": MessageLookupByLibrary.simpleMessage("Settings"),
    "nazovASerioveCisloPovinne": MessageLookupByLibrary.simpleMessage(
      "Name and serial number are required.",
    ),
    "nazovCisloRevizie": MessageLookupByLibrary.simpleMessage(
      "Name / Revision Number",
    ),
    "nazovFV": MessageLookupByLibrary.simpleMessage("Company Name"),
    "nazovFirmy": MessageLookupByLibrary.simpleMessage("Company Name"),
    "nazovHint": MessageLookupByLibrary.simpleMessage("Name"),
    "nazovP": MessageLookupByLibrary.simpleMessage("Item Name"),
    "nazovPolozky": MessageLookupByLibrary.simpleMessage(
      "Item name (select or enter new)",
    ),
    "nazovZ": MessageLookupByLibrary.simpleMessage("Name"),
    "nazovZariadenia": MessageLookupByLibrary.simpleMessage("Device Name *"),
    "neporadiloPrehratNahravku": MessageLookupByLibrary.simpleMessage(
      "Could not decrypt or play the recording.",
    ),
    "neporadiloPrehratVideo": MessageLookupByLibrary.simpleMessage(
      "Could not play video.",
    ),
    "neznamy": MessageLookupByLibrary.simpleMessage("Unknown"),
    "neznamyEmail": MessageLookupByLibrary.simpleMessage("Unknown email"),
    "neznamyMajitel": MessageLookupByLibrary.simpleMessage("Unknown owner"),
    "novePole": MessageLookupByLibrary.simpleMessage("New Field"),
    "noveZar": MessageLookupByLibrary.simpleMessage("New Device"),
    "noveZarH": MessageLookupByLibrary.simpleMessage("New Device"),
    "noveZariadenieFull": MessageLookupByLibrary.simpleMessage("New Device"),
    "novyP": MessageLookupByLibrary.simpleMessage("New Movement"),
    "novyPohyb": MessageLookupByLibrary.simpleMessage("New Movement"),
    "oblubeneV": MessageLookupByLibrary.simpleMessage("Favorites"),
    "odhlasV": MessageLookupByLibrary.simpleMessage("Log Out"),
    "odkazUrl": MessageLookupByLibrary.simpleMessage("Link / URL"),
    "odstranenyT": MessageLookupByLibrary.simpleMessage("Removed"),
    "odstranit": MessageLookupByLibrary.simpleMessage("Remove"),
    "odstranitTechnika": MessageLookupByLibrary.simpleMessage(
      "Remove Technician?",
    ),
    "odstranitZFirmy": MessageLookupByLibrary.simpleMessage(
      "Remove from company",
    ),
    "opravaPred": MessageLookupByLibrary.simpleMessage("Repair Before"),
    "opravapo": MessageLookupByLibrary.simpleMessage("Repair After"),
    "osemZV": MessageLookupByLibrary.simpleMessage("8+ characters"),
    "panelText": MessageLookupByLibrary.simpleMessage(
      "Asset and Warehouse Management",
    ),
    "pociatocnyStav": MessageLookupByLibrary.simpleMessage("Initial Status"),
    "pohybyT": MessageLookupByLibrary.simpleMessage("Movements"),
    "pohybyTab": MessageLookupByLibrary.simpleMessage("Movements"),
    "pohybyText": MessageLookupByLibrary.simpleMessage("Movements"),
    "pohybyTextH": MessageLookupByLibrary.simpleMessage("Movements"),
    "poloha": m5,
    "popisB": MessageLookupByLibrary.simpleMessage("Description"),
    "popisStavu": MessageLookupByLibrary.simpleMessage("Condition Description"),
    "potvrdenieVymazania": m6,
    "potvrditP": MessageLookupByLibrary.simpleMessage("Confirm Receipt"),
    "potvrditPrijem": MessageLookupByLibrary.simpleMessage("CONFIRM RECEIPT"),
    "potvrditV": MessageLookupByLibrary.simpleMessage("Confirm Issue"),
    "potvrditVydaj": MessageLookupByLibrary.simpleMessage("CONFIRM ISSUE"),
    "povinnePole": MessageLookupByLibrary.simpleMessage("Required field"),
    "poznamkaKServisu": MessageLookupByLibrary.simpleMessage("Service Note"),
    "pregeneratKod": MessageLookupByLibrary.simpleMessage("Regenerate Code?"),
    "prehladyT": MessageLookupByLibrary.simpleMessage("Overview"),
    "pridatB": MessageLookupByLibrary.simpleMessage("Add"),
    "pridatP": MessageLookupByLibrary.simpleMessage("Add"),
    "pridatZariadenie": MessageLookupByLibrary.simpleMessage("Add Device"),
    "prihlasV": MessageLookupByLibrary.simpleMessage("Log In"),
    "prihlasenyPouzivatel": MessageLookupByLibrary.simpleMessage(
      "Logged in user",
    ),
    "prijem": MessageLookupByLibrary.simpleMessage("Receipt"),
    "prijemT": MessageLookupByLibrary.simpleMessage("Receipt"),
    "prilozeneMedia": m7,
    "priloztePrst": MessageLookupByLibrary.simpleMessage(
      "Place your finger to verify",
    ),
    "pripojenieT": MessageLookupByLibrary.simpleMessage("Connection"),
    "pripojitZTrezoru": MessageLookupByLibrary.simpleMessage(
      "Attach from Vault",
    ),
    "profilT": MessageLookupByLibrary.simpleMessage("Profile"),
    "recordAudio": MessageLookupByLibrary.simpleMessage("Record Audio"),
    "registrTV": MessageLookupByLibrary.simpleMessage(
      "Technician Registration",
    ),
    "registrV": MessageLookupByLibrary.simpleMessage("Register"),
    "reviziaOo": MessageLookupByLibrary.simpleMessage("Revision After"),
    "reviziaPred": MessageLookupByLibrary.simpleMessage("Revision Before"),
    "rozumiem": MessageLookupByLibrary.simpleMessage("Got it"),
    "serioveCislo": MessageLookupByLibrary.simpleMessage("Serial Number *"),
    "servisUprava": MessageLookupByLibrary.simpleMessage("Service / Edit"),
    "servisZmenaStavu": MessageLookupByLibrary.simpleMessage("Status Change"),
    "servisneZaznamy": MessageLookupByLibrary.simpleMessage("Service Records"),
    "setloV": MessageLookupByLibrary.simpleMessage("Light"),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("Settings"),
    "skladH": MessageLookupByLibrary.simpleMessage("Warehouse Management"),
    "skladJePrazdny": MessageLookupByLibrary.simpleMessage(
      "Warehouse is empty.",
    ),
    "skladText": MessageLookupByLibrary.simpleMessage("Warehouse"),
    "skladTextH": MessageLookupByLibrary.simpleMessage("Warehouse"),
    "skladoveHospodarstvo": MessageLookupByLibrary.simpleMessage(
      "Warehouse Management",
    ),
    "skladovyPohyb": MessageLookupByLibrary.simpleMessage("Stock Movement"),
    "skopirovaneDo": MessageLookupByLibrary.simpleMessage(
      "Copied to clipboard",
    ),
    "snZ": MessageLookupByLibrary.simpleMessage("SN"),
    "somAV": MessageLookupByLibrary.simpleMessage("I am an Admin"),
    "somAdmin": MessageLookupByLibrary.simpleMessage("I am an Admin"),
    "somTV": MessageLookupByLibrary.simpleMessage("I am a Technician"),
    "somTechnik": MessageLookupByLibrary.simpleMessage("I am a Technician"),
    "spravaAudioV": MessageLookupByLibrary.simpleMessage(
      "Audio saved and encrypted",
    ),
    "stacV": MessageLookupByLibrary.simpleMessage("Press to Record"),
    "staryKodPrestan": MessageLookupByLibrary.simpleMessage(
      "The old code will immediately stop working for new technicians.",
    ),
    "statusDiscarded": MessageLookupByLibrary.simpleMessage("Discarded"),
    "statusFaulty": MessageLookupByLibrary.simpleMessage("Faulty"),
    "statusInOperation": MessageLookupByLibrary.simpleMessage("In Operation"),
    "statusOutOufOrder": MessageLookupByLibrary.simpleMessage("Out of Order"),
    "statusRequiresService": MessageLookupByLibrary.simpleMessage(
      "Requires Service",
    ),
    "statusZ": MessageLookupByLibrary.simpleMessage("Stock Status"),
    "stavSkladuT": MessageLookupByLibrary.simpleMessage("Stock Status"),
    "stavZText": MessageLookupByLibrary.simpleMessage("Stock Status"),
    "stavZasob": MessageLookupByLibrary.simpleMessage("Stock Status"),
    "stlacPreNah": MessageLookupByLibrary.simpleMessage("Press for recording"),
    "stopRecording": MessageLookupByLibrary.simpleMessage("Stop Recording"),
    "suborNatrvaloOdstraneny": MessageLookupByLibrary.simpleMessage(
      "This file will be permanently deleted.",
    ),
    "suborNatrvaloOdstraneny2": MessageLookupByLibrary.simpleMessage(
      "The file will be permanently deleted.",
    ),
    "systemText": MessageLookupByLibrary.simpleMessage("System"),
    "systemV": MessageLookupByLibrary.simpleMessage("System"),
    "technickeParametre": MessageLookupByLibrary.simpleMessage(
      "Technical Parameters",
    ),
    "technickeParametreSection": MessageLookupByLibrary.simpleMessage(
      "Technical Parameters",
    ),
    "technikT": MessageLookupByLibrary.simpleMessage("Technician"),
    "temaT": MessageLookupByLibrary.simpleMessage("App Theme"),
    "tmavoV": MessageLookupByLibrary.simpleMessage("Dark"),
    "trezorFotiekPrazdny": MessageLookupByLibrary.simpleMessage(
      "Photo vault is empty",
    ),
    "trezorNahravokPrazdny": MessageLookupByLibrary.simpleMessage(
      "Recording vault is empty.",
    ),
    "trezorPrazdny": MessageLookupByLibrary.simpleMessage("Vault is empty"),
    "trezorSystem": MessageLookupByLibrary.simpleMessage("Trezor System"),
    "typP": MessageLookupByLibrary.simpleMessage("Type"),
    "ulozitB": MessageLookupByLibrary.simpleMessage("Save"),
    "ulozitReport": MessageLookupByLibrary.simpleMessage("Save Report"),
    "ulozitZariadenie": MessageLookupByLibrary.simpleMessage("SAVE DEVICE"),
    "ulozitZmeny": MessageLookupByLibrary.simpleMessage("SAVE CHANGES"),
    "uspesneNahranychNahravok": m8,
    "uspesneNahranychVidei": m9,
    "uspesneSpraovanychFotiek": m10,
    "uzmateUV": MessageLookupByLibrary.simpleMessage(
      "Already have an account? Log In",
    ),
    "videa": MessageLookupByLibrary.simpleMessage("Videos"),
    "videaNahrate": m11,
    "video": MessageLookupByLibrary.simpleMessage("Video"),
    "videoZasifrovaneUlozene": MessageLookupByLibrary.simpleMessage(
      "Video encrypted and saved",
    ),
    "vitajteVTrezore": MessageLookupByLibrary.simpleMessage(
      "Welcome to Trezor",
    ),
    "vsetkyFilter": MessageLookupByLibrary.simpleMessage("All"),
    "vsetkyT": MessageLookupByLibrary.simpleMessage("All"),
    "vybraneCount": m12,
    "vydaj": MessageLookupByLibrary.simpleMessage("Issue"),
    "vydajT": MessageLookupByLibrary.simpleMessage("Issue"),
    "vymazat": MessageLookupByLibrary.simpleMessage("Delete"),
    "vymazatB": MessageLookupByLibrary.simpleMessage("Delete"),
    "vymazatPolozkyPotvrdenie": m13,
    "vymazatVyber": MessageLookupByLibrary.simpleMessage("Delete selection?"),
    "vymazatZariadenie": MessageLookupByLibrary.simpleMessage("Delete device?"),
    "vzhladT": MessageLookupByLibrary.simpleMessage("Appearance"),
    "wifiT": MessageLookupByLibrary.simpleMessage("Wi-Fi"),
    "zFirmyText": MessageLookupByLibrary.simpleMessage(
      " from the company?\n\nThe technician will lose access to company data and will not be able to log in.",
    ),
    "zadajteEmail": MessageLookupByLibrary.simpleMessage("Enter a valid email"),
    "zadajteHeslo": MessageLookupByLibrary.simpleMessage("Enter password"),
    "zakladneUdaje": MessageLookupByLibrary.simpleMessage("Basic Information"),
    "zakladneUdajeReport": MessageLookupByLibrary.simpleMessage(
      "Basic Information",
    ),
    "zalozFV": MessageLookupByLibrary.simpleMessage("Set up Company"),
    "zariadeniaTab": MessageLookupByLibrary.simpleMessage("Devices"),
    "zariadeniaText": MessageLookupByLibrary.simpleMessage("Devices"),
    "zariadenieBylVymazane": m14,
    "zariadenieVymazane": m15,
    "zdielatT": MessageLookupByLibrary.simpleMessage("Share"),
    "ziadnaHistoria": MessageLookupByLibrary.simpleMessage(
      "No movement history.",
    ),
    "ziadneDoplnkove": MessageLookupByLibrary.simpleMessage(
      "No additional data",
    ),
    "ziadneGps": MessageLookupByLibrary.simpleMessage(
      "No GPS data available for this photo.",
    ),
    "ziadneParametreKlikni": MessageLookupByLibrary.simpleMessage(
      "No parameters – click Add",
    ),
    "ziadneTechParam2": MessageLookupByLibrary.simpleMessage(
      "No technical parameters",
    ),
    "ziadneTechnickeParam": MessageLookupByLibrary.simpleMessage(
      "No technical parameters",
    ),
    "ziadneVidea": MessageLookupByLibrary.simpleMessage(
      "No videos in the vault yet.",
    ),
    "ziadneVysledky": MessageLookupByLibrary.simpleMessage(
      "No results for the selected filter.",
    ),
    "ziadniTechnici": MessageLookupByLibrary.simpleMessage(
      "No technicians yet.",
    ),
    "ziadnyMajjetok": MessageLookupByLibrary.simpleMessage(
      "No assets in the company.",
    ),
    "zmazat": MessageLookupByLibrary.simpleMessage("Delete"),
    "zmazatNahravku": MessageLookupByLibrary.simpleMessage("Delete recording?"),
    "zmazatVideo": MessageLookupByLibrary.simpleMessage("Delete video?"),
    "zmenitT": MessageLookupByLibrary.simpleMessage("Change"),
    "zobrazitZasoby": MessageLookupByLibrary.simpleMessage("View stock"),
    "zoraditAZ": MessageLookupByLibrary.simpleMessage("Sort A–Z"),
    "zrusitB": MessageLookupByLibrary.simpleMessage("Cancel"),
  };
}
