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

  /// `Regenerate Code?`
  String get pregeneratKod {
    return Intl.message(
      'Regenerate Code?',
      name: 'pregeneratKod',
      desc: '',
      args: [],
    );
  }

  /// `The old code will immediately stop working for new technicians.`
  String get staryKodPrestan {
    return Intl.message(
      'The old code will immediately stop working for new technicians.',
      name: 'staryKodPrestan',
      desc: '',
      args: [],
    );
  }

  /// `Yes, change`
  String get anoZmenit {
    return Intl.message('Yes, change', name: 'anoZmenit', desc: '', args: []);
  }

  /// `Code has been changed`
  String get kodBylZmeneny {
    return Intl.message(
      'Code has been changed',
      name: 'kodBylZmeneny',
      desc: '',
      args: [],
    );
  }

  /// `Error changing code`
  String get chybaZmenyKodu {
    return Intl.message(
      'Error changing code',
      name: 'chybaZmenyKodu',
      desc: '',
      args: [],
    );
  }

  /// `Remove Technician?`
  String get odstranitTechnika {
    return Intl.message(
      'Remove Technician?',
      name: 'odstranitTechnika',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove `
  String get naozajOdstranit {
    return Intl.message(
      'Are you sure you want to remove ',
      name: 'naozajOdstranit',
      desc: '',
      args: [],
    );
  }

  /// ` from the company?\n\nThe technician will lose access to company data and will not be able to log in.`
  String get zFirmyText {
    return Intl.message(
      ' from the company?\n\nThe technician will lose access to company data and will not be able to log in.',
      name: 'zFirmyText',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get odstranit {
    return Intl.message('Remove', name: 'odstranit', desc: '', args: []);
  }

  /// `Copied to clipboard`
  String get skopirovaneDo {
    return Intl.message(
      'Copied to clipboard',
      name: 'skopirovaneDo',
      desc: '',
      args: [],
    );
  }

  /// `No technicians yet.`
  String get ziadniTechnici {
    return Intl.message(
      'No technicians yet.',
      name: 'ziadniTechnici',
      desc: '',
      args: [],
    );
  }

  /// `Removed`
  String get odstranenyT {
    return Intl.message('Removed', name: 'odstranenyT', desc: '', args: []);
  }

  /// `Technician`
  String get technikT {
    return Intl.message('Technician', name: 'technikT', desc: '', args: []);
  }

  /// `Remove from company`
  String get odstranitZFirmy {
    return Intl.message(
      'Remove from company',
      name: 'odstranitZFirmy',
      desc: '',
      args: [],
    );
  }

  /// `Error – technician could not be removed.`
  String get chybaTechnika {
    return Intl.message(
      'Error – technician could not be removed.',
      name: 'chybaTechnika',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get naozajO {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'naozajO',
      desc: '',
      args: [],
    );
  }

  /// `Error logging out. Please try again.`
  String get chybaOdhlasenia {
    return Intl.message(
      'Error logging out. Please try again.',
      name: 'chybaOdhlasenia',
      desc: '',
      args: [],
    );
  }

  /// `Error saving recording`
  String get chybaUkladaniaAudio {
    return Intl.message(
      'Error saving recording',
      name: 'chybaUkladaniaAudio',
      desc: '',
      args: [],
    );
  }

  /// `Logged in user`
  String get prihlasenyPouzivatel {
    return Intl.message(
      'Logged in user',
      name: 'prihlasenyPouzivatel',
      desc: '',
      args: [],
    );
  }

  /// `Unknown email`
  String get neznamyEmail {
    return Intl.message(
      'Unknown email',
      name: 'neznamyEmail',
      desc: '',
      args: [],
    );
  }

  /// `Overview`
  String get prehladyT {
    return Intl.message('Overview', name: 'prehladyT', desc: '', args: []);
  }

  /// `Stock Status`
  String get stavSkladuT {
    return Intl.message(
      'Stock Status',
      name: 'stavSkladuT',
      desc: '',
      args: [],
    );
  }

  /// `View stock`
  String get zobrazitZasoby {
    return Intl.message(
      'View stock',
      name: 'zobrazitZasoby',
      desc: '',
      args: [],
    );
  }

  /// `Asset History`
  String get historiaMajjetku {
    return Intl.message(
      'Asset History',
      name: 'historiaMajjetku',
      desc: '',
      args: [],
    );
  }

  /// `Service Records`
  String get servisneZaznamy {
    return Intl.message(
      'Service Records',
      name: 'servisneZaznamy',
      desc: '',
      args: [],
    );
  }

  /// `Trezor System`
  String get trezorSystem {
    return Intl.message(
      'Trezor System',
      name: 'trezorSystem',
      desc: '',
      args: [],
    );
  }

  /// `Trezor`
  String get appTitle {
    return Intl.message('Trezor', name: 'appTitle', desc: '', args: []);
  }

  /// `Place your finger to verify`
  String get priloztePrst {
    return Intl.message(
      'Place your finger to verify',
      name: 'priloztePrst',
      desc: '',
      args: [],
    );
  }

  /// `Successfully uploaded {count} videos.`
  String uspesneNahranychVidei(int count) {
    return Intl.message(
      'Successfully uploaded $count videos.',
      name: 'uspesneNahranychVidei',
      desc: '',
      args: [count],
    );
  }

  /// `No videos in the vault yet.`
  String get ziadneVidea {
    return Intl.message(
      'No videos in the vault yet.',
      name: 'ziadneVidea',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get neznamy {
    return Intl.message('Unknown', name: 'neznamy', desc: '', args: []);
  }

  /// `Delete video?`
  String get zmazatVideo {
    return Intl.message(
      'Delete video?',
      name: 'zmazatVideo',
      desc: '',
      args: [],
    );
  }

  /// `This file will be permanently deleted.`
  String get suborNatrvaloOdstraneny {
    return Intl.message(
      'This file will be permanently deleted.',
      name: 'suborNatrvaloOdstraneny',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get zmazat {
    return Intl.message('Delete', name: 'zmazat', desc: '', args: []);
  }

  /// `Could not play video.`
  String get neporadiloPrehratVideo {
    return Intl.message(
      'Could not play video.',
      name: 'neporadiloPrehratVideo',
      desc: '',
      args: [],
    );
  }

  /// `{count} selected`
  String vybraneCount(int count) {
    return Intl.message(
      '$count selected',
      name: 'vybraneCount',
      desc: '',
      args: [count],
    );
  }

  /// `My Vault`
  String get mojTrezor {
    return Intl.message('My Vault', name: 'mojTrezor', desc: '', args: []);
  }

  /// `Welcome to Trezor`
  String get vitajteVTrezore {
    return Intl.message(
      'Welcome to Trezor',
      name: 'vitajteVTrezore',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid email`
  String get zadajteEmail {
    return Intl.message(
      'Enter a valid email',
      name: 'zadajteEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enter password`
  String get zadajteHeslo {
    return Intl.message(
      'Enter password',
      name: 'zadajteHeslo',
      desc: '',
      args: [],
    );
  }

  /// `Required field`
  String get povinnePole {
    return Intl.message(
      'Required field',
      name: 'povinnePole',
      desc: '',
      args: [],
    );
  }

  /// `I am a Technician`
  String get somTechnik {
    return Intl.message(
      'I am a Technician',
      name: 'somTechnik',
      desc: '',
      args: [],
    );
  }

  /// `I am an Admin`
  String get somAdmin {
    return Intl.message('I am an Admin', name: 'somAdmin', desc: '', args: []);
  }

  /// `Company Name`
  String get nazovFirmy {
    return Intl.message('Company Name', name: 'nazovFirmy', desc: '', args: []);
  }

  /// `Company ID`
  String get ico {
    return Intl.message('Company ID', name: 'ico', desc: '', args: []);
  }

  /// `Biometrics Available`
  String get biometriaTitle {
    return Intl.message(
      'Biometrics Available',
      name: 'biometriaTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your credentials have been saved. Next time you can log in with your fingerprint.`
  String get biometriaContent {
    return Intl.message(
      'Your credentials have been saved. Next time you can log in with your fingerprint.',
      name: 'biometriaContent',
      desc: '',
      args: [],
    );
  }

  /// `Got it`
  String get rozumiem {
    return Intl.message('Got it', name: 'rozumiem', desc: '', args: []);
  }

  /// `You must log in manually first.`
  String get najprvManualne {
    return Intl.message(
      'You must log in manually first.',
      name: 'najprvManualne',
      desc: '',
      args: [],
    );
  }

  /// `Biometrics failed.`
  String get biometriaZlyhala {
    return Intl.message(
      'Biometrics failed.',
      name: 'biometriaZlyhala',
      desc: '',
      args: [],
    );
  }

  /// `Stock Movement`
  String get skladovyPohyb {
    return Intl.message(
      'Stock Movement',
      name: 'skladovyPohyb',
      desc: '',
      args: [],
    );
  }

  /// `Issue`
  String get vydaj {
    return Intl.message('Issue', name: 'vydaj', desc: '', args: []);
  }

  /// `Receipt`
  String get prijem {
    return Intl.message('Receipt', name: 'prijem', desc: '', args: []);
  }

  /// `Item name (select or enter new)`
  String get nazovPolozky {
    return Intl.message(
      'Item name (select or enter new)',
      name: 'nazovPolozky',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get mnozstvo {
    return Intl.message('Quantity', name: 'mnozstvo', desc: '', args: []);
  }

  /// `Additional Data`
  String get doplnkoveUdaje {
    return Intl.message(
      'Additional Data',
      name: 'doplnkoveUdaje',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get nazovHint {
    return Intl.message('Name', name: 'nazovHint', desc: '', args: []);
  }

  /// `Value`
  String get hodnotaHint {
    return Intl.message('Value', name: 'hodnotaHint', desc: '', args: []);
  }

  /// `CONFIRM RECEIPT`
  String get potvrditPrijem {
    return Intl.message(
      'CONFIRM RECEIPT',
      name: 'potvrditPrijem',
      desc: '',
      args: [],
    );
  }

  /// `CONFIRM ISSUE`
  String get potvrditVydaj {
    return Intl.message(
      'CONFIRM ISSUE',
      name: 'potvrditVydaj',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse is empty.`
  String get skladJePrazdny {
    return Intl.message(
      'Warehouse is empty.',
      name: 'skladJePrazdny',
      desc: '',
      args: [],
    );
  }

  /// `Search warehouse...`
  String get hladatVSklade {
    return Intl.message(
      'Search warehouse...',
      name: 'hladatVSklade',
      desc: '',
      args: [],
    );
  }

  /// `Stock Status`
  String get stavZasob {
    return Intl.message('Stock Status', name: 'stavZasob', desc: '', args: []);
  }

  /// `Movements`
  String get pohybyTab {
    return Intl.message('Movements', name: 'pohybyTab', desc: '', args: []);
  }

  /// `New Movement`
  String get novyPohyb {
    return Intl.message('New Movement', name: 'novyPohyb', desc: '', args: []);
  }

  /// `No movement history.`
  String get ziadnaHistoria {
    return Intl.message(
      'No movement history.',
      name: 'ziadnaHistoria',
      desc: '',
      args: [],
    );
  }

  /// `Additional data:`
  String get doplnkoveUdajeLabel {
    return Intl.message(
      'Additional data:',
      name: 'doplnkoveUdajeLabel',
      desc: '',
      args: [],
    );
  }

  /// `No additional data`
  String get ziadneDoplnkove {
    return Intl.message(
      'No additional data',
      name: 'ziadneDoplnkove',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse Management`
  String get skladoveHospodarstvo {
    return Intl.message(
      'Warehouse Management',
      name: 'skladoveHospodarstvo',
      desc: '',
      args: [],
    );
  }

  /// `Photo vault is empty`
  String get trezorFotiekPrazdny {
    return Intl.message(
      'Photo vault is empty',
      name: 'trezorFotiekPrazdny',
      desc: '',
      args: [],
    );
  }

  /// `Successfully processed {count} photos.`
  String uspesneSpraovanychFotiek(int count) {
    return Intl.message(
      'Successfully processed $count photos.',
      name: 'uspesneSpraovanychFotiek',
      desc: '',
      args: [count],
    );
  }

  /// `Delete selection?`
  String get vymazatVyber {
    return Intl.message(
      'Delete selection?',
      name: 'vymazatVyber',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete {count} items?`
  String naozajVymazat(int count) {
    return Intl.message(
      'Are you sure you want to delete $count items?',
      name: 'naozajVymazat',
      desc: '',
      args: [count],
    );
  }

  /// `Delete`
  String get vymazat {
    return Intl.message('Delete', name: 'vymazat', desc: '', args: []);
  }

  /// `Unknown owner`
  String get neznamyMajitel {
    return Intl.message(
      'Unknown owner',
      name: 'neznamyMajitel',
      desc: '',
      args: [],
    );
  }

  /// `Location: {lat}, {lng}`
  String poloha(String lat, String lng) {
    return Intl.message(
      'Location: $lat, $lng',
      name: 'poloha',
      desc: '',
      args: [lat, lng],
    );
  }

  /// `No GPS data available for this photo.`
  String get ziadneGps {
    return Intl.message(
      'No GPS data available for this photo.',
      name: 'ziadneGps',
      desc: '',
      args: [],
    );
  }

  /// `Recording vault is empty.`
  String get trezorNahravokPrazdny {
    return Intl.message(
      'Recording vault is empty.',
      name: 'trezorNahravokPrazdny',
      desc: '',
      args: [],
    );
  }

  /// `Successfully uploaded {count} recordings.`
  String uspesneNahranychNahravok(int count) {
    return Intl.message(
      'Successfully uploaded $count recordings.',
      name: 'uspesneNahranychNahravok',
      desc: '',
      args: [count],
    );
  }

  /// `Could not decrypt or play the recording.`
  String get neporadiloPrehratNahravku {
    return Intl.message(
      'Could not decrypt or play the recording.',
      name: 'neporadiloPrehratNahravku',
      desc: '',
      args: [],
    );
  }

  /// `Delete recording?`
  String get zmazatNahravku {
    return Intl.message(
      'Delete recording?',
      name: 'zmazatNahravku',
      desc: '',
      args: [],
    );
  }

  /// `The file will be permanently deleted.`
  String get suborNatrvaloOdstraneny2 {
    return Intl.message(
      'The file will be permanently deleted.',
      name: 'suborNatrvaloOdstraneny2',
      desc: '',
      args: [],
    );
  }

  /// `Voice Recording`
  String get hlasovaNahravka {
    return Intl.message(
      'Voice Recording',
      name: 'hlasovaNahravka',
      desc: '',
      args: [],
    );
  }

  /// `Asset Management`
  String get evidenciaMajjetku {
    return Intl.message(
      'Asset Management',
      name: 'evidenciaMajjetku',
      desc: '',
      args: [],
    );
  }

  /// `Offline – changes will be saved locally`
  String get bezPripojenia {
    return Intl.message(
      'Offline – changes will be saved locally',
      name: 'bezPripojenia',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'zorаditZA' key

  /// `Sort A–Z`
  String get zoraditAZ {
    return Intl.message('Sort A–Z', name: 'zoraditAZ', desc: '', args: []);
  }

  /// `Devices`
  String get zariadeniaTab {
    return Intl.message('Devices', name: 'zariadeniaTab', desc: '', args: []);
  }

  /// `History`
  String get historiaTab {
    return Intl.message('History', name: 'historiaTab', desc: '', args: []);
  }

  /// `Add Device`
  String get pridatZariadenie {
    return Intl.message(
      'Add Device',
      name: 'pridatZariadenie',
      desc: '',
      args: [],
    );
  }

  /// `Search by name, S/N, model...`
  String get hladatZariadenie {
    return Intl.message(
      'Search by name, S/N, model...',
      name: 'hladatZariadenie',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get vsetkyFilter {
    return Intl.message('All', name: 'vsetkyFilter', desc: '', args: []);
  }

  /// `No results for the selected filter.`
  String get ziadneVysledky {
    return Intl.message(
      'No results for the selected filter.',
      name: 'ziadneVysledky',
      desc: '',
      args: [],
    );
  }

  /// `No assets in the company.`
  String get ziadnyMajjetok {
    return Intl.message(
      'No assets in the company.',
      name: 'ziadnyMajjetok',
      desc: '',
      args: [],
    );
  }

  /// `Delete device?`
  String get vymazatZariadenie {
    return Intl.message(
      'Delete device?',
      name: 'vymazatZariadenie',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete "{name}"?\nThis action cannot be undone.`
  String naozajVymazatZariadenie(String name) {
    return Intl.message(
      'Are you sure you want to delete "$name"?\nThis action cannot be undone.',
      name: 'naozajVymazatZariadenie',
      desc: '',
      args: [name],
    );
  }

  /// `"{name}" has been deleted.`
  String zariadenieBylVymazane(String name) {
    return Intl.message(
      '"$name" has been deleted.',
      name: 'zariadenieBylVymazane',
      desc: '',
      args: [name],
    );
  }

  /// `No technical parameters`
  String get ziadneTechnickeParam {
    return Intl.message(
      'No technical parameters',
      name: 'ziadneTechnickeParam',
      desc: '',
      args: [],
    );
  }

  /// `Service / Edit`
  String get servisUprava {
    return Intl.message(
      'Service / Edit',
      name: 'servisUprava',
      desc: '',
      args: [],
    );
  }

  /// `Technical Parameters`
  String get technickeParametre {
    return Intl.message(
      'Technical Parameters',
      name: 'technickeParametre',
      desc: '',
      args: [],
    );
  }

  /// `New Device`
  String get noveZariadenieFull {
    return Intl.message(
      'New Device',
      name: 'noveZariadenieFull',
      desc: '',
      args: [],
    );
  }

  /// `Basic Information`
  String get zakladneUdaje {
    return Intl.message(
      'Basic Information',
      name: 'zakladneUdaje',
      desc: '',
      args: [],
    );
  }

  /// `Device Name *`
  String get nazovZariadenia {
    return Intl.message(
      'Device Name *',
      name: 'nazovZariadenia',
      desc: '',
      args: [],
    );
  }

  /// `Serial Number *`
  String get serioveCislo {
    return Intl.message(
      'Serial Number *',
      name: 'serioveCislo',
      desc: '',
      args: [],
    );
  }

  /// `Link / URL`
  String get odkazUrl {
    return Intl.message('Link / URL', name: 'odkazUrl', desc: '', args: []);
  }

  /// `Initial Status`
  String get pociatocnyStav {
    return Intl.message(
      'Initial Status',
      name: 'pociatocnyStav',
      desc: '',
      args: [],
    );
  }

  /// `Technical Parameters`
  String get technickeParametreSection {
    return Intl.message(
      'Technical Parameters',
      name: 'technickeParametreSection',
      desc: '',
      args: [],
    );
  }

  /// `No parameters – click Add`
  String get ziadneParametreKlikni {
    return Intl.message(
      'No parameters – click Add',
      name: 'ziadneParametreKlikni',
      desc: '',
      args: [],
    );
  }

  /// `SAVE DEVICE`
  String get ulozitZariadenie {
    return Intl.message(
      'SAVE DEVICE',
      name: 'ulozitZariadenie',
      desc: '',
      args: [],
    );
  }

  /// `Name and serial number are required.`
  String get nazovASerioveCisloPovinne {
    return Intl.message(
      'Name and serial number are required.',
      name: 'nazovASerioveCisloPovinne',
      desc: '',
      args: [],
    );
  }

  /// `Status Change`
  String get servisZmenaStavu {
    return Intl.message(
      'Status Change',
      name: 'servisZmenaStavu',
      desc: '',
      args: [],
    );
  }

  /// `Service Note`
  String get poznamkaKServisu {
    return Intl.message(
      'Service Note',
      name: 'poznamkaKServisu',
      desc: '',
      args: [],
    );
  }

  /// `Add Parameters`
  String get doplnitParametre {
    return Intl.message(
      'Add Parameters',
      name: 'doplnitParametre',
      desc: '',
      args: [],
    );
  }

  /// `New Field`
  String get novePole {
    return Intl.message('New Field', name: 'novePole', desc: '', args: []);
  }

  /// `SAVE CHANGES`
  String get ulozitZmeny {
    return Intl.message(
      'SAVE CHANGES',
      name: 'ulozitZmeny',
      desc: '',
      args: [],
    );
  }

  /// `History is empty.`
  String get historiaPrazdna {
    return Intl.message(
      'History is empty.',
      name: 'historiaPrazdna',
      desc: '',
      args: [],
    );
  }

  /// `No technical parameters`
  String get ziadneTechParam2 {
    return Intl.message(
      'No technical parameters',
      name: 'ziadneTechParam2',
      desc: '',
      args: [],
    );
  }

  /// `Save Report`
  String get ulozitReport {
    return Intl.message(
      'Save Report',
      name: 'ulozitReport',
      desc: '',
      args: [],
    );
  }

  /// `Basic Information`
  String get zakladneUdajeReport {
    return Intl.message(
      'Basic Information',
      name: 'zakladneUdajeReport',
      desc: '',
      args: [],
    );
  }

  /// `Name / Revision Number`
  String get nazovCisloRevizie {
    return Intl.message(
      'Name / Revision Number',
      name: 'nazovCisloRevizie',
      desc: '',
      args: [],
    );
  }

  /// `Condition Description`
  String get popisStavu {
    return Intl.message(
      'Condition Description',
      name: 'popisStavu',
      desc: '',
      args: [],
    );
  }

  /// `Attached Media ({count})`
  String prilozeneMedia(int count) {
    return Intl.message(
      'Attached Media ($count)',
      name: 'prilozeneMedia',
      desc: '',
      args: [count],
    );
  }

  /// `Attach from Vault`
  String get pripojitZTrezoru {
    return Intl.message(
      'Attach from Vault',
      name: 'pripojitZTrezoru',
      desc: '',
      args: [],
    );
  }

  /// `Photos`
  String get fotky {
    return Intl.message('Photos', name: 'fotky', desc: '', args: []);
  }

  /// `Videos`
  String get videa {
    return Intl.message('Videos', name: 'videa', desc: '', args: []);
  }

  /// `Done`
  String get hotovo {
    return Intl.message('Done', name: 'hotovo', desc: '', args: []);
  }

  /// `Vault is empty`
  String get trezorPrazdny {
    return Intl.message(
      'Vault is empty',
      name: 'trezorPrazdny',
      desc: '',
      args: [],
    );
  }

  /// `Documentation for: {title}`
  String dokumentaciaPreTitle(String title) {
    return Intl.message(
      'Documentation for: $title',
      name: 'dokumentaciaPreTitle',
      desc: '',
      args: [title],
    );
  }

  // skipped getter for the 'zatialZiadneSúbory' key

  /// `Revision Before`
  String get reviziaPred {
    return Intl.message(
      'Revision Before',
      name: 'reviziaPred',
      desc: '',
      args: [],
    );
  }

  /// `Revision After`
  String get reviziaOo {
    return Intl.message(
      'Revision After',
      name: 'reviziaOo',
      desc: '',
      args: [],
    );
  }

  /// `Repair Before`
  String get opravaPred {
    return Intl.message(
      'Repair Before',
      name: 'opravaPred',
      desc: '',
      args: [],
    );
  }

  /// `Repair After`
  String get opravapo {
    return Intl.message('Repair After', name: 'opravapo', desc: '', args: []);
  }

  /// `Video encrypted and saved`
  String get videoZasifrovaneUlozene {
    return Intl.message(
      'Video encrypted and saved',
      name: 'videoZasifrovaneUlozene',
      desc: '',
      args: [],
    );
  }

  /// `In Operation`
  String get statusInOperation {
    return Intl.message(
      'In Operation',
      name: 'statusInOperation',
      desc: '',
      args: [],
    );
  }

  /// `Requires Service`
  String get statusRequiresService {
    return Intl.message(
      'Requires Service',
      name: 'statusRequiresService',
      desc: '',
      args: [],
    );
  }

  /// `Faulty`
  String get statusFaulty {
    return Intl.message('Faulty', name: 'statusFaulty', desc: '', args: []);
  }

  /// `Out of Order`
  String get statusOutOufOrder {
    return Intl.message(
      'Out of Order',
      name: 'statusOutOufOrder',
      desc: '',
      args: [],
    );
  }

  /// `Discarded`
  String get statusDiscarded {
    return Intl.message(
      'Discarded',
      name: 'statusDiscarded',
      desc: '',
      args: [],
    );
  }

  /// `recording`
  String get nahravam {
    return Intl.message('recording', name: 'nahravam', desc: '', args: []);
  }

  /// `Press for recording`
  String get stlacPreNah {
    return Intl.message(
      'Press for recording',
      name: 'stlacPreNah',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to delete "{name}"?\nThis action is irreversible.`
  String potvrdenieVymazania(String name) {
    return Intl.message(
      'Do you really want to delete "$name"?\nThis action is irreversible.',
      name: 'potvrdenieVymazania',
      desc: '',
      args: [name],
    );
  }

  /// `"{name}" has been deleted.`
  String zariadenieVymazane(String name) {
    return Intl.message(
      '"$name" has been deleted.',
      name: 'zariadenieVymazane',
      desc: '',
      args: [name],
    );
  }

  /// `{count, plural, one{Successfully processed {count} photo.} other{Successfully processed {count} photos.}}`
  String fotkySpracovane(int count) {
    return Intl.plural(
      count,
      one: 'Successfully processed $count photo.',
      other: 'Successfully processed $count photos.',
      name: 'fotkySpracovane',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{Do you really want to delete one item?} other{Do you really want to delete {count} items?}}`
  String vymazatPolozkyPotvrdenie(int count) {
    return Intl.plural(
      count,
      one: 'Do you really want to delete one item?',
      other: 'Do you really want to delete $count items?',
      name: 'vymazatPolozkyPotvrdenie',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{Successfully uploaded {count} video.} other{Successfully uploaded {count} videos.}}`
  String videaNahrate(int count) {
    return Intl.plural(
      count,
      one: 'Successfully uploaded $count video.',
      other: 'Successfully uploaded $count videos.',
      name: 'videaNahrate',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{Successfully uploaded {count} recording.} other{Successfully uploaded {count} recordings.}}`
  String nahravkyNahrate(int count) {
    return Intl.plural(
      count,
      one: 'Successfully uploaded $count recording.',
      other: 'Successfully uploaded $count recordings.',
      name: 'nahravkyNahrate',
      desc: '',
      args: [count],
    );
  }

  /// `Hi, log in to our Trezor app using the code: {code}`
  String prihlasovaciKod(String code) {
    return Intl.message(
      'Hi, log in to our Trezor app using the code: $code',
      name: 'prihlasovaciKod',
      desc: '',
      args: [code],
    );
  }

  /// `{email} has been removed from the company.`
  String pouzivatelOdstraneny(String email) {
    return Intl.message(
      '$email has been removed from the company.',
      name: 'pouzivatelOdstraneny',
      desc: '',
      args: [email],
    );
  }

  /// `{count, plural, one{Synchronization of one item successful} other{Synchronization of {count} items successful}}`
  String syncUspesna(int count) {
    return Intl.plural(
      count,
      one: 'Synchronization of one item successful',
      other: 'Synchronization of $count items successful',
      name: 'syncUspesna',
      desc: '',
      args: [count],
    );
  }

  /// `Error during synchronization`
  String get chybaSync {
    return Intl.message(
      'Error during synchronization',
      name: 'chybaSync',
      desc: '',
      args: [],
    );
  }

  /// `Sending...`
  String get odosielam {
    return Intl.message('Sending...', name: 'odosielam', desc: '', args: []);
  }

  /// `Upload to cloud`
  String get odoslatDoCloudu {
    return Intl.message(
      'Upload to cloud',
      name: 'odoslatDoCloudu',
      desc: '',
      args: [],
    );
  }

  /// `Please authenticate to continue`
  String get dovodBiometrie {
    return Intl.message(
      'Please authenticate to continue',
      name: 'dovodBiometrie',
      desc: '',
      args: [],
    );
  }

  /// `Your account has been removed from the company. Please contact the administrator.`
  String get ucetOdstranenyInfo {
    return Intl.message(
      'Your account has been removed from the company. Please contact the administrator.',
      name: 'ucetOdstranenyInfo',
      desc: '',
      args: [],
    );
  }

  /// `This invitation code is invalid.`
  String get chybaNeplatnyKod {
    return Intl.message(
      'This invitation code is invalid.',
      name: 'chybaNeplatnyKod',
      desc: '',
      args: [],
    );
  }

  /// `Recording file not found.`
  String get chybaSuborNeexistuje {
    return Intl.message(
      'Recording file not found.',
      name: 'chybaSuborNeexistuje',
      desc: '',
      args: [],
    );
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
