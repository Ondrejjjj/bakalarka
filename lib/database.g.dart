// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyCodeMeta = const VerificationMeta(
    'companyCode',
  );
  @override
  late final GeneratedColumn<String> companyCode = GeneratedColumn<String>(
    'company_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, uid, email, role, companyCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('company_code')) {
      context.handle(
        _companyCodeMeta,
        companyCode.isAcceptableOrUnknown(
          data['company_code']!,
          _companyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companyCodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      companyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_code'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String uid;
  final String email;
  final String role;
  final String companyCode;
  const User({
    required this.id,
    required this.uid,
    required this.email,
    required this.role,
    required this.companyCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
    map['company_code'] = Variable<String>(companyCode);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      uid: Value(uid),
      email: Value(email),
      role: Value(role),
      companyCode: Value(companyCode),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
      companyCode: serializer.fromJson<String>(json['companyCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
      'companyCode': serializer.toJson<String>(companyCode),
    };
  }

  User copyWith({
    int? id,
    String? uid,
    String? email,
    String? role,
    String? companyCode,
  }) => User(
    id: id ?? this.id,
    uid: uid ?? this.uid,
    email: email ?? this.email,
    role: role ?? this.role,
    companyCode: companyCode ?? this.companyCode,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      uid: data.uid.present ? data.uid.value : this.uid,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      companyCode: data.companyCode.present
          ? data.companyCode.value
          : this.companyCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('companyCode: $companyCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uid, email, role, companyCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.email == this.email &&
          other.role == this.role &&
          other.companyCode == this.companyCode);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> uid;
  final Value<String> email;
  final Value<String> role;
  final Value<String> companyCode;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.companyCode = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String uid,
    required String email,
    required String role,
    required String companyCode,
  }) : uid = Value(uid),
       email = Value(email),
       role = Value(role),
       companyCode = Value(companyCode);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<String>? email,
    Expression<String>? role,
    Expression<String>? companyCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (companyCode != null) 'company_code': companyCode,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? uid,
    Value<String>? email,
    Value<String>? role,
    Value<String>? companyCode,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      companyCode: companyCode ?? this.companyCode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (companyCode.present) {
      map['company_code'] = Variable<String>(companyCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('companyCode: $companyCode')
          ..write(')'))
        .toString();
  }
}

class $AssetsTable extends Assets with TableInfo<$AssetsTable, Asset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _firebaseIdMeta = const VerificationMeta(
    'firebaseId',
  );
  @override
  late final GeneratedColumn<String> firebaseId = GeneratedColumn<String>(
    'firebase_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snMeta = const VerificationMeta('sn');
  @override
  late final GeneratedColumn<String> sn = GeneratedColumn<String>(
    'sn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _techSpecsMeta = const VerificationMeta(
    'techSpecs',
  );
  @override
  late final GeneratedColumn<String> techSpecs = GeneratedColumn<String>(
    'tech_specs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _historyMeta = const VerificationMeta(
    'history',
  );
  @override
  late final GeneratedColumn<String> history = GeneratedColumn<String>(
    'history',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userEmailMeta = const VerificationMeta(
    'userEmail',
  );
  @override
  late final GeneratedColumn<String> userEmail = GeneratedColumn<String>(
    'user_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyCodeMeta = const VerificationMeta(
    'companyCode',
  );
  @override
  late final GeneratedColumn<String> companyCode = GeneratedColumn<String>(
    'company_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isUploadedMeta = const VerificationMeta(
    'isUploaded',
  );
  @override
  late final GeneratedColumn<bool> isUploaded = GeneratedColumn<bool>(
    'is_uploaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_uploaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firebaseId,
    name,
    sn,
    model,
    url,
    status,
    techSpecs,
    history,
    userEmail,
    companyCode,
    isUploaded,
    lastModified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Asset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('firebase_id')) {
      context.handle(
        _firebaseIdMeta,
        firebaseId.isAcceptableOrUnknown(data['firebase_id']!, _firebaseIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sn')) {
      context.handle(_snMeta, sn.isAcceptableOrUnknown(data['sn']!, _snMeta));
    } else if (isInserting) {
      context.missing(_snMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('tech_specs')) {
      context.handle(
        _techSpecsMeta,
        techSpecs.isAcceptableOrUnknown(data['tech_specs']!, _techSpecsMeta),
      );
    } else if (isInserting) {
      context.missing(_techSpecsMeta);
    }
    if (data.containsKey('history')) {
      context.handle(
        _historyMeta,
        history.isAcceptableOrUnknown(data['history']!, _historyMeta),
      );
    } else if (isInserting) {
      context.missing(_historyMeta);
    }
    if (data.containsKey('user_email')) {
      context.handle(
        _userEmailMeta,
        userEmail.isAcceptableOrUnknown(data['user_email']!, _userEmailMeta),
      );
    } else if (isInserting) {
      context.missing(_userEmailMeta);
    }
    if (data.containsKey('company_code')) {
      context.handle(
        _companyCodeMeta,
        companyCode.isAcceptableOrUnknown(
          data['company_code']!,
          _companyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companyCodeMeta);
    }
    if (data.containsKey('is_uploaded')) {
      context.handle(
        _isUploadedMeta,
        isUploaded.isAcceptableOrUnknown(data['is_uploaded']!, _isUploadedMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Asset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Asset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      firebaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firebase_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sn'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      techSpecs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tech_specs'],
      )!,
      history: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}history'],
      )!,
      userEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_email'],
      )!,
      companyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_code'],
      )!,
      isUploaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_uploaded'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
    );
  }

  @override
  $AssetsTable createAlias(String alias) {
    return $AssetsTable(attachedDatabase, alias);
  }
}

class Asset extends DataClass implements Insertable<Asset> {
  final int id;
  final String? firebaseId;
  final String name;
  final String sn;
  final String model;
  final String? url;
  final String status;
  final String techSpecs;
  final String history;
  final String userEmail;
  final String companyCode;
  final bool isUploaded;
  final DateTime lastModified;
  const Asset({
    required this.id,
    this.firebaseId,
    required this.name,
    required this.sn,
    required this.model,
    this.url,
    required this.status,
    required this.techSpecs,
    required this.history,
    required this.userEmail,
    required this.companyCode,
    required this.isUploaded,
    required this.lastModified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || firebaseId != null) {
      map['firebase_id'] = Variable<String>(firebaseId);
    }
    map['name'] = Variable<String>(name);
    map['sn'] = Variable<String>(sn);
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    map['status'] = Variable<String>(status);
    map['tech_specs'] = Variable<String>(techSpecs);
    map['history'] = Variable<String>(history);
    map['user_email'] = Variable<String>(userEmail);
    map['company_code'] = Variable<String>(companyCode);
    map['is_uploaded'] = Variable<bool>(isUploaded);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  AssetsCompanion toCompanion(bool nullToAbsent) {
    return AssetsCompanion(
      id: Value(id),
      firebaseId: firebaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(firebaseId),
      name: Value(name),
      sn: Value(sn),
      model: Value(model),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      status: Value(status),
      techSpecs: Value(techSpecs),
      history: Value(history),
      userEmail: Value(userEmail),
      companyCode: Value(companyCode),
      isUploaded: Value(isUploaded),
      lastModified: Value(lastModified),
    );
  }

  factory Asset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Asset(
      id: serializer.fromJson<int>(json['id']),
      firebaseId: serializer.fromJson<String?>(json['firebaseId']),
      name: serializer.fromJson<String>(json['name']),
      sn: serializer.fromJson<String>(json['sn']),
      model: serializer.fromJson<String>(json['model']),
      url: serializer.fromJson<String?>(json['url']),
      status: serializer.fromJson<String>(json['status']),
      techSpecs: serializer.fromJson<String>(json['techSpecs']),
      history: serializer.fromJson<String>(json['history']),
      userEmail: serializer.fromJson<String>(json['userEmail']),
      companyCode: serializer.fromJson<String>(json['companyCode']),
      isUploaded: serializer.fromJson<bool>(json['isUploaded']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'firebaseId': serializer.toJson<String?>(firebaseId),
      'name': serializer.toJson<String>(name),
      'sn': serializer.toJson<String>(sn),
      'model': serializer.toJson<String>(model),
      'url': serializer.toJson<String?>(url),
      'status': serializer.toJson<String>(status),
      'techSpecs': serializer.toJson<String>(techSpecs),
      'history': serializer.toJson<String>(history),
      'userEmail': serializer.toJson<String>(userEmail),
      'companyCode': serializer.toJson<String>(companyCode),
      'isUploaded': serializer.toJson<bool>(isUploaded),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  Asset copyWith({
    int? id,
    Value<String?> firebaseId = const Value.absent(),
    String? name,
    String? sn,
    String? model,
    Value<String?> url = const Value.absent(),
    String? status,
    String? techSpecs,
    String? history,
    String? userEmail,
    String? companyCode,
    bool? isUploaded,
    DateTime? lastModified,
  }) => Asset(
    id: id ?? this.id,
    firebaseId: firebaseId.present ? firebaseId.value : this.firebaseId,
    name: name ?? this.name,
    sn: sn ?? this.sn,
    model: model ?? this.model,
    url: url.present ? url.value : this.url,
    status: status ?? this.status,
    techSpecs: techSpecs ?? this.techSpecs,
    history: history ?? this.history,
    userEmail: userEmail ?? this.userEmail,
    companyCode: companyCode ?? this.companyCode,
    isUploaded: isUploaded ?? this.isUploaded,
    lastModified: lastModified ?? this.lastModified,
  );
  Asset copyWithCompanion(AssetsCompanion data) {
    return Asset(
      id: data.id.present ? data.id.value : this.id,
      firebaseId: data.firebaseId.present
          ? data.firebaseId.value
          : this.firebaseId,
      name: data.name.present ? data.name.value : this.name,
      sn: data.sn.present ? data.sn.value : this.sn,
      model: data.model.present ? data.model.value : this.model,
      url: data.url.present ? data.url.value : this.url,
      status: data.status.present ? data.status.value : this.status,
      techSpecs: data.techSpecs.present ? data.techSpecs.value : this.techSpecs,
      history: data.history.present ? data.history.value : this.history,
      userEmail: data.userEmail.present ? data.userEmail.value : this.userEmail,
      companyCode: data.companyCode.present
          ? data.companyCode.value
          : this.companyCode,
      isUploaded: data.isUploaded.present
          ? data.isUploaded.value
          : this.isUploaded,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Asset(')
          ..write('id: $id, ')
          ..write('firebaseId: $firebaseId, ')
          ..write('name: $name, ')
          ..write('sn: $sn, ')
          ..write('model: $model, ')
          ..write('url: $url, ')
          ..write('status: $status, ')
          ..write('techSpecs: $techSpecs, ')
          ..write('history: $history, ')
          ..write('userEmail: $userEmail, ')
          ..write('companyCode: $companyCode, ')
          ..write('isUploaded: $isUploaded, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firebaseId,
    name,
    sn,
    model,
    url,
    status,
    techSpecs,
    history,
    userEmail,
    companyCode,
    isUploaded,
    lastModified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Asset &&
          other.id == this.id &&
          other.firebaseId == this.firebaseId &&
          other.name == this.name &&
          other.sn == this.sn &&
          other.model == this.model &&
          other.url == this.url &&
          other.status == this.status &&
          other.techSpecs == this.techSpecs &&
          other.history == this.history &&
          other.userEmail == this.userEmail &&
          other.companyCode == this.companyCode &&
          other.isUploaded == this.isUploaded &&
          other.lastModified == this.lastModified);
}

class AssetsCompanion extends UpdateCompanion<Asset> {
  final Value<int> id;
  final Value<String?> firebaseId;
  final Value<String> name;
  final Value<String> sn;
  final Value<String> model;
  final Value<String?> url;
  final Value<String> status;
  final Value<String> techSpecs;
  final Value<String> history;
  final Value<String> userEmail;
  final Value<String> companyCode;
  final Value<bool> isUploaded;
  final Value<DateTime> lastModified;
  const AssetsCompanion({
    this.id = const Value.absent(),
    this.firebaseId = const Value.absent(),
    this.name = const Value.absent(),
    this.sn = const Value.absent(),
    this.model = const Value.absent(),
    this.url = const Value.absent(),
    this.status = const Value.absent(),
    this.techSpecs = const Value.absent(),
    this.history = const Value.absent(),
    this.userEmail = const Value.absent(),
    this.companyCode = const Value.absent(),
    this.isUploaded = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  AssetsCompanion.insert({
    this.id = const Value.absent(),
    this.firebaseId = const Value.absent(),
    required String name,
    required String sn,
    required String model,
    this.url = const Value.absent(),
    required String status,
    required String techSpecs,
    required String history,
    required String userEmail,
    required String companyCode,
    this.isUploaded = const Value.absent(),
    this.lastModified = const Value.absent(),
  }) : name = Value(name),
       sn = Value(sn),
       model = Value(model),
       status = Value(status),
       techSpecs = Value(techSpecs),
       history = Value(history),
       userEmail = Value(userEmail),
       companyCode = Value(companyCode);
  static Insertable<Asset> custom({
    Expression<int>? id,
    Expression<String>? firebaseId,
    Expression<String>? name,
    Expression<String>? sn,
    Expression<String>? model,
    Expression<String>? url,
    Expression<String>? status,
    Expression<String>? techSpecs,
    Expression<String>? history,
    Expression<String>? userEmail,
    Expression<String>? companyCode,
    Expression<bool>? isUploaded,
    Expression<DateTime>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firebaseId != null) 'firebase_id': firebaseId,
      if (name != null) 'name': name,
      if (sn != null) 'sn': sn,
      if (model != null) 'model': model,
      if (url != null) 'url': url,
      if (status != null) 'status': status,
      if (techSpecs != null) 'tech_specs': techSpecs,
      if (history != null) 'history': history,
      if (userEmail != null) 'user_email': userEmail,
      if (companyCode != null) 'company_code': companyCode,
      if (isUploaded != null) 'is_uploaded': isUploaded,
      if (lastModified != null) 'last_modified': lastModified,
    });
  }

  AssetsCompanion copyWith({
    Value<int>? id,
    Value<String?>? firebaseId,
    Value<String>? name,
    Value<String>? sn,
    Value<String>? model,
    Value<String?>? url,
    Value<String>? status,
    Value<String>? techSpecs,
    Value<String>? history,
    Value<String>? userEmail,
    Value<String>? companyCode,
    Value<bool>? isUploaded,
    Value<DateTime>? lastModified,
  }) {
    return AssetsCompanion(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      name: name ?? this.name,
      sn: sn ?? this.sn,
      model: model ?? this.model,
      url: url ?? this.url,
      status: status ?? this.status,
      techSpecs: techSpecs ?? this.techSpecs,
      history: history ?? this.history,
      userEmail: userEmail ?? this.userEmail,
      companyCode: companyCode ?? this.companyCode,
      isUploaded: isUploaded ?? this.isUploaded,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (firebaseId.present) {
      map['firebase_id'] = Variable<String>(firebaseId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sn.present) {
      map['sn'] = Variable<String>(sn.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (techSpecs.present) {
      map['tech_specs'] = Variable<String>(techSpecs.value);
    }
    if (history.present) {
      map['history'] = Variable<String>(history.value);
    }
    if (userEmail.present) {
      map['user_email'] = Variable<String>(userEmail.value);
    }
    if (companyCode.present) {
      map['company_code'] = Variable<String>(companyCode.value);
    }
    if (isUploaded.present) {
      map['is_uploaded'] = Variable<bool>(isUploaded.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetsCompanion(')
          ..write('id: $id, ')
          ..write('firebaseId: $firebaseId, ')
          ..write('name: $name, ')
          ..write('sn: $sn, ')
          ..write('model: $model, ')
          ..write('url: $url, ')
          ..write('status: $status, ')
          ..write('techSpecs: $techSpecs, ')
          ..write('history: $history, ')
          ..write('userEmail: $userEmail, ')
          ..write('companyCode: $companyCode, ')
          ..write('isUploaded: $isUploaded, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerNameMeta = const VerificationMeta(
    'ownerName',
  );
  @override
  late final GeneratedColumn<String> ownerName = GeneratedColumn<String>(
    'owner_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userEmailMeta = const VerificationMeta(
    'userEmail',
  );
  @override
  late final GeneratedColumn<String> userEmail = GeneratedColumn<String>(
    'user_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyCodeMeta = const VerificationMeta(
    'companyCode',
  );
  @override
  late final GeneratedColumn<String> companyCode = GeneratedColumn<String>(
    'company_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadedMeta = const VerificationMeta(
    'uploaded',
  );
  @override
  late final GeneratedColumn<bool> uploaded = GeneratedColumn<bool>(
    'uploaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uploaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    filePath,
    createdAt,
    deviceId,
    ownerName,
    userEmail,
    companyCode,
    uploaded,
    favorite,
    latitude,
    longitude,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Photo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('owner_name')) {
      context.handle(
        _ownerNameMeta,
        ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta),
      );
    }
    if (data.containsKey('user_email')) {
      context.handle(
        _userEmailMeta,
        userEmail.isAcceptableOrUnknown(data['user_email']!, _userEmailMeta),
      );
    } else if (isInserting) {
      context.missing(_userEmailMeta);
    }
    if (data.containsKey('company_code')) {
      context.handle(
        _companyCodeMeta,
        companyCode.isAcceptableOrUnknown(
          data['company_code']!,
          _companyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companyCodeMeta);
    }
    if (data.containsKey('uploaded')) {
      context.handle(
        _uploadedMeta,
        uploaded.isAcceptableOrUnknown(data['uploaded']!, _uploadedMeta),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      ownerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_name'],
      ),
      userEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_email'],
      )!,
      companyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_code'],
      )!,
      uploaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uploaded'],
      )!,
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class Photo extends DataClass implements Insertable<Photo> {
  final int id;
  final String filePath;
  final DateTime createdAt;
  final String deviceId;
  final String? ownerName;
  final String userEmail;
  final String companyCode;
  final bool uploaded;
  final bool favorite;
  final double? latitude;
  final double? longitude;
  const Photo({
    required this.id,
    required this.filePath,
    required this.createdAt,
    required this.deviceId,
    this.ownerName,
    required this.userEmail,
    required this.companyCode,
    required this.uploaded,
    required this.favorite,
    this.latitude,
    this.longitude,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['file_path'] = Variable<String>(filePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || ownerName != null) {
      map['owner_name'] = Variable<String>(ownerName);
    }
    map['user_email'] = Variable<String>(userEmail);
    map['company_code'] = Variable<String>(companyCode);
    map['uploaded'] = Variable<bool>(uploaded);
    map['favorite'] = Variable<bool>(favorite);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      filePath: Value(filePath),
      createdAt: Value(createdAt),
      deviceId: Value(deviceId),
      ownerName: ownerName == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerName),
      userEmail: Value(userEmail),
      companyCode: Value(companyCode),
      uploaded: Value(uploaded),
      favorite: Value(favorite),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
    );
  }

  factory Photo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<int>(json['id']),
      filePath: serializer.fromJson<String>(json['filePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      ownerName: serializer.fromJson<String?>(json['ownerName']),
      userEmail: serializer.fromJson<String>(json['userEmail']),
      companyCode: serializer.fromJson<String>(json['companyCode']),
      uploaded: serializer.fromJson<bool>(json['uploaded']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'filePath': serializer.toJson<String>(filePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'ownerName': serializer.toJson<String?>(ownerName),
      'userEmail': serializer.toJson<String>(userEmail),
      'companyCode': serializer.toJson<String>(companyCode),
      'uploaded': serializer.toJson<bool>(uploaded),
      'favorite': serializer.toJson<bool>(favorite),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
    };
  }

  Photo copyWith({
    int? id,
    String? filePath,
    DateTime? createdAt,
    String? deviceId,
    Value<String?> ownerName = const Value.absent(),
    String? userEmail,
    String? companyCode,
    bool? uploaded,
    bool? favorite,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
  }) => Photo(
    id: id ?? this.id,
    filePath: filePath ?? this.filePath,
    createdAt: createdAt ?? this.createdAt,
    deviceId: deviceId ?? this.deviceId,
    ownerName: ownerName.present ? ownerName.value : this.ownerName,
    userEmail: userEmail ?? this.userEmail,
    companyCode: companyCode ?? this.companyCode,
    uploaded: uploaded ?? this.uploaded,
    favorite: favorite ?? this.favorite,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
  );
  Photo copyWithCompanion(PhotosCompanion data) {
    return Photo(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      userEmail: data.userEmail.present ? data.userEmail.value : this.userEmail,
      companyCode: data.companyCode.present
          ? data.companyCode.value
          : this.companyCode,
      uploaded: data.uploaded.present ? data.uploaded.value : this.uploaded,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('ownerName: $ownerName, ')
          ..write('userEmail: $userEmail, ')
          ..write('companyCode: $companyCode, ')
          ..write('uploaded: $uploaded, ')
          ..write('favorite: $favorite, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    filePath,
    createdAt,
    deviceId,
    ownerName,
    userEmail,
    companyCode,
    uploaded,
    favorite,
    latitude,
    longitude,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          other.createdAt == this.createdAt &&
          other.deviceId == this.deviceId &&
          other.ownerName == this.ownerName &&
          other.userEmail == this.userEmail &&
          other.companyCode == this.companyCode &&
          other.uploaded == this.uploaded &&
          other.favorite == this.favorite &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<int> id;
  final Value<String> filePath;
  final Value<DateTime> createdAt;
  final Value<String> deviceId;
  final Value<String?> ownerName;
  final Value<String> userEmail;
  final Value<String> companyCode;
  final Value<bool> uploaded;
  final Value<bool> favorite;
  final Value<double?> latitude;
  final Value<double?> longitude;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.userEmail = const Value.absent(),
    this.companyCode = const Value.absent(),
    this.uploaded = const Value.absent(),
    this.favorite = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
  });
  PhotosCompanion.insert({
    this.id = const Value.absent(),
    required String filePath,
    this.createdAt = const Value.absent(),
    required String deviceId,
    this.ownerName = const Value.absent(),
    required String userEmail,
    required String companyCode,
    this.uploaded = const Value.absent(),
    this.favorite = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
  }) : filePath = Value(filePath),
       deviceId = Value(deviceId),
       userEmail = Value(userEmail),
       companyCode = Value(companyCode);
  static Insertable<Photo> custom({
    Expression<int>? id,
    Expression<String>? filePath,
    Expression<DateTime>? createdAt,
    Expression<String>? deviceId,
    Expression<String>? ownerName,
    Expression<String>? userEmail,
    Expression<String>? companyCode,
    Expression<bool>? uploaded,
    Expression<bool>? favorite,
    Expression<double>? latitude,
    Expression<double>? longitude,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt,
      if (deviceId != null) 'device_id': deviceId,
      if (ownerName != null) 'owner_name': ownerName,
      if (userEmail != null) 'user_email': userEmail,
      if (companyCode != null) 'company_code': companyCode,
      if (uploaded != null) 'uploaded': uploaded,
      if (favorite != null) 'favorite': favorite,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
  }

  PhotosCompanion copyWith({
    Value<int>? id,
    Value<String>? filePath,
    Value<DateTime>? createdAt,
    Value<String>? deviceId,
    Value<String?>? ownerName,
    Value<String>? userEmail,
    Value<String>? companyCode,
    Value<bool>? uploaded,
    Value<bool>? favorite,
    Value<double?>? latitude,
    Value<double?>? longitude,
  }) {
    return PhotosCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      deviceId: deviceId ?? this.deviceId,
      ownerName: ownerName ?? this.ownerName,
      userEmail: userEmail ?? this.userEmail,
      companyCode: companyCode ?? this.companyCode,
      uploaded: uploaded ?? this.uploaded,
      favorite: favorite ?? this.favorite,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (ownerName.present) {
      map['owner_name'] = Variable<String>(ownerName.value);
    }
    if (userEmail.present) {
      map['user_email'] = Variable<String>(userEmail.value);
    }
    if (companyCode.present) {
      map['company_code'] = Variable<String>(companyCode.value);
    }
    if (uploaded.present) {
      map['uploaded'] = Variable<bool>(uploaded.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('ownerName: $ownerName, ')
          ..write('userEmail: $userEmail, ')
          ..write('companyCode: $companyCode, ')
          ..write('uploaded: $uploaded, ')
          ..write('favorite: $favorite, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }
}

class $AudiosTable extends Audios with TableInfo<$AudiosTable, Audio> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudiosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerNameMeta = const VerificationMeta(
    'ownerName',
  );
  @override
  late final GeneratedColumn<String> ownerName = GeneratedColumn<String>(
    'owner_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userEmailMeta = const VerificationMeta(
    'userEmail',
  );
  @override
  late final GeneratedColumn<String> userEmail = GeneratedColumn<String>(
    'user_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyCodeMeta = const VerificationMeta(
    'companyCode',
  );
  @override
  late final GeneratedColumn<String> companyCode = GeneratedColumn<String>(
    'company_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _uploadedMeta = const VerificationMeta(
    'uploaded',
  );
  @override
  late final GeneratedColumn<bool> uploaded = GeneratedColumn<bool>(
    'uploaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uploaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    filePath,
    createdAt,
    deviceId,
    ownerName,
    userEmail,
    companyCode,
    durationSeconds,
    favorite,
    uploaded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audios';
  @override
  VerificationContext validateIntegrity(
    Insertable<Audio> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('owner_name')) {
      context.handle(
        _ownerNameMeta,
        ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta),
      );
    }
    if (data.containsKey('user_email')) {
      context.handle(
        _userEmailMeta,
        userEmail.isAcceptableOrUnknown(data['user_email']!, _userEmailMeta),
      );
    } else if (isInserting) {
      context.missing(_userEmailMeta);
    }
    if (data.containsKey('company_code')) {
      context.handle(
        _companyCodeMeta,
        companyCode.isAcceptableOrUnknown(
          data['company_code']!,
          _companyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companyCodeMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('uploaded')) {
      context.handle(
        _uploadedMeta,
        uploaded.isAcceptableOrUnknown(data['uploaded']!, _uploadedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Audio map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Audio(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      ownerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_name'],
      ),
      userEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_email'],
      )!,
      companyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_code'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      uploaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uploaded'],
      )!,
    );
  }

  @override
  $AudiosTable createAlias(String alias) {
    return $AudiosTable(attachedDatabase, alias);
  }
}

class Audio extends DataClass implements Insertable<Audio> {
  final int id;
  final String filePath;
  final DateTime createdAt;
  final String deviceId;
  final String? ownerName;
  final String userEmail;
  final String companyCode;
  final int? durationSeconds;
  final bool favorite;
  final bool uploaded;
  const Audio({
    required this.id,
    required this.filePath,
    required this.createdAt,
    required this.deviceId,
    this.ownerName,
    required this.userEmail,
    required this.companyCode,
    this.durationSeconds,
    required this.favorite,
    required this.uploaded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['file_path'] = Variable<String>(filePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || ownerName != null) {
      map['owner_name'] = Variable<String>(ownerName);
    }
    map['user_email'] = Variable<String>(userEmail);
    map['company_code'] = Variable<String>(companyCode);
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['favorite'] = Variable<bool>(favorite);
    map['uploaded'] = Variable<bool>(uploaded);
    return map;
  }

  AudiosCompanion toCompanion(bool nullToAbsent) {
    return AudiosCompanion(
      id: Value(id),
      filePath: Value(filePath),
      createdAt: Value(createdAt),
      deviceId: Value(deviceId),
      ownerName: ownerName == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerName),
      userEmail: Value(userEmail),
      companyCode: Value(companyCode),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      favorite: Value(favorite),
      uploaded: Value(uploaded),
    );
  }

  factory Audio.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Audio(
      id: serializer.fromJson<int>(json['id']),
      filePath: serializer.fromJson<String>(json['filePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      ownerName: serializer.fromJson<String?>(json['ownerName']),
      userEmail: serializer.fromJson<String>(json['userEmail']),
      companyCode: serializer.fromJson<String>(json['companyCode']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      uploaded: serializer.fromJson<bool>(json['uploaded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'filePath': serializer.toJson<String>(filePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'ownerName': serializer.toJson<String?>(ownerName),
      'userEmail': serializer.toJson<String>(userEmail),
      'companyCode': serializer.toJson<String>(companyCode),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'favorite': serializer.toJson<bool>(favorite),
      'uploaded': serializer.toJson<bool>(uploaded),
    };
  }

  Audio copyWith({
    int? id,
    String? filePath,
    DateTime? createdAt,
    String? deviceId,
    Value<String?> ownerName = const Value.absent(),
    String? userEmail,
    String? companyCode,
    Value<int?> durationSeconds = const Value.absent(),
    bool? favorite,
    bool? uploaded,
  }) => Audio(
    id: id ?? this.id,
    filePath: filePath ?? this.filePath,
    createdAt: createdAt ?? this.createdAt,
    deviceId: deviceId ?? this.deviceId,
    ownerName: ownerName.present ? ownerName.value : this.ownerName,
    userEmail: userEmail ?? this.userEmail,
    companyCode: companyCode ?? this.companyCode,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    favorite: favorite ?? this.favorite,
    uploaded: uploaded ?? this.uploaded,
  );
  Audio copyWithCompanion(AudiosCompanion data) {
    return Audio(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      userEmail: data.userEmail.present ? data.userEmail.value : this.userEmail,
      companyCode: data.companyCode.present
          ? data.companyCode.value
          : this.companyCode,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      uploaded: data.uploaded.present ? data.uploaded.value : this.uploaded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Audio(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('ownerName: $ownerName, ')
          ..write('userEmail: $userEmail, ')
          ..write('companyCode: $companyCode, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('favorite: $favorite, ')
          ..write('uploaded: $uploaded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    filePath,
    createdAt,
    deviceId,
    ownerName,
    userEmail,
    companyCode,
    durationSeconds,
    favorite,
    uploaded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Audio &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          other.createdAt == this.createdAt &&
          other.deviceId == this.deviceId &&
          other.ownerName == this.ownerName &&
          other.userEmail == this.userEmail &&
          other.companyCode == this.companyCode &&
          other.durationSeconds == this.durationSeconds &&
          other.favorite == this.favorite &&
          other.uploaded == this.uploaded);
}

class AudiosCompanion extends UpdateCompanion<Audio> {
  final Value<int> id;
  final Value<String> filePath;
  final Value<DateTime> createdAt;
  final Value<String> deviceId;
  final Value<String?> ownerName;
  final Value<String> userEmail;
  final Value<String> companyCode;
  final Value<int?> durationSeconds;
  final Value<bool> favorite;
  final Value<bool> uploaded;
  const AudiosCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.userEmail = const Value.absent(),
    this.companyCode = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.favorite = const Value.absent(),
    this.uploaded = const Value.absent(),
  });
  AudiosCompanion.insert({
    this.id = const Value.absent(),
    required String filePath,
    this.createdAt = const Value.absent(),
    required String deviceId,
    this.ownerName = const Value.absent(),
    required String userEmail,
    required String companyCode,
    this.durationSeconds = const Value.absent(),
    this.favorite = const Value.absent(),
    this.uploaded = const Value.absent(),
  }) : filePath = Value(filePath),
       deviceId = Value(deviceId),
       userEmail = Value(userEmail),
       companyCode = Value(companyCode);
  static Insertable<Audio> custom({
    Expression<int>? id,
    Expression<String>? filePath,
    Expression<DateTime>? createdAt,
    Expression<String>? deviceId,
    Expression<String>? ownerName,
    Expression<String>? userEmail,
    Expression<String>? companyCode,
    Expression<int>? durationSeconds,
    Expression<bool>? favorite,
    Expression<bool>? uploaded,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt,
      if (deviceId != null) 'device_id': deviceId,
      if (ownerName != null) 'owner_name': ownerName,
      if (userEmail != null) 'user_email': userEmail,
      if (companyCode != null) 'company_code': companyCode,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (favorite != null) 'favorite': favorite,
      if (uploaded != null) 'uploaded': uploaded,
    });
  }

  AudiosCompanion copyWith({
    Value<int>? id,
    Value<String>? filePath,
    Value<DateTime>? createdAt,
    Value<String>? deviceId,
    Value<String?>? ownerName,
    Value<String>? userEmail,
    Value<String>? companyCode,
    Value<int?>? durationSeconds,
    Value<bool>? favorite,
    Value<bool>? uploaded,
  }) {
    return AudiosCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      deviceId: deviceId ?? this.deviceId,
      ownerName: ownerName ?? this.ownerName,
      userEmail: userEmail ?? this.userEmail,
      companyCode: companyCode ?? this.companyCode,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      favorite: favorite ?? this.favorite,
      uploaded: uploaded ?? this.uploaded,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (ownerName.present) {
      map['owner_name'] = Variable<String>(ownerName.value);
    }
    if (userEmail.present) {
      map['user_email'] = Variable<String>(userEmail.value);
    }
    if (companyCode.present) {
      map['company_code'] = Variable<String>(companyCode.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (uploaded.present) {
      map['uploaded'] = Variable<bool>(uploaded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudiosCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('ownerName: $ownerName, ')
          ..write('userEmail: $userEmail, ')
          ..write('companyCode: $companyCode, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('favorite: $favorite, ')
          ..write('uploaded: $uploaded')
          ..write(')'))
        .toString();
  }
}

class $VideosTable extends Videos with TableInfo<$VideosTable, Video> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerNameMeta = const VerificationMeta(
    'ownerName',
  );
  @override
  late final GeneratedColumn<String> ownerName = GeneratedColumn<String>(
    'owner_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userEmailMeta = const VerificationMeta(
    'userEmail',
  );
  @override
  late final GeneratedColumn<String> userEmail = GeneratedColumn<String>(
    'user_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyCodeMeta = const VerificationMeta(
    'companyCode',
  );
  @override
  late final GeneratedColumn<String> companyCode = GeneratedColumn<String>(
    'company_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadedMeta = const VerificationMeta(
    'uploaded',
  );
  @override
  late final GeneratedColumn<bool> uploaded = GeneratedColumn<bool>(
    'uploaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uploaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    filePath,
    createdAt,
    deviceId,
    ownerName,
    userEmail,
    companyCode,
    uploaded,
    durationSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'videos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Video> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('owner_name')) {
      context.handle(
        _ownerNameMeta,
        ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta),
      );
    }
    if (data.containsKey('user_email')) {
      context.handle(
        _userEmailMeta,
        userEmail.isAcceptableOrUnknown(data['user_email']!, _userEmailMeta),
      );
    } else if (isInserting) {
      context.missing(_userEmailMeta);
    }
    if (data.containsKey('company_code')) {
      context.handle(
        _companyCodeMeta,
        companyCode.isAcceptableOrUnknown(
          data['company_code']!,
          _companyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companyCodeMeta);
    }
    if (data.containsKey('uploaded')) {
      context.handle(
        _uploadedMeta,
        uploaded.isAcceptableOrUnknown(data['uploaded']!, _uploadedMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Video map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Video(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      ownerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_name'],
      ),
      userEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_email'],
      )!,
      companyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_code'],
      )!,
      uploaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uploaded'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
    );
  }

  @override
  $VideosTable createAlias(String alias) {
    return $VideosTable(attachedDatabase, alias);
  }
}

class Video extends DataClass implements Insertable<Video> {
  final int id;
  final String filePath;
  final DateTime createdAt;
  final String deviceId;
  final String? ownerName;
  final String userEmail;
  final String companyCode;
  final bool uploaded;
  final int? durationSeconds;
  const Video({
    required this.id,
    required this.filePath,
    required this.createdAt,
    required this.deviceId,
    this.ownerName,
    required this.userEmail,
    required this.companyCode,
    required this.uploaded,
    this.durationSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['file_path'] = Variable<String>(filePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || ownerName != null) {
      map['owner_name'] = Variable<String>(ownerName);
    }
    map['user_email'] = Variable<String>(userEmail);
    map['company_code'] = Variable<String>(companyCode);
    map['uploaded'] = Variable<bool>(uploaded);
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    return map;
  }

  VideosCompanion toCompanion(bool nullToAbsent) {
    return VideosCompanion(
      id: Value(id),
      filePath: Value(filePath),
      createdAt: Value(createdAt),
      deviceId: Value(deviceId),
      ownerName: ownerName == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerName),
      userEmail: Value(userEmail),
      companyCode: Value(companyCode),
      uploaded: Value(uploaded),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
    );
  }

  factory Video.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Video(
      id: serializer.fromJson<int>(json['id']),
      filePath: serializer.fromJson<String>(json['filePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      ownerName: serializer.fromJson<String?>(json['ownerName']),
      userEmail: serializer.fromJson<String>(json['userEmail']),
      companyCode: serializer.fromJson<String>(json['companyCode']),
      uploaded: serializer.fromJson<bool>(json['uploaded']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'filePath': serializer.toJson<String>(filePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'ownerName': serializer.toJson<String?>(ownerName),
      'userEmail': serializer.toJson<String>(userEmail),
      'companyCode': serializer.toJson<String>(companyCode),
      'uploaded': serializer.toJson<bool>(uploaded),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
    };
  }

  Video copyWith({
    int? id,
    String? filePath,
    DateTime? createdAt,
    String? deviceId,
    Value<String?> ownerName = const Value.absent(),
    String? userEmail,
    String? companyCode,
    bool? uploaded,
    Value<int?> durationSeconds = const Value.absent(),
  }) => Video(
    id: id ?? this.id,
    filePath: filePath ?? this.filePath,
    createdAt: createdAt ?? this.createdAt,
    deviceId: deviceId ?? this.deviceId,
    ownerName: ownerName.present ? ownerName.value : this.ownerName,
    userEmail: userEmail ?? this.userEmail,
    companyCode: companyCode ?? this.companyCode,
    uploaded: uploaded ?? this.uploaded,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
  );
  Video copyWithCompanion(VideosCompanion data) {
    return Video(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      userEmail: data.userEmail.present ? data.userEmail.value : this.userEmail,
      companyCode: data.companyCode.present
          ? data.companyCode.value
          : this.companyCode,
      uploaded: data.uploaded.present ? data.uploaded.value : this.uploaded,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Video(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('ownerName: $ownerName, ')
          ..write('userEmail: $userEmail, ')
          ..write('companyCode: $companyCode, ')
          ..write('uploaded: $uploaded, ')
          ..write('durationSeconds: $durationSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    filePath,
    createdAt,
    deviceId,
    ownerName,
    userEmail,
    companyCode,
    uploaded,
    durationSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Video &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          other.createdAt == this.createdAt &&
          other.deviceId == this.deviceId &&
          other.ownerName == this.ownerName &&
          other.userEmail == this.userEmail &&
          other.companyCode == this.companyCode &&
          other.uploaded == this.uploaded &&
          other.durationSeconds == this.durationSeconds);
}

class VideosCompanion extends UpdateCompanion<Video> {
  final Value<int> id;
  final Value<String> filePath;
  final Value<DateTime> createdAt;
  final Value<String> deviceId;
  final Value<String?> ownerName;
  final Value<String> userEmail;
  final Value<String> companyCode;
  final Value<bool> uploaded;
  final Value<int?> durationSeconds;
  const VideosCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.userEmail = const Value.absent(),
    this.companyCode = const Value.absent(),
    this.uploaded = const Value.absent(),
    this.durationSeconds = const Value.absent(),
  });
  VideosCompanion.insert({
    this.id = const Value.absent(),
    required String filePath,
    this.createdAt = const Value.absent(),
    required String deviceId,
    this.ownerName = const Value.absent(),
    required String userEmail,
    required String companyCode,
    this.uploaded = const Value.absent(),
    this.durationSeconds = const Value.absent(),
  }) : filePath = Value(filePath),
       deviceId = Value(deviceId),
       userEmail = Value(userEmail),
       companyCode = Value(companyCode);
  static Insertable<Video> custom({
    Expression<int>? id,
    Expression<String>? filePath,
    Expression<DateTime>? createdAt,
    Expression<String>? deviceId,
    Expression<String>? ownerName,
    Expression<String>? userEmail,
    Expression<String>? companyCode,
    Expression<bool>? uploaded,
    Expression<int>? durationSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt,
      if (deviceId != null) 'device_id': deviceId,
      if (ownerName != null) 'owner_name': ownerName,
      if (userEmail != null) 'user_email': userEmail,
      if (companyCode != null) 'company_code': companyCode,
      if (uploaded != null) 'uploaded': uploaded,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
    });
  }

  VideosCompanion copyWith({
    Value<int>? id,
    Value<String>? filePath,
    Value<DateTime>? createdAt,
    Value<String>? deviceId,
    Value<String?>? ownerName,
    Value<String>? userEmail,
    Value<String>? companyCode,
    Value<bool>? uploaded,
    Value<int?>? durationSeconds,
  }) {
    return VideosCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      deviceId: deviceId ?? this.deviceId,
      ownerName: ownerName ?? this.ownerName,
      userEmail: userEmail ?? this.userEmail,
      companyCode: companyCode ?? this.companyCode,
      uploaded: uploaded ?? this.uploaded,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (ownerName.present) {
      map['owner_name'] = Variable<String>(ownerName.value);
    }
    if (userEmail.present) {
      map['user_email'] = Variable<String>(userEmail.value);
    }
    if (companyCode.present) {
      map['company_code'] = Variable<String>(companyCode.value);
    }
    if (uploaded.present) {
      map['uploaded'] = Variable<bool>(uploaded.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideosCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('ownerName: $ownerName, ')
          ..write('userEmail: $userEmail, ')
          ..write('companyCode: $companyCode, ')
          ..write('uploaded: $uploaded, ')
          ..write('durationSeconds: $durationSeconds')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $AssetsTable assets = $AssetsTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $AudiosTable audios = $AudiosTable(this);
  late final $VideosTable videos = $VideosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    assets,
    photos,
    audios,
    videos,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String uid,
      required String email,
      required String role,
      required String companyCode,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> uid,
      Value<String> email,
      Value<String> role,
      Value<String> companyCode,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyCode => $composableBuilder(
    column: $table.companyCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyCode => $composableBuilder(
    column: $table.companyCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get companyCode => $composableBuilder(
    column: $table.companyCode,
    builder: (column) => column,
  );
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> companyCode = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                uid: uid,
                email: email,
                role: role,
                companyCode: companyCode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uid,
                required String email,
                required String role,
                required String companyCode,
              }) => UsersCompanion.insert(
                id: id,
                uid: uid,
                email: email,
                role: role,
                companyCode: companyCode,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$AssetsTableCreateCompanionBuilder =
    AssetsCompanion Function({
      Value<int> id,
      Value<String?> firebaseId,
      required String name,
      required String sn,
      required String model,
      Value<String?> url,
      required String status,
      required String techSpecs,
      required String history,
      required String userEmail,
      required String companyCode,
      Value<bool> isUploaded,
      Value<DateTime> lastModified,
    });
typedef $$AssetsTableUpdateCompanionBuilder =
    AssetsCompanion Function({
      Value<int> id,
      Value<String?> firebaseId,
      Value<String> name,
      Value<String> sn,
      Value<String> model,
      Value<String?> url,
      Value<String> status,
      Value<String> techSpecs,
      Value<String> history,
      Value<String> userEmail,
      Value<String> companyCode,
      Value<bool> isUploaded,
      Value<DateTime> lastModified,
    });

class $$AssetsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firebaseId => $composableBuilder(
    column: $table.firebaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sn => $composableBuilder(
    column: $table.sn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get techSpecs => $composableBuilder(
    column: $table.techSpecs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get history => $composableBuilder(
    column: $table.history,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyCode => $composableBuilder(
    column: $table.companyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUploaded => $composableBuilder(
    column: $table.isUploaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firebaseId => $composableBuilder(
    column: $table.firebaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sn => $composableBuilder(
    column: $table.sn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get techSpecs => $composableBuilder(
    column: $table.techSpecs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get history => $composableBuilder(
    column: $table.history,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyCode => $composableBuilder(
    column: $table.companyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUploaded => $composableBuilder(
    column: $table.isUploaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firebaseId => $composableBuilder(
    column: $table.firebaseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sn =>
      $composableBuilder(column: $table.sn, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get techSpecs =>
      $composableBuilder(column: $table.techSpecs, builder: (column) => column);

  GeneratedColumn<String> get history =>
      $composableBuilder(column: $table.history, builder: (column) => column);

  GeneratedColumn<String> get userEmail =>
      $composableBuilder(column: $table.userEmail, builder: (column) => column);

  GeneratedColumn<String> get companyCode => $composableBuilder(
    column: $table.companyCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isUploaded => $composableBuilder(
    column: $table.isUploaded,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );
}

class $$AssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetsTable,
          Asset,
          $$AssetsTableFilterComposer,
          $$AssetsTableOrderingComposer,
          $$AssetsTableAnnotationComposer,
          $$AssetsTableCreateCompanionBuilder,
          $$AssetsTableUpdateCompanionBuilder,
          (Asset, BaseReferences<_$AppDatabase, $AssetsTable, Asset>),
          Asset,
          PrefetchHooks Function()
        > {
  $$AssetsTableTableManager(_$AppDatabase db, $AssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> firebaseId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sn = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> techSpecs = const Value.absent(),
                Value<String> history = const Value.absent(),
                Value<String> userEmail = const Value.absent(),
                Value<String> companyCode = const Value.absent(),
                Value<bool> isUploaded = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
              }) => AssetsCompanion(
                id: id,
                firebaseId: firebaseId,
                name: name,
                sn: sn,
                model: model,
                url: url,
                status: status,
                techSpecs: techSpecs,
                history: history,
                userEmail: userEmail,
                companyCode: companyCode,
                isUploaded: isUploaded,
                lastModified: lastModified,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> firebaseId = const Value.absent(),
                required String name,
                required String sn,
                required String model,
                Value<String?> url = const Value.absent(),
                required String status,
                required String techSpecs,
                required String history,
                required String userEmail,
                required String companyCode,
                Value<bool> isUploaded = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
              }) => AssetsCompanion.insert(
                id: id,
                firebaseId: firebaseId,
                name: name,
                sn: sn,
                model: model,
                url: url,
                status: status,
                techSpecs: techSpecs,
                history: history,
                userEmail: userEmail,
                companyCode: companyCode,
                isUploaded: isUploaded,
                lastModified: lastModified,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetsTable,
      Asset,
      $$AssetsTableFilterComposer,
      $$AssetsTableOrderingComposer,
      $$AssetsTableAnnotationComposer,
      $$AssetsTableCreateCompanionBuilder,
      $$AssetsTableUpdateCompanionBuilder,
      (Asset, BaseReferences<_$AppDatabase, $AssetsTable, Asset>),
      Asset,
      PrefetchHooks Function()
    >;
typedef $$PhotosTableCreateCompanionBuilder =
    PhotosCompanion Function({
      Value<int> id,
      required String filePath,
      Value<DateTime> createdAt,
      required String deviceId,
      Value<String?> ownerName,
      required String userEmail,
      required String companyCode,
      Value<bool> uploaded,
      Value<bool> favorite,
      Value<double?> latitude,
      Value<double?> longitude,
    });
typedef $$PhotosTableUpdateCompanionBuilder =
    PhotosCompanion Function({
      Value<int> id,
      Value<String> filePath,
      Value<DateTime> createdAt,
      Value<String> deviceId,
      Value<String?> ownerName,
      Value<String> userEmail,
      Value<String> companyCode,
      Value<bool> uploaded,
      Value<bool> favorite,
      Value<double?> latitude,
      Value<double?> longitude,
    });

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyCode => $composableBuilder(
    column: $table.companyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyCode => $composableBuilder(
    column: $table.companyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => column);

  GeneratedColumn<String> get userEmail =>
      $composableBuilder(column: $table.userEmail, builder: (column) => column);

  GeneratedColumn<String> get companyCode => $composableBuilder(
    column: $table.companyCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get uploaded =>
      $composableBuilder(column: $table.uploaded, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          Photo,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (Photo, BaseReferences<_$AppDatabase, $PhotosTable, Photo>),
          Photo,
          PrefetchHooks Function()
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> ownerName = const Value.absent(),
                Value<String> userEmail = const Value.absent(),
                Value<String> companyCode = const Value.absent(),
                Value<bool> uploaded = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
              }) => PhotosCompanion(
                id: id,
                filePath: filePath,
                createdAt: createdAt,
                deviceId: deviceId,
                ownerName: ownerName,
                userEmail: userEmail,
                companyCode: companyCode,
                uploaded: uploaded,
                favorite: favorite,
                latitude: latitude,
                longitude: longitude,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String filePath,
                Value<DateTime> createdAt = const Value.absent(),
                required String deviceId,
                Value<String?> ownerName = const Value.absent(),
                required String userEmail,
                required String companyCode,
                Value<bool> uploaded = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
              }) => PhotosCompanion.insert(
                id: id,
                filePath: filePath,
                createdAt: createdAt,
                deviceId: deviceId,
                ownerName: ownerName,
                userEmail: userEmail,
                companyCode: companyCode,
                uploaded: uploaded,
                favorite: favorite,
                latitude: latitude,
                longitude: longitude,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      Photo,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (Photo, BaseReferences<_$AppDatabase, $PhotosTable, Photo>),
      Photo,
      PrefetchHooks Function()
    >;
typedef $$AudiosTableCreateCompanionBuilder =
    AudiosCompanion Function({
      Value<int> id,
      required String filePath,
      Value<DateTime> createdAt,
      required String deviceId,
      Value<String?> ownerName,
      required String userEmail,
      required String companyCode,
      Value<int?> durationSeconds,
      Value<bool> favorite,
      Value<bool> uploaded,
    });
typedef $$AudiosTableUpdateCompanionBuilder =
    AudiosCompanion Function({
      Value<int> id,
      Value<String> filePath,
      Value<DateTime> createdAt,
      Value<String> deviceId,
      Value<String?> ownerName,
      Value<String> userEmail,
      Value<String> companyCode,
      Value<int?> durationSeconds,
      Value<bool> favorite,
      Value<bool> uploaded,
    });

class $$AudiosTableFilterComposer
    extends Composer<_$AppDatabase, $AudiosTable> {
  $$AudiosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyCode => $composableBuilder(
    column: $table.companyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudiosTableOrderingComposer
    extends Composer<_$AppDatabase, $AudiosTable> {
  $$AudiosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyCode => $composableBuilder(
    column: $table.companyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudiosTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudiosTable> {
  $$AudiosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => column);

  GeneratedColumn<String> get userEmail =>
      $composableBuilder(column: $table.userEmail, builder: (column) => column);

  GeneratedColumn<String> get companyCode => $composableBuilder(
    column: $table.companyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<bool> get uploaded =>
      $composableBuilder(column: $table.uploaded, builder: (column) => column);
}

class $$AudiosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudiosTable,
          Audio,
          $$AudiosTableFilterComposer,
          $$AudiosTableOrderingComposer,
          $$AudiosTableAnnotationComposer,
          $$AudiosTableCreateCompanionBuilder,
          $$AudiosTableUpdateCompanionBuilder,
          (Audio, BaseReferences<_$AppDatabase, $AudiosTable, Audio>),
          Audio,
          PrefetchHooks Function()
        > {
  $$AudiosTableTableManager(_$AppDatabase db, $AudiosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudiosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudiosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudiosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> ownerName = const Value.absent(),
                Value<String> userEmail = const Value.absent(),
                Value<String> companyCode = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<bool> uploaded = const Value.absent(),
              }) => AudiosCompanion(
                id: id,
                filePath: filePath,
                createdAt: createdAt,
                deviceId: deviceId,
                ownerName: ownerName,
                userEmail: userEmail,
                companyCode: companyCode,
                durationSeconds: durationSeconds,
                favorite: favorite,
                uploaded: uploaded,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String filePath,
                Value<DateTime> createdAt = const Value.absent(),
                required String deviceId,
                Value<String?> ownerName = const Value.absent(),
                required String userEmail,
                required String companyCode,
                Value<int?> durationSeconds = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<bool> uploaded = const Value.absent(),
              }) => AudiosCompanion.insert(
                id: id,
                filePath: filePath,
                createdAt: createdAt,
                deviceId: deviceId,
                ownerName: ownerName,
                userEmail: userEmail,
                companyCode: companyCode,
                durationSeconds: durationSeconds,
                favorite: favorite,
                uploaded: uploaded,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudiosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudiosTable,
      Audio,
      $$AudiosTableFilterComposer,
      $$AudiosTableOrderingComposer,
      $$AudiosTableAnnotationComposer,
      $$AudiosTableCreateCompanionBuilder,
      $$AudiosTableUpdateCompanionBuilder,
      (Audio, BaseReferences<_$AppDatabase, $AudiosTable, Audio>),
      Audio,
      PrefetchHooks Function()
    >;
typedef $$VideosTableCreateCompanionBuilder =
    VideosCompanion Function({
      Value<int> id,
      required String filePath,
      Value<DateTime> createdAt,
      required String deviceId,
      Value<String?> ownerName,
      required String userEmail,
      required String companyCode,
      Value<bool> uploaded,
      Value<int?> durationSeconds,
    });
typedef $$VideosTableUpdateCompanionBuilder =
    VideosCompanion Function({
      Value<int> id,
      Value<String> filePath,
      Value<DateTime> createdAt,
      Value<String> deviceId,
      Value<String?> ownerName,
      Value<String> userEmail,
      Value<String> companyCode,
      Value<bool> uploaded,
      Value<int?> durationSeconds,
    });

class $$VideosTableFilterComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyCode => $composableBuilder(
    column: $table.companyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VideosTableOrderingComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyCode => $composableBuilder(
    column: $table.companyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VideosTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => column);

  GeneratedColumn<String> get userEmail =>
      $composableBuilder(column: $table.userEmail, builder: (column) => column);

  GeneratedColumn<String> get companyCode => $composableBuilder(
    column: $table.companyCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get uploaded =>
      $composableBuilder(column: $table.uploaded, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );
}

class $$VideosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VideosTable,
          Video,
          $$VideosTableFilterComposer,
          $$VideosTableOrderingComposer,
          $$VideosTableAnnotationComposer,
          $$VideosTableCreateCompanionBuilder,
          $$VideosTableUpdateCompanionBuilder,
          (Video, BaseReferences<_$AppDatabase, $VideosTable, Video>),
          Video,
          PrefetchHooks Function()
        > {
  $$VideosTableTableManager(_$AppDatabase db, $VideosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> ownerName = const Value.absent(),
                Value<String> userEmail = const Value.absent(),
                Value<String> companyCode = const Value.absent(),
                Value<bool> uploaded = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
              }) => VideosCompanion(
                id: id,
                filePath: filePath,
                createdAt: createdAt,
                deviceId: deviceId,
                ownerName: ownerName,
                userEmail: userEmail,
                companyCode: companyCode,
                uploaded: uploaded,
                durationSeconds: durationSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String filePath,
                Value<DateTime> createdAt = const Value.absent(),
                required String deviceId,
                Value<String?> ownerName = const Value.absent(),
                required String userEmail,
                required String companyCode,
                Value<bool> uploaded = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
              }) => VideosCompanion.insert(
                id: id,
                filePath: filePath,
                createdAt: createdAt,
                deviceId: deviceId,
                ownerName: ownerName,
                userEmail: userEmail,
                companyCode: companyCode,
                uploaded: uploaded,
                durationSeconds: durationSeconds,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VideosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VideosTable,
      Video,
      $$VideosTableFilterComposer,
      $$VideosTableOrderingComposer,
      $$VideosTableAnnotationComposer,
      $$VideosTableCreateCompanionBuilder,
      $$VideosTableUpdateCompanionBuilder,
      (Video, BaseReferences<_$AppDatabase, $VideosTable, Video>),
      Video,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db, _db.assets);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
  $$AudiosTableTableManager get audios =>
      $$AudiosTableTableManager(_db, _db.audios);
  $$VideosTableTableManager get videos =>
      $$VideosTableTableManager(_db, _db.videos);
}
