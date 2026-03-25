// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Home`
  String get homeTitle {
    return Intl.message('Home', name: 'homeTitle', desc: '', args: []);
  }

  /// `Settings`
  String get settingsTitle {
    return Intl.message('Settings', name: 'settingsTitle', desc: '', args: []);
  }

  /// `Record Audio`
  String get recordAudio {
    return Intl.message(
      'Record Audio',
      name: 'recordAudio',
      desc: '',
      args: [],
    );
  }

  /// `Stop Recording`
  String get stopRecording {
    return Intl.message(
      'Stop Recording',
      name: 'stopRecording',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get cameraIcon {
    return Intl.message('Camera', name: 'cameraIcon', desc: '', args: []);
  }

  /// `Gallery`
  String get galleryIcon {
    return Intl.message('Gallery', name: 'galleryIcon', desc: '', args: []);
  }

  /// `Audio`
  String get audioIcon {
    return Intl.message('Audio', name: 'audioIcon', desc: '', args: []);
  }

  /// `Home Screen`
  String get homeText {
    return Intl.message('Home Screen', name: 'homeText', desc: '', args: []);
  }

  /// `Asset and Warehouse Management`
  String get panelText {
    return Intl.message(
      'Asset and Warehouse Management',
      name: 'panelText',
      desc: '',
      args: [],
    );
  }

  /// `Evidence`
  String get evidenciaText {
    return Intl.message('Evidence', name: 'evidenciaText', desc: '', args: []);
  }

  /// `Devices`
  String get zariadeniaText {
    return Intl.message('Devices', name: 'zariadeniaText', desc: '', args: []);
  }

  /// `Records History`
  String get historiaKText {
    return Intl.message(
      'Records History',
      name: 'historiaKText',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse`
  String get skladText {
    return Intl.message('Warehouse', name: 'skladText', desc: '', args: []);
  }

  /// `Stock Status`
  String get stavZText {
    return Intl.message('Stock Status', name: 'stavZText', desc: '', args: []);
  }

  /// `Movements`
  String get pohybyText {
    return Intl.message('Movements', name: 'pohybyText', desc: '', args: []);
  }

  /// `System`
  String get systemText {
    return Intl.message('System', name: 'systemText', desc: '', args: []);
  }

  /// `Log Out`
  String get logoutText {
    return Intl.message('Log Out', name: 'logoutText', desc: '', args: []);
  }

  /// `Evidence`
  String get evidenciaTextH {
    return Intl.message('Evidence', name: 'evidenciaTextH', desc: '', args: []);
  }

  /// `Devices`
  String get Zariadenia {
    return Intl.message('Devices', name: 'Zariadenia', desc: '', args: []);
  }

  /// `History`
  String get historiaKTextH {
    return Intl.message('History', name: 'historiaKTextH', desc: '', args: []);
  }

  /// `Movements`
  String get pohybyTextH {
    return Intl.message('Movements', name: 'pohybyTextH', desc: '', args: []);
  }

  /// `Warehouse`
  String get skladTextH {
    return Intl.message('Warehouse', name: 'skladTextH', desc: '', args: []);
  }

  /// `Add`
  String get pridatB {
    return Intl.message('Add', name: 'pridatB', desc: '', args: []);
  }

  /// `Delete`
  String get vymazatB {
    return Intl.message('Delete', name: 'vymazatB', desc: '', args: []);
  }

  /// `Save`
  String get ulozitB {
    return Intl.message('Save', name: 'ulozitB', desc: '', args: []);
  }

  /// `Cancel`
  String get zrusitB {
    return Intl.message('Cancel', name: 'zrusitB', desc: '', args: []);
  }

  /// `Description`
  String get popisB {
    return Intl.message('Description', name: 'popisB', desc: '', args: []);
  }

  /// `New Device`
  String get noveZar {
    return Intl.message('New Device', name: 'noveZar', desc: '', args: []);
  }

  /// `New Device`
  String get noveZarH {
    return Intl.message('New Device', name: 'noveZarH', desc: '', args: []);
  }

  /// `Name`
  String get nazovZ {
    return Intl.message('Name', name: 'nazovZ', desc: '', args: []);
  }

  /// `SN`
  String get snZ {
    return Intl.message('SN', name: 'snZ', desc: '', args: []);
  }

  /// `Model`
  String get modelZ {
    return Intl.message('Model', name: 'modelZ', desc: '', args: []);
  }

  /// `Warehouse Management`
  String get skladH {
    return Intl.message(
      'Warehouse Management',
      name: 'skladH',
      desc: '',
      args: [],
    );
  }

  /// `Stock Status`
  String get statusZ {
    return Intl.message('Stock Status', name: 'statusZ', desc: '', args: []);
  }

  /// `Movements`
  String get pohybyT {
    return Intl.message('Movements', name: 'pohybyT', desc: '', args: []);
  }

  /// `Search Warehouse`
  String get Hladanie {
    return Intl.message(
      'Search Warehouse',
      name: 'Hladanie',
      desc: '',
      args: [],
    );
  }

  /// `New Movement`
  String get novyP {
    return Intl.message('New Movement', name: 'novyP', desc: '', args: []);
  }

  /// `Issue`
  String get vydajT {
    return Intl.message('Issue', name: 'vydajT', desc: '', args: []);
  }

  /// `Receipt`
  String get prijemT {
    return Intl.message('Receipt', name: 'prijemT', desc: '', args: []);
  }

  /// `Item Name`
  String get nazovP {
    return Intl.message('Item Name', name: 'nazovP', desc: '', args: []);
  }

  /// `Quantity`
  String get mnozstvoP {
    return Intl.message('Quantity', name: 'mnozstvoP', desc: '', args: []);
  }

  /// `Type`
  String get typP {
    return Intl.message('Type', name: 'typP', desc: '', args: []);
  }

  /// `Additional Info`
  String get doplnkoveu {
    return Intl.message(
      'Additional Info',
      name: 'doplnkoveu',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get pridatP {
    return Intl.message('Add', name: 'pridatP', desc: '', args: []);
  }

  /// `Confirm Issue`
  String get potvrditV {
    return Intl.message('Confirm Issue', name: 'potvrditV', desc: '', args: []);
  }

  /// `Confirm Receipt`
  String get potvrditP {
    return Intl.message(
      'Confirm Receipt',
      name: 'potvrditP',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get nastaveniaH {
    return Intl.message('Settings', name: 'nastaveniaH', desc: '', args: []);
  }

  /// `Company Access (Admin)`
  String get firemPris {
    return Intl.message(
      'Company Access (Admin)',
      name: 'firemPris',
      desc: '',
      args: [],
    );
  }

  /// `Entry Code for Technicians`
  String get kodPreT {
    return Intl.message(
      'Entry Code for Technicians',
      name: 'kodPreT',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get kopy {
    return Intl.message('Copy', name: 'kopy', desc: '', args: []);
  }

  /// `Share`
  String get zdielatT {
    return Intl.message('Share', name: 'zdielatT', desc: '', args: []);
  }

  /// `Change`
  String get zmenitT {
    return Intl.message('Change', name: 'zmenitT', desc: '', args: []);
  }

  /// `My Technicians`
  String get mojiT {
    return Intl.message('My Technicians', name: 'mojiT', desc: '', args: []);
  }

  /// `Profile`
  String get profilT {
    return Intl.message('Profile', name: 'profilT', desc: '', args: []);
  }

  /// `Connection`
  String get pripojenieT {
    return Intl.message('Connection', name: 'pripojenieT', desc: '', args: []);
  }

  /// `Wi-Fi`
  String get wifiT {
    return Intl.message('Wi-Fi', name: 'wifiT', desc: '', args: []);
  }

  /// `Mobile Connection`
  String get mobilDH {
    return Intl.message(
      'Mobile Connection',
      name: 'mobilDH',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get vzhladT {
    return Intl.message('Appearance', name: 'vzhladT', desc: '', args: []);
  }

  /// `App Theme`
  String get temaT {
    return Intl.message('App Theme', name: 'temaT', desc: '', args: []);
  }

  /// `System`
  String get systemV {
    return Intl.message('System', name: 'systemV', desc: '', args: []);
  }

  /// `Light`
  String get setloV {
    return Intl.message('Light', name: 'setloV', desc: '', args: []);
  }

  /// `Dark`
  String get tmavoV {
    return Intl.message('Dark', name: 'tmavoV', desc: '', args: []);
  }

  /// `Log Out`
  String get odhlasV {
    return Intl.message('Log Out', name: 'odhlasV', desc: '', args: []);
  }

  /// `Log In`
  String get prihlasV {
    return Intl.message('Log In', name: 'prihlasV', desc: '', args: []);
  }

  /// `Photo`
  String get foto {
    return Intl.message('Photo', name: 'foto', desc: '', args: []);
  }

  /// `Video`
  String get video {
    return Intl.message('Video', name: 'video', desc: '', args: []);
  }

  /// `Audio`
  String get audio {
    return Intl.message('Audio', name: 'audio', desc: '', args: []);
  }

  /// `All`
  String get vsetkyT {
    return Intl.message('All', name: 'vsetkyT', desc: '', args: []);
  }

  /// `Favorites`
  String get oblubeneV {
    return Intl.message('Favorites', name: 'oblubeneV', desc: '', args: []);
  }

  /// `Press to Record`
  String get stacV {
    return Intl.message('Press to Record', name: 'stacV', desc: '', args: []);
  }

  /// `Recording`
  String get nahravamV {
    return Intl.message('Recording', name: 'nahravamV', desc: '', args: []);
  }

  /// `Audio saved and encrypted`
  String get spravaAudioV {
    return Intl.message(
      'Audio saved and encrypted',
      name: 'spravaAudioV',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Trezor`
  String get nadpisV {
    return Intl.message(
      'Welcome to Trezor',
      name: 'nadpisV',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get hesloV {
    return Intl.message('Password', name: 'hesloV', desc: '', args: []);
  }

  /// `New to the system? Register`
  String get RegistraciaV {
    return Intl.message(
      'New to the system? Register',
      name: 'RegistraciaV',
      desc: '',
      args: [],
    );
  }

  /// `I am a Technician`
  String get somTV {
    return Intl.message('I am a Technician', name: 'somTV', desc: '', args: []);
  }

  /// `I am an Admin`
  String get somAV {
    return Intl.message('I am an Admin', name: 'somAV', desc: '', args: []);
  }

  /// `8+ characters`
  String get osemZV {
    return Intl.message('8+ characters', name: 'osemZV', desc: '', args: []);
  }

  /// `Code from Admin`
  String get kodOdAdmina {
    return Intl.message(
      'Code from Admin',
      name: 'kodOdAdmina',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get registrV {
    return Intl.message('Register', name: 'registrV', desc: '', args: []);
  }

  /// `Already have an account? Log In`
  String get uzmateUV {
    return Intl.message(
      'Already have an account? Log In',
      name: 'uzmateUV',
      desc: '',
      args: [],
    );
  }

  /// `Technician Registration`
  String get registrTV {
    return Intl.message(
      'Technician Registration',
      name: 'registrTV',
      desc: '',
      args: [],
    );
  }

  /// `Set up Company`
  String get zalozFV {
    return Intl.message('Set up Company', name: 'zalozFV', desc: '', args: []);
  }

  /// `Company Name`
  String get nazovFV {
    return Intl.message('Company Name', name: 'nazovFV', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'sk'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
