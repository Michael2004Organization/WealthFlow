// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordSaltMeta = const VerificationMeta(
    'passwordSalt',
  );
  @override
  late final GeneratedColumn<String> passwordSalt = GeneratedColumn<String>(
    'password_salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileImagePathMeta = const VerificationMeta(
    'profileImagePath',
  );
  @override
  late final GeneratedColumn<String> profileImagePath = GeneratedColumn<String>(
    'profile_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('member'),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    displayName,
    passwordHash,
    passwordSalt,
    profileImagePath,
    role,
    createdAt,
    updatedAt,
  ];
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
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('password_salt')) {
      context.handle(
        _passwordSaltMeta,
        passwordSalt.isAcceptableOrUnknown(
          data['password_salt']!,
          _passwordSaltMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordSaltMeta);
    }
    if (data.containsKey('profile_image_path')) {
      context.handle(
        _profileImagePathMeta,
        profileImagePath.isAcceptableOrUnknown(
          data['profile_image_path']!,
          _profileImagePathMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
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
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      passwordSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_salt'],
      )!,
      profileImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_image_path'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String email;
  final String displayName;
  final String passwordHash;
  final String passwordSalt;
  final String? profileImagePath;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.passwordHash,
    required this.passwordSalt,
    this.profileImagePath,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['display_name'] = Variable<String>(displayName);
    map['password_hash'] = Variable<String>(passwordHash);
    map['password_salt'] = Variable<String>(passwordSalt);
    if (!nullToAbsent || profileImagePath != null) {
      map['profile_image_path'] = Variable<String>(profileImagePath);
    }
    map['role'] = Variable<String>(role);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      displayName: Value(displayName),
      passwordHash: Value(passwordHash),
      passwordSalt: Value(passwordSalt),
      profileImagePath: profileImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(profileImagePath),
      role: Value(role),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      displayName: serializer.fromJson<String>(json['displayName']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      passwordSalt: serializer.fromJson<String>(json['passwordSalt']),
      profileImagePath: serializer.fromJson<String?>(json['profileImagePath']),
      role: serializer.fromJson<String>(json['role']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'displayName': serializer.toJson<String>(displayName),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'passwordSalt': serializer.toJson<String>(passwordSalt),
      'profileImagePath': serializer.toJson<String?>(profileImagePath),
      'role': serializer.toJson<String>(role),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? passwordHash,
    String? passwordSalt,
    Value<String?> profileImagePath = const Value.absent(),
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    passwordHash: passwordHash ?? this.passwordHash,
    passwordSalt: passwordSalt ?? this.passwordSalt,
    profileImagePath: profileImagePath.present
        ? profileImagePath.value
        : this.profileImagePath,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      passwordSalt: data.passwordSalt.present
          ? data.passwordSalt.value
          : this.passwordSalt,
      profileImagePath: data.profileImagePath.present
          ? data.profileImagePath.value
          : this.profileImagePath,
      role: data.role.present ? data.role.value : this.role,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('profileImagePath: $profileImagePath, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    displayName,
    passwordHash,
    passwordSalt,
    profileImagePath,
    role,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.passwordHash == this.passwordHash &&
          other.passwordSalt == this.passwordSalt &&
          other.profileImagePath == this.profileImagePath &&
          other.role == this.role &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> displayName;
  final Value<String> passwordHash;
  final Value<String> passwordSalt;
  final Value<String?> profileImagePath;
  final Value<String> role;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.passwordSalt = const Value.absent(),
    this.profileImagePath = const Value.absent(),
    this.role = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    required String displayName,
    required String passwordHash,
    required String passwordSalt,
    this.profileImagePath = const Value.absent(),
    this.role = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       displayName = Value(displayName),
       passwordHash = Value(passwordHash),
       passwordSalt = Value(passwordSalt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<String>? passwordHash,
    Expression<String>? passwordSalt,
    Expression<String>? profileImagePath,
    Expression<String>? role,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (passwordSalt != null) 'password_salt': passwordSalt,
      if (profileImagePath != null) 'profile_image_path': profileImagePath,
      if (role != null) 'role': role,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String>? displayName,
    Value<String>? passwordHash,
    Value<String>? passwordSalt,
    Value<String?>? profileImagePath,
    Value<String>? role,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (passwordSalt.present) {
      map['password_salt'] = Variable<String>(passwordSalt.value);
    }
    if (profileImagePath.present) {
      map['profile_image_path'] = Variable<String>(profileImagePath.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('profileImagePath: $profileImagePath, ')
          ..write('role: $role, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _bankNameMeta = const VerificationMeta(
    'bankName',
  );
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
    'bank_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _holderMeta = const VerificationMeta('holder');
  @override
  late final GeneratedColumn<String> holder = GeneratedColumn<String>(
    'holder',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ibanMeta = const VerificationMeta('iban');
  @override
  late final GeneratedColumn<String> iban = GeneratedColumn<String>(
    'iban',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bicMeta = const VerificationMeta('bic');
  @override
  late final GeneratedColumn<String> bic = GeneratedColumn<String>(
    'bic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _accountNumberMeta = const VerificationMeta(
    'accountNumber',
  );
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
    'account_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _availableBalanceMeta = const VerificationMeta(
    'availableBalance',
  );
  @override
  late final GeneratedColumn<double> availableBalance = GeneratedColumn<double>(
    'available_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _usageTypeMeta = const VerificationMeta(
    'usageType',
  );
  @override
  late final GeneratedColumn<String> usageType = GeneratedColumn<String>(
    'usage_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unassigned'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    bankName,
    label,
    holder,
    iban,
    bic,
    accountNumber,
    currency,
    balance,
    availableBalance,
    usageType,
    notes,
    displayOrder,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('bank_name')) {
      context.handle(
        _bankNameMeta,
        bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bankNameMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('holder')) {
      context.handle(
        _holderMeta,
        holder.isAcceptableOrUnknown(data['holder']!, _holderMeta),
      );
    }
    if (data.containsKey('iban')) {
      context.handle(
        _ibanMeta,
        iban.isAcceptableOrUnknown(data['iban']!, _ibanMeta),
      );
    }
    if (data.containsKey('bic')) {
      context.handle(
        _bicMeta,
        bic.isAcceptableOrUnknown(data['bic']!, _bicMeta),
      );
    }
    if (data.containsKey('account_number')) {
      context.handle(
        _accountNumberMeta,
        accountNumber.isAcceptableOrUnknown(
          data['account_number']!,
          _accountNumberMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('available_balance')) {
      context.handle(
        _availableBalanceMeta,
        availableBalance.isAcceptableOrUnknown(
          data['available_balance']!,
          _availableBalanceMeta,
        ),
      );
    }
    if (data.containsKey('usage_type')) {
      context.handle(
        _usageTypeMeta,
        usageType.isAcceptableOrUnknown(data['usage_type']!, _usageTypeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      bankName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_name'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      holder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}holder'],
      )!,
      iban: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iban'],
      )!,
      bic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bic'],
      )!,
      accountNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_number'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      )!,
      availableBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}available_balance'],
      )!,
      usageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usage_type'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String userId;
  final String bankName;
  final String label;
  final String holder;
  final String iban;
  final String bic;
  final String accountNumber;
  final String currency;
  final double balance;
  final double availableBalance;
  final String usageType;
  final String notes;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Account({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.label,
    required this.holder,
    required this.iban,
    required this.bic,
    required this.accountNumber,
    required this.currency,
    required this.balance,
    required this.availableBalance,
    required this.usageType,
    required this.notes,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['bank_name'] = Variable<String>(bankName);
    map['label'] = Variable<String>(label);
    map['holder'] = Variable<String>(holder);
    map['iban'] = Variable<String>(iban);
    map['bic'] = Variable<String>(bic);
    map['account_number'] = Variable<String>(accountNumber);
    map['currency'] = Variable<String>(currency);
    map['balance'] = Variable<double>(balance);
    map['available_balance'] = Variable<double>(availableBalance);
    map['usage_type'] = Variable<String>(usageType);
    map['notes'] = Variable<String>(notes);
    map['display_order'] = Variable<int>(displayOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      userId: Value(userId),
      bankName: Value(bankName),
      label: Value(label),
      holder: Value(holder),
      iban: Value(iban),
      bic: Value(bic),
      accountNumber: Value(accountNumber),
      currency: Value(currency),
      balance: Value(balance),
      availableBalance: Value(availableBalance),
      usageType: Value(usageType),
      notes: Value(notes),
      displayOrder: Value(displayOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      bankName: serializer.fromJson<String>(json['bankName']),
      label: serializer.fromJson<String>(json['label']),
      holder: serializer.fromJson<String>(json['holder']),
      iban: serializer.fromJson<String>(json['iban']),
      bic: serializer.fromJson<String>(json['bic']),
      accountNumber: serializer.fromJson<String>(json['accountNumber']),
      currency: serializer.fromJson<String>(json['currency']),
      balance: serializer.fromJson<double>(json['balance']),
      availableBalance: serializer.fromJson<double>(json['availableBalance']),
      usageType: serializer.fromJson<String>(json['usageType']),
      notes: serializer.fromJson<String>(json['notes']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'bankName': serializer.toJson<String>(bankName),
      'label': serializer.toJson<String>(label),
      'holder': serializer.toJson<String>(holder),
      'iban': serializer.toJson<String>(iban),
      'bic': serializer.toJson<String>(bic),
      'accountNumber': serializer.toJson<String>(accountNumber),
      'currency': serializer.toJson<String>(currency),
      'balance': serializer.toJson<double>(balance),
      'availableBalance': serializer.toJson<double>(availableBalance),
      'usageType': serializer.toJson<String>(usageType),
      'notes': serializer.toJson<String>(notes),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Account copyWith({
    String? id,
    String? userId,
    String? bankName,
    String? label,
    String? holder,
    String? iban,
    String? bic,
    String? accountNumber,
    String? currency,
    double? balance,
    double? availableBalance,
    String? usageType,
    String? notes,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Account(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    bankName: bankName ?? this.bankName,
    label: label ?? this.label,
    holder: holder ?? this.holder,
    iban: iban ?? this.iban,
    bic: bic ?? this.bic,
    accountNumber: accountNumber ?? this.accountNumber,
    currency: currency ?? this.currency,
    balance: balance ?? this.balance,
    availableBalance: availableBalance ?? this.availableBalance,
    usageType: usageType ?? this.usageType,
    notes: notes ?? this.notes,
    displayOrder: displayOrder ?? this.displayOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      label: data.label.present ? data.label.value : this.label,
      holder: data.holder.present ? data.holder.value : this.holder,
      iban: data.iban.present ? data.iban.value : this.iban,
      bic: data.bic.present ? data.bic.value : this.bic,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      currency: data.currency.present ? data.currency.value : this.currency,
      balance: data.balance.present ? data.balance.value : this.balance,
      availableBalance: data.availableBalance.present
          ? data.availableBalance.value
          : this.availableBalance,
      usageType: data.usageType.present ? data.usageType.value : this.usageType,
      notes: data.notes.present ? data.notes.value : this.notes,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('bankName: $bankName, ')
          ..write('label: $label, ')
          ..write('holder: $holder, ')
          ..write('iban: $iban, ')
          ..write('bic: $bic, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('currency: $currency, ')
          ..write('balance: $balance, ')
          ..write('availableBalance: $availableBalance, ')
          ..write('usageType: $usageType, ')
          ..write('notes: $notes, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    bankName,
    label,
    holder,
    iban,
    bic,
    accountNumber,
    currency,
    balance,
    availableBalance,
    usageType,
    notes,
    displayOrder,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.bankName == this.bankName &&
          other.label == this.label &&
          other.holder == this.holder &&
          other.iban == this.iban &&
          other.bic == this.bic &&
          other.accountNumber == this.accountNumber &&
          other.currency == this.currency &&
          other.balance == this.balance &&
          other.availableBalance == this.availableBalance &&
          other.usageType == this.usageType &&
          other.notes == this.notes &&
          other.displayOrder == this.displayOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> bankName;
  final Value<String> label;
  final Value<String> holder;
  final Value<String> iban;
  final Value<String> bic;
  final Value<String> accountNumber;
  final Value<String> currency;
  final Value<double> balance;
  final Value<double> availableBalance;
  final Value<String> usageType;
  final Value<String> notes;
  final Value<int> displayOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.bankName = const Value.absent(),
    this.label = const Value.absent(),
    this.holder = const Value.absent(),
    this.iban = const Value.absent(),
    this.bic = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.currency = const Value.absent(),
    this.balance = const Value.absent(),
    this.availableBalance = const Value.absent(),
    this.usageType = const Value.absent(),
    this.notes = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String userId,
    required String bankName,
    required String label,
    this.holder = const Value.absent(),
    this.iban = const Value.absent(),
    this.bic = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.currency = const Value.absent(),
    this.balance = const Value.absent(),
    this.availableBalance = const Value.absent(),
    this.usageType = const Value.absent(),
    this.notes = const Value.absent(),
    this.displayOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       bankName = Value(bankName),
       label = Value(label),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? bankName,
    Expression<String>? label,
    Expression<String>? holder,
    Expression<String>? iban,
    Expression<String>? bic,
    Expression<String>? accountNumber,
    Expression<String>? currency,
    Expression<double>? balance,
    Expression<double>? availableBalance,
    Expression<String>? usageType,
    Expression<String>? notes,
    Expression<int>? displayOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (bankName != null) 'bank_name': bankName,
      if (label != null) 'label': label,
      if (holder != null) 'holder': holder,
      if (iban != null) 'iban': iban,
      if (bic != null) 'bic': bic,
      if (accountNumber != null) 'account_number': accountNumber,
      if (currency != null) 'currency': currency,
      if (balance != null) 'balance': balance,
      if (availableBalance != null) 'available_balance': availableBalance,
      if (usageType != null) 'usage_type': usageType,
      if (notes != null) 'notes': notes,
      if (displayOrder != null) 'display_order': displayOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? bankName,
    Value<String>? label,
    Value<String>? holder,
    Value<String>? iban,
    Value<String>? bic,
    Value<String>? accountNumber,
    Value<String>? currency,
    Value<double>? balance,
    Value<double>? availableBalance,
    Value<String>? usageType,
    Value<String>? notes,
    Value<int>? displayOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bankName: bankName ?? this.bankName,
      label: label ?? this.label,
      holder: holder ?? this.holder,
      iban: iban ?? this.iban,
      bic: bic ?? this.bic,
      accountNumber: accountNumber ?? this.accountNumber,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      availableBalance: availableBalance ?? this.availableBalance,
      usageType: usageType ?? this.usageType,
      notes: notes ?? this.notes,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (holder.present) {
      map['holder'] = Variable<String>(holder.value);
    }
    if (iban.present) {
      map['iban'] = Variable<String>(iban.value);
    }
    if (bic.present) {
      map['bic'] = Variable<String>(bic.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (availableBalance.present) {
      map['available_balance'] = Variable<double>(availableBalance.value);
    }
    if (usageType.present) {
      map['usage_type'] = Variable<String>(usageType.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('bankName: $bankName, ')
          ..write('label: $label, ')
          ..write('holder: $holder, ')
          ..write('iban: $iban, ')
          ..write('bic: $bic, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('currency: $currency, ')
          ..write('balance: $balance, ')
          ..write('availableBalance: $availableBalance, ')
          ..write('usageType: $usageType, ')
          ..write('notes: $notes, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountBalanceHistoriesTable extends AccountBalanceHistories
    with TableInfo<$AccountBalanceHistoriesTable, AccountBalanceHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountBalanceHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _effectiveAtMeta = const VerificationMeta(
    'effectiveAt',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveAt = GeneratedColumn<DateTime>(
    'effective_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _availableBalanceMeta = const VerificationMeta(
    'availableBalance',
  );
  @override
  late final GeneratedColumn<double> availableBalance = GeneratedColumn<double>(
    'available_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    accountId,
    effectiveAt,
    balance,
    availableBalance,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_balance_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountBalanceHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('effective_at')) {
      context.handle(
        _effectiveAtMeta,
        effectiveAt.isAcceptableOrUnknown(
          data['effective_at']!,
          _effectiveAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveAtMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('available_balance')) {
      context.handle(
        _availableBalanceMeta,
        availableBalance.isAcceptableOrUnknown(
          data['available_balance']!,
          _availableBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_availableBalanceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountBalanceHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountBalanceHistory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      effectiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_at'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      )!,
      availableBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}available_balance'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AccountBalanceHistoriesTable createAlias(String alias) {
    return $AccountBalanceHistoriesTable(attachedDatabase, alias);
  }
}

class AccountBalanceHistory extends DataClass
    implements Insertable<AccountBalanceHistory> {
  final String id;
  final String userId;
  final String accountId;
  final DateTime effectiveAt;
  final double balance;
  final double availableBalance;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const AccountBalanceHistory({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.effectiveAt,
    required this.balance,
    required this.availableBalance,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['account_id'] = Variable<String>(accountId);
    map['effective_at'] = Variable<DateTime>(effectiveAt);
    map['balance'] = Variable<double>(balance);
    map['available_balance'] = Variable<double>(availableBalance);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AccountBalanceHistoriesCompanion toCompanion(bool nullToAbsent) {
    return AccountBalanceHistoriesCompanion(
      id: Value(id),
      userId: Value(userId),
      accountId: Value(accountId),
      effectiveAt: Value(effectiveAt),
      balance: Value(balance),
      availableBalance: Value(availableBalance),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory AccountBalanceHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountBalanceHistory(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      effectiveAt: serializer.fromJson<DateTime>(json['effectiveAt']),
      balance: serializer.fromJson<double>(json['balance']),
      availableBalance: serializer.fromJson<double>(json['availableBalance']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'accountId': serializer.toJson<String>(accountId),
      'effectiveAt': serializer.toJson<DateTime>(effectiveAt),
      'balance': serializer.toJson<double>(balance),
      'availableBalance': serializer.toJson<double>(availableBalance),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  AccountBalanceHistory copyWith({
    String? id,
    String? userId,
    String? accountId,
    DateTime? effectiveAt,
    double? balance,
    double? availableBalance,
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => AccountBalanceHistory(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    accountId: accountId ?? this.accountId,
    effectiveAt: effectiveAt ?? this.effectiveAt,
    balance: balance ?? this.balance,
    availableBalance: availableBalance ?? this.availableBalance,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  AccountBalanceHistory copyWithCompanion(
    AccountBalanceHistoriesCompanion data,
  ) {
    return AccountBalanceHistory(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      effectiveAt: data.effectiveAt.present
          ? data.effectiveAt.value
          : this.effectiveAt,
      balance: data.balance.present ? data.balance.value : this.balance,
      availableBalance: data.availableBalance.present
          ? data.availableBalance.value
          : this.availableBalance,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountBalanceHistory(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('balance: $balance, ')
          ..write('availableBalance: $availableBalance, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    accountId,
    effectiveAt,
    balance,
    availableBalance,
    createdAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountBalanceHistory &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.accountId == this.accountId &&
          other.effectiveAt == this.effectiveAt &&
          other.balance == this.balance &&
          other.availableBalance == this.availableBalance &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class AccountBalanceHistoriesCompanion
    extends UpdateCompanion<AccountBalanceHistory> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> accountId;
  final Value<DateTime> effectiveAt;
  final Value<double> balance;
  final Value<double> availableBalance;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const AccountBalanceHistoriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.effectiveAt = const Value.absent(),
    this.balance = const Value.absent(),
    this.availableBalance = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountBalanceHistoriesCompanion.insert({
    required String id,
    required String userId,
    required String accountId,
    required DateTime effectiveAt,
    required double balance,
    required double availableBalance,
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       accountId = Value(accountId),
       effectiveAt = Value(effectiveAt),
       balance = Value(balance),
       availableBalance = Value(availableBalance),
       createdAt = Value(createdAt);
  static Insertable<AccountBalanceHistory> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? accountId,
    Expression<DateTime>? effectiveAt,
    Expression<double>? balance,
    Expression<double>? availableBalance,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (accountId != null) 'account_id': accountId,
      if (effectiveAt != null) 'effective_at': effectiveAt,
      if (balance != null) 'balance': balance,
      if (availableBalance != null) 'available_balance': availableBalance,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountBalanceHistoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? accountId,
    Value<DateTime>? effectiveAt,
    Value<double>? balance,
    Value<double>? availableBalance,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return AccountBalanceHistoriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      effectiveAt: effectiveAt ?? this.effectiveAt,
      balance: balance ?? this.balance,
      availableBalance: availableBalance ?? this.availableBalance,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (effectiveAt.present) {
      map['effective_at'] = Variable<DateTime>(effectiveAt.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (availableBalance.present) {
      map['available_balance'] = Variable<double>(availableBalance.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountBalanceHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('balance: $balance, ')
          ..write('availableBalance: $availableBalance, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentsTable extends Investments
    with TableInfo<$InvestmentsTable, Investment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _stockIdMeta = const VerificationMeta(
    'stockId',
  );
  @override
  late final GeneratedColumn<String> stockId = GeneratedColumn<String>(
    'stock_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isinMeta = const VerificationMeta('isin');
  @override
  late final GeneratedColumn<String> isin = GeneratedColumn<String>(
    'isin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _wknMeta = const VerificationMeta('wkn');
  @override
  late final GeneratedColumn<String> wkn = GeneratedColumn<String>(
    'wkn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _assetTypeMeta = const VerificationMeta(
    'assetType',
  );
  @override
  late final GeneratedColumn<String> assetType = GeneratedColumn<String>(
    'asset_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brokerMeta = const VerificationMeta('broker');
  @override
  late final GeneratedColumn<String> broker = GeneratedColumn<String>(
    'broker',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sectorMeta = const VerificationMeta('sector');
  @override
  late final GeneratedColumn<String> sector = GeneratedColumn<String>(
    'sector',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feesMeta = const VerificationMeta('fees');
  @override
  late final GeneratedColumn<double> fees = GeneratedColumn<double>(
    'fees',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentPriceMeta = const VerificationMeta(
    'currentPrice',
  );
  @override
  late final GeneratedColumn<double> currentPrice = GeneratedColumn<double>(
    'current_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _annualDividendMeta = const VerificationMeta(
    'annualDividend',
  );
  @override
  late final GeneratedColumn<double> annualDividend = GeneratedColumn<double>(
    'annual_dividend',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dividendCurrencyMeta = const VerificationMeta(
    'dividendCurrency',
  );
  @override
  late final GeneratedColumn<String> dividendCurrency = GeneratedColumn<String>(
    'dividend_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _dividendExchangeRateMeta =
      const VerificationMeta('dividendExchangeRate');
  @override
  late final GeneratedColumn<double> dividendExchangeRate =
      GeneratedColumn<double>(
        'dividend_exchange_rate',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1),
      );
  static const VerificationMeta _dividendWithholdingTaxRateMeta =
      const VerificationMeta('dividendWithholdingTaxRate');
  @override
  late final GeneratedColumn<double> dividendWithholdingTaxRate =
      GeneratedColumn<double>(
        'dividend_withholding_tax_rate',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _dividendFrequencyMeta = const VerificationMeta(
    'dividendFrequency',
  );
  @override
  late final GeneratedColumn<String> dividendFrequency =
      GeneratedColumn<String>(
        'dividend_frequency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('jährlich'),
      );
  static const VerificationMeta _dividendStartMonthMeta =
      const VerificationMeta('dividendStartMonth');
  @override
  late final GeneratedColumn<int> dividendStartMonth = GeneratedColumn<int>(
    'dividend_start_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    stockId,
    accountId,
    name,
    symbol,
    isin,
    wkn,
    assetType,
    broker,
    country,
    sector,
    purchaseDate,
    purchasePrice,
    quantity,
    fees,
    currentPrice,
    annualDividend,
    dividendCurrency,
    dividendExchangeRate,
    dividendWithholdingTaxRate,
    dividendFrequency,
    dividendStartMonth,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Investment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('stock_id')) {
      context.handle(
        _stockIdMeta,
        stockId.isAcceptableOrUnknown(data['stock_id']!, _stockIdMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
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
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    }
    if (data.containsKey('isin')) {
      context.handle(
        _isinMeta,
        isin.isAcceptableOrUnknown(data['isin']!, _isinMeta),
      );
    }
    if (data.containsKey('wkn')) {
      context.handle(
        _wknMeta,
        wkn.isAcceptableOrUnknown(data['wkn']!, _wknMeta),
      );
    }
    if (data.containsKey('asset_type')) {
      context.handle(
        _assetTypeMeta,
        assetType.isAcceptableOrUnknown(data['asset_type']!, _assetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_assetTypeMeta);
    }
    if (data.containsKey('broker')) {
      context.handle(
        _brokerMeta,
        broker.isAcceptableOrUnknown(data['broker']!, _brokerMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('sector')) {
      context.handle(
        _sectorMeta,
        sector.isAcceptableOrUnknown(data['sector']!, _sectorMeta),
      );
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseDateMeta);
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('fees')) {
      context.handle(
        _feesMeta,
        fees.isAcceptableOrUnknown(data['fees']!, _feesMeta),
      );
    }
    if (data.containsKey('current_price')) {
      context.handle(
        _currentPriceMeta,
        currentPrice.isAcceptableOrUnknown(
          data['current_price']!,
          _currentPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentPriceMeta);
    }
    if (data.containsKey('annual_dividend')) {
      context.handle(
        _annualDividendMeta,
        annualDividend.isAcceptableOrUnknown(
          data['annual_dividend']!,
          _annualDividendMeta,
        ),
      );
    }
    if (data.containsKey('dividend_currency')) {
      context.handle(
        _dividendCurrencyMeta,
        dividendCurrency.isAcceptableOrUnknown(
          data['dividend_currency']!,
          _dividendCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('dividend_exchange_rate')) {
      context.handle(
        _dividendExchangeRateMeta,
        dividendExchangeRate.isAcceptableOrUnknown(
          data['dividend_exchange_rate']!,
          _dividendExchangeRateMeta,
        ),
      );
    }
    if (data.containsKey('dividend_withholding_tax_rate')) {
      context.handle(
        _dividendWithholdingTaxRateMeta,
        dividendWithholdingTaxRate.isAcceptableOrUnknown(
          data['dividend_withholding_tax_rate']!,
          _dividendWithholdingTaxRateMeta,
        ),
      );
    }
    if (data.containsKey('dividend_frequency')) {
      context.handle(
        _dividendFrequencyMeta,
        dividendFrequency.isAcceptableOrUnknown(
          data['dividend_frequency']!,
          _dividendFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('dividend_start_month')) {
      context.handle(
        _dividendStartMonthMeta,
        dividendStartMonth.isAcceptableOrUnknown(
          data['dividend_start_month']!,
          _dividendStartMonthMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Investment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Investment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      stockId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_id'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      isin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isin'],
      )!,
      wkn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wkn'],
      )!,
      assetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_type'],
      )!,
      broker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}broker'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      sector: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector'],
      )!,
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      )!,
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      fees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fees'],
      )!,
      currentPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_price'],
      )!,
      annualDividend: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}annual_dividend'],
      )!,
      dividendCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dividend_currency'],
      )!,
      dividendExchangeRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dividend_exchange_rate'],
      )!,
      dividendWithholdingTaxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dividend_withholding_tax_rate'],
      )!,
      dividendFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dividend_frequency'],
      )!,
      dividendStartMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dividend_start_month'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $InvestmentsTable createAlias(String alias) {
    return $InvestmentsTable(attachedDatabase, alias);
  }
}

class Investment extends DataClass implements Insertable<Investment> {
  final String id;
  final String userId;
  final String? stockId;
  final String accountId;
  final String name;
  final String symbol;
  final String isin;
  final String wkn;
  final String assetType;
  final String broker;
  final String country;
  final String sector;
  final DateTime purchaseDate;
  final double purchasePrice;
  final double quantity;
  final double fees;
  final double currentPrice;
  final double annualDividend;
  final String dividendCurrency;
  final double dividendExchangeRate;
  final double dividendWithholdingTaxRate;
  final String dividendFrequency;
  final int dividendStartMonth;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Investment({
    required this.id,
    required this.userId,
    this.stockId,
    required this.accountId,
    required this.name,
    required this.symbol,
    required this.isin,
    required this.wkn,
    required this.assetType,
    required this.broker,
    required this.country,
    required this.sector,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.quantity,
    required this.fees,
    required this.currentPrice,
    required this.annualDividend,
    required this.dividendCurrency,
    required this.dividendExchangeRate,
    required this.dividendWithholdingTaxRate,
    required this.dividendFrequency,
    required this.dividendStartMonth,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || stockId != null) {
      map['stock_id'] = Variable<String>(stockId);
    }
    map['account_id'] = Variable<String>(accountId);
    map['name'] = Variable<String>(name);
    map['symbol'] = Variable<String>(symbol);
    map['isin'] = Variable<String>(isin);
    map['wkn'] = Variable<String>(wkn);
    map['asset_type'] = Variable<String>(assetType);
    map['broker'] = Variable<String>(broker);
    map['country'] = Variable<String>(country);
    map['sector'] = Variable<String>(sector);
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['quantity'] = Variable<double>(quantity);
    map['fees'] = Variable<double>(fees);
    map['current_price'] = Variable<double>(currentPrice);
    map['annual_dividend'] = Variable<double>(annualDividend);
    map['dividend_currency'] = Variable<String>(dividendCurrency);
    map['dividend_exchange_rate'] = Variable<double>(dividendExchangeRate);
    map['dividend_withholding_tax_rate'] = Variable<double>(
      dividendWithholdingTaxRate,
    );
    map['dividend_frequency'] = Variable<String>(dividendFrequency);
    map['dividend_start_month'] = Variable<int>(dividendStartMonth);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  InvestmentsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentsCompanion(
      id: Value(id),
      userId: Value(userId),
      stockId: stockId == null && nullToAbsent
          ? const Value.absent()
          : Value(stockId),
      accountId: Value(accountId),
      name: Value(name),
      symbol: Value(symbol),
      isin: Value(isin),
      wkn: Value(wkn),
      assetType: Value(assetType),
      broker: Value(broker),
      country: Value(country),
      sector: Value(sector),
      purchaseDate: Value(purchaseDate),
      purchasePrice: Value(purchasePrice),
      quantity: Value(quantity),
      fees: Value(fees),
      currentPrice: Value(currentPrice),
      annualDividend: Value(annualDividend),
      dividendCurrency: Value(dividendCurrency),
      dividendExchangeRate: Value(dividendExchangeRate),
      dividendWithholdingTaxRate: Value(dividendWithholdingTaxRate),
      dividendFrequency: Value(dividendFrequency),
      dividendStartMonth: Value(dividendStartMonth),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Investment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Investment(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      stockId: serializer.fromJson<String?>(json['stockId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      name: serializer.fromJson<String>(json['name']),
      symbol: serializer.fromJson<String>(json['symbol']),
      isin: serializer.fromJson<String>(json['isin']),
      wkn: serializer.fromJson<String>(json['wkn']),
      assetType: serializer.fromJson<String>(json['assetType']),
      broker: serializer.fromJson<String>(json['broker']),
      country: serializer.fromJson<String>(json['country']),
      sector: serializer.fromJson<String>(json['sector']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      quantity: serializer.fromJson<double>(json['quantity']),
      fees: serializer.fromJson<double>(json['fees']),
      currentPrice: serializer.fromJson<double>(json['currentPrice']),
      annualDividend: serializer.fromJson<double>(json['annualDividend']),
      dividendCurrency: serializer.fromJson<String>(json['dividendCurrency']),
      dividendExchangeRate: serializer.fromJson<double>(
        json['dividendExchangeRate'],
      ),
      dividendWithholdingTaxRate: serializer.fromJson<double>(
        json['dividendWithholdingTaxRate'],
      ),
      dividendFrequency: serializer.fromJson<String>(json['dividendFrequency']),
      dividendStartMonth: serializer.fromJson<int>(json['dividendStartMonth']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'stockId': serializer.toJson<String?>(stockId),
      'accountId': serializer.toJson<String>(accountId),
      'name': serializer.toJson<String>(name),
      'symbol': serializer.toJson<String>(symbol),
      'isin': serializer.toJson<String>(isin),
      'wkn': serializer.toJson<String>(wkn),
      'assetType': serializer.toJson<String>(assetType),
      'broker': serializer.toJson<String>(broker),
      'country': serializer.toJson<String>(country),
      'sector': serializer.toJson<String>(sector),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'quantity': serializer.toJson<double>(quantity),
      'fees': serializer.toJson<double>(fees),
      'currentPrice': serializer.toJson<double>(currentPrice),
      'annualDividend': serializer.toJson<double>(annualDividend),
      'dividendCurrency': serializer.toJson<String>(dividendCurrency),
      'dividendExchangeRate': serializer.toJson<double>(dividendExchangeRate),
      'dividendWithholdingTaxRate': serializer.toJson<double>(
        dividendWithholdingTaxRate,
      ),
      'dividendFrequency': serializer.toJson<String>(dividendFrequency),
      'dividendStartMonth': serializer.toJson<int>(dividendStartMonth),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Investment copyWith({
    String? id,
    String? userId,
    Value<String?> stockId = const Value.absent(),
    String? accountId,
    String? name,
    String? symbol,
    String? isin,
    String? wkn,
    String? assetType,
    String? broker,
    String? country,
    String? sector,
    DateTime? purchaseDate,
    double? purchasePrice,
    double? quantity,
    double? fees,
    double? currentPrice,
    double? annualDividend,
    String? dividendCurrency,
    double? dividendExchangeRate,
    double? dividendWithholdingTaxRate,
    String? dividendFrequency,
    int? dividendStartMonth,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Investment(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    stockId: stockId.present ? stockId.value : this.stockId,
    accountId: accountId ?? this.accountId,
    name: name ?? this.name,
    symbol: symbol ?? this.symbol,
    isin: isin ?? this.isin,
    wkn: wkn ?? this.wkn,
    assetType: assetType ?? this.assetType,
    broker: broker ?? this.broker,
    country: country ?? this.country,
    sector: sector ?? this.sector,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    quantity: quantity ?? this.quantity,
    fees: fees ?? this.fees,
    currentPrice: currentPrice ?? this.currentPrice,
    annualDividend: annualDividend ?? this.annualDividend,
    dividendCurrency: dividendCurrency ?? this.dividendCurrency,
    dividendExchangeRate: dividendExchangeRate ?? this.dividendExchangeRate,
    dividendWithholdingTaxRate:
        dividendWithholdingTaxRate ?? this.dividendWithholdingTaxRate,
    dividendFrequency: dividendFrequency ?? this.dividendFrequency,
    dividendStartMonth: dividendStartMonth ?? this.dividendStartMonth,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Investment copyWithCompanion(InvestmentsCompanion data) {
    return Investment(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      stockId: data.stockId.present ? data.stockId.value : this.stockId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      name: data.name.present ? data.name.value : this.name,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      isin: data.isin.present ? data.isin.value : this.isin,
      wkn: data.wkn.present ? data.wkn.value : this.wkn,
      assetType: data.assetType.present ? data.assetType.value : this.assetType,
      broker: data.broker.present ? data.broker.value : this.broker,
      country: data.country.present ? data.country.value : this.country,
      sector: data.sector.present ? data.sector.value : this.sector,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      fees: data.fees.present ? data.fees.value : this.fees,
      currentPrice: data.currentPrice.present
          ? data.currentPrice.value
          : this.currentPrice,
      annualDividend: data.annualDividend.present
          ? data.annualDividend.value
          : this.annualDividend,
      dividendCurrency: data.dividendCurrency.present
          ? data.dividendCurrency.value
          : this.dividendCurrency,
      dividendExchangeRate: data.dividendExchangeRate.present
          ? data.dividendExchangeRate.value
          : this.dividendExchangeRate,
      dividendWithholdingTaxRate: data.dividendWithholdingTaxRate.present
          ? data.dividendWithholdingTaxRate.value
          : this.dividendWithholdingTaxRate,
      dividendFrequency: data.dividendFrequency.present
          ? data.dividendFrequency.value
          : this.dividendFrequency,
      dividendStartMonth: data.dividendStartMonth.present
          ? data.dividendStartMonth.value
          : this.dividendStartMonth,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Investment(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('stockId: $stockId, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('isin: $isin, ')
          ..write('wkn: $wkn, ')
          ..write('assetType: $assetType, ')
          ..write('broker: $broker, ')
          ..write('country: $country, ')
          ..write('sector: $sector, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('quantity: $quantity, ')
          ..write('fees: $fees, ')
          ..write('currentPrice: $currentPrice, ')
          ..write('annualDividend: $annualDividend, ')
          ..write('dividendCurrency: $dividendCurrency, ')
          ..write('dividendExchangeRate: $dividendExchangeRate, ')
          ..write('dividendWithholdingTaxRate: $dividendWithholdingTaxRate, ')
          ..write('dividendFrequency: $dividendFrequency, ')
          ..write('dividendStartMonth: $dividendStartMonth, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    stockId,
    accountId,
    name,
    symbol,
    isin,
    wkn,
    assetType,
    broker,
    country,
    sector,
    purchaseDate,
    purchasePrice,
    quantity,
    fees,
    currentPrice,
    annualDividend,
    dividendCurrency,
    dividendExchangeRate,
    dividendWithholdingTaxRate,
    dividendFrequency,
    dividendStartMonth,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Investment &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.stockId == this.stockId &&
          other.accountId == this.accountId &&
          other.name == this.name &&
          other.symbol == this.symbol &&
          other.isin == this.isin &&
          other.wkn == this.wkn &&
          other.assetType == this.assetType &&
          other.broker == this.broker &&
          other.country == this.country &&
          other.sector == this.sector &&
          other.purchaseDate == this.purchaseDate &&
          other.purchasePrice == this.purchasePrice &&
          other.quantity == this.quantity &&
          other.fees == this.fees &&
          other.currentPrice == this.currentPrice &&
          other.annualDividend == this.annualDividend &&
          other.dividendCurrency == this.dividendCurrency &&
          other.dividendExchangeRate == this.dividendExchangeRate &&
          other.dividendWithholdingTaxRate == this.dividendWithholdingTaxRate &&
          other.dividendFrequency == this.dividendFrequency &&
          other.dividendStartMonth == this.dividendStartMonth &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class InvestmentsCompanion extends UpdateCompanion<Investment> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> stockId;
  final Value<String> accountId;
  final Value<String> name;
  final Value<String> symbol;
  final Value<String> isin;
  final Value<String> wkn;
  final Value<String> assetType;
  final Value<String> broker;
  final Value<String> country;
  final Value<String> sector;
  final Value<DateTime> purchaseDate;
  final Value<double> purchasePrice;
  final Value<double> quantity;
  final Value<double> fees;
  final Value<double> currentPrice;
  final Value<double> annualDividend;
  final Value<String> dividendCurrency;
  final Value<double> dividendExchangeRate;
  final Value<double> dividendWithholdingTaxRate;
  final Value<String> dividendFrequency;
  final Value<int> dividendStartMonth;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const InvestmentsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.stockId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.name = const Value.absent(),
    this.symbol = const Value.absent(),
    this.isin = const Value.absent(),
    this.wkn = const Value.absent(),
    this.assetType = const Value.absent(),
    this.broker = const Value.absent(),
    this.country = const Value.absent(),
    this.sector = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.quantity = const Value.absent(),
    this.fees = const Value.absent(),
    this.currentPrice = const Value.absent(),
    this.annualDividend = const Value.absent(),
    this.dividendCurrency = const Value.absent(),
    this.dividendExchangeRate = const Value.absent(),
    this.dividendWithholdingTaxRate = const Value.absent(),
    this.dividendFrequency = const Value.absent(),
    this.dividendStartMonth = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentsCompanion.insert({
    required String id,
    required String userId,
    this.stockId = const Value.absent(),
    this.accountId = const Value.absent(),
    required String name,
    this.symbol = const Value.absent(),
    this.isin = const Value.absent(),
    this.wkn = const Value.absent(),
    required String assetType,
    this.broker = const Value.absent(),
    this.country = const Value.absent(),
    this.sector = const Value.absent(),
    required DateTime purchaseDate,
    required double purchasePrice,
    required double quantity,
    this.fees = const Value.absent(),
    required double currentPrice,
    this.annualDividend = const Value.absent(),
    this.dividendCurrency = const Value.absent(),
    this.dividendExchangeRate = const Value.absent(),
    this.dividendWithholdingTaxRate = const Value.absent(),
    this.dividendFrequency = const Value.absent(),
    this.dividendStartMonth = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       assetType = Value(assetType),
       purchaseDate = Value(purchaseDate),
       purchasePrice = Value(purchasePrice),
       quantity = Value(quantity),
       currentPrice = Value(currentPrice),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Investment> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? stockId,
    Expression<String>? accountId,
    Expression<String>? name,
    Expression<String>? symbol,
    Expression<String>? isin,
    Expression<String>? wkn,
    Expression<String>? assetType,
    Expression<String>? broker,
    Expression<String>? country,
    Expression<String>? sector,
    Expression<DateTime>? purchaseDate,
    Expression<double>? purchasePrice,
    Expression<double>? quantity,
    Expression<double>? fees,
    Expression<double>? currentPrice,
    Expression<double>? annualDividend,
    Expression<String>? dividendCurrency,
    Expression<double>? dividendExchangeRate,
    Expression<double>? dividendWithholdingTaxRate,
    Expression<String>? dividendFrequency,
    Expression<int>? dividendStartMonth,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (stockId != null) 'stock_id': stockId,
      if (accountId != null) 'account_id': accountId,
      if (name != null) 'name': name,
      if (symbol != null) 'symbol': symbol,
      if (isin != null) 'isin': isin,
      if (wkn != null) 'wkn': wkn,
      if (assetType != null) 'asset_type': assetType,
      if (broker != null) 'broker': broker,
      if (country != null) 'country': country,
      if (sector != null) 'sector': sector,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (quantity != null) 'quantity': quantity,
      if (fees != null) 'fees': fees,
      if (currentPrice != null) 'current_price': currentPrice,
      if (annualDividend != null) 'annual_dividend': annualDividend,
      if (dividendCurrency != null) 'dividend_currency': dividendCurrency,
      if (dividendExchangeRate != null)
        'dividend_exchange_rate': dividendExchangeRate,
      if (dividendWithholdingTaxRate != null)
        'dividend_withholding_tax_rate': dividendWithholdingTaxRate,
      if (dividendFrequency != null) 'dividend_frequency': dividendFrequency,
      if (dividendStartMonth != null)
        'dividend_start_month': dividendStartMonth,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? stockId,
    Value<String>? accountId,
    Value<String>? name,
    Value<String>? symbol,
    Value<String>? isin,
    Value<String>? wkn,
    Value<String>? assetType,
    Value<String>? broker,
    Value<String>? country,
    Value<String>? sector,
    Value<DateTime>? purchaseDate,
    Value<double>? purchasePrice,
    Value<double>? quantity,
    Value<double>? fees,
    Value<double>? currentPrice,
    Value<double>? annualDividend,
    Value<String>? dividendCurrency,
    Value<double>? dividendExchangeRate,
    Value<double>? dividendWithholdingTaxRate,
    Value<String>? dividendFrequency,
    Value<int>? dividendStartMonth,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return InvestmentsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stockId: stockId ?? this.stockId,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      isin: isin ?? this.isin,
      wkn: wkn ?? this.wkn,
      assetType: assetType ?? this.assetType,
      broker: broker ?? this.broker,
      country: country ?? this.country,
      sector: sector ?? this.sector,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      quantity: quantity ?? this.quantity,
      fees: fees ?? this.fees,
      currentPrice: currentPrice ?? this.currentPrice,
      annualDividend: annualDividend ?? this.annualDividend,
      dividendCurrency: dividendCurrency ?? this.dividendCurrency,
      dividendExchangeRate: dividendExchangeRate ?? this.dividendExchangeRate,
      dividendWithholdingTaxRate:
          dividendWithholdingTaxRate ?? this.dividendWithholdingTaxRate,
      dividendFrequency: dividendFrequency ?? this.dividendFrequency,
      dividendStartMonth: dividendStartMonth ?? this.dividendStartMonth,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (stockId.present) {
      map['stock_id'] = Variable<String>(stockId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (isin.present) {
      map['isin'] = Variable<String>(isin.value);
    }
    if (wkn.present) {
      map['wkn'] = Variable<String>(wkn.value);
    }
    if (assetType.present) {
      map['asset_type'] = Variable<String>(assetType.value);
    }
    if (broker.present) {
      map['broker'] = Variable<String>(broker.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (sector.present) {
      map['sector'] = Variable<String>(sector.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (fees.present) {
      map['fees'] = Variable<double>(fees.value);
    }
    if (currentPrice.present) {
      map['current_price'] = Variable<double>(currentPrice.value);
    }
    if (annualDividend.present) {
      map['annual_dividend'] = Variable<double>(annualDividend.value);
    }
    if (dividendCurrency.present) {
      map['dividend_currency'] = Variable<String>(dividendCurrency.value);
    }
    if (dividendExchangeRate.present) {
      map['dividend_exchange_rate'] = Variable<double>(
        dividendExchangeRate.value,
      );
    }
    if (dividendWithholdingTaxRate.present) {
      map['dividend_withholding_tax_rate'] = Variable<double>(
        dividendWithholdingTaxRate.value,
      );
    }
    if (dividendFrequency.present) {
      map['dividend_frequency'] = Variable<String>(dividendFrequency.value);
    }
    if (dividendStartMonth.present) {
      map['dividend_start_month'] = Variable<int>(dividendStartMonth.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('stockId: $stockId, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('isin: $isin, ')
          ..write('wkn: $wkn, ')
          ..write('assetType: $assetType, ')
          ..write('broker: $broker, ')
          ..write('country: $country, ')
          ..write('sector: $sector, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('quantity: $quantity, ')
          ..write('fees: $fees, ')
          ..write('currentPrice: $currentPrice, ')
          ..write('annualDividend: $annualDividend, ')
          ..write('dividendCurrency: $dividendCurrency, ')
          ..write('dividendExchangeRate: $dividendExchangeRate, ')
          ..write('dividendWithholdingTaxRate: $dividendWithholdingTaxRate, ')
          ..write('dividendFrequency: $dividendFrequency, ')
          ..write('dividendStartMonth: $dividendStartMonth, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentPurchasesTable extends InvestmentPurchases
    with TableInfo<$InvestmentPurchasesTable, InvestmentPurchase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentPurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _investmentIdMeta = const VerificationMeta(
    'investmentId',
  );
  @override
  late final GeneratedColumn<String> investmentId = GeneratedColumn<String>(
    'investment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES investments (id)',
    ),
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feesMeta = const VerificationMeta('fees');
  @override
  late final GeneratedColumn<double> fees = GeneratedColumn<double>(
    'fees',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cashAppliedMeta = const VerificationMeta(
    'cashApplied',
  );
  @override
  late final GeneratedColumn<bool> cashApplied = GeneratedColumn<bool>(
    'cash_applied',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cash_applied" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    investmentId,
    purchaseDate,
    purchasePrice,
    quantity,
    fees,
    cashApplied,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investment_purchases';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvestmentPurchase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('investment_id')) {
      context.handle(
        _investmentIdMeta,
        investmentId.isAcceptableOrUnknown(
          data['investment_id']!,
          _investmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_investmentIdMeta);
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseDateMeta);
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('fees')) {
      context.handle(
        _feesMeta,
        fees.isAcceptableOrUnknown(data['fees']!, _feesMeta),
      );
    }
    if (data.containsKey('cash_applied')) {
      context.handle(
        _cashAppliedMeta,
        cashApplied.isAcceptableOrUnknown(
          data['cash_applied']!,
          _cashAppliedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvestmentPurchase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvestmentPurchase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      investmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}investment_id'],
      )!,
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      )!,
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      fees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fees'],
      )!,
      cashApplied: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cash_applied'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $InvestmentPurchasesTable createAlias(String alias) {
    return $InvestmentPurchasesTable(attachedDatabase, alias);
  }
}

class InvestmentPurchase extends DataClass
    implements Insertable<InvestmentPurchase> {
  final String id;
  final String userId;
  final String investmentId;
  final DateTime purchaseDate;
  final double purchasePrice;
  final double quantity;
  final double fees;
  final bool cashApplied;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const InvestmentPurchase({
    required this.id,
    required this.userId,
    required this.investmentId,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.quantity,
    required this.fees,
    required this.cashApplied,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['investment_id'] = Variable<String>(investmentId);
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['quantity'] = Variable<double>(quantity);
    map['fees'] = Variable<double>(fees);
    map['cash_applied'] = Variable<bool>(cashApplied);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  InvestmentPurchasesCompanion toCompanion(bool nullToAbsent) {
    return InvestmentPurchasesCompanion(
      id: Value(id),
      userId: Value(userId),
      investmentId: Value(investmentId),
      purchaseDate: Value(purchaseDate),
      purchasePrice: Value(purchasePrice),
      quantity: Value(quantity),
      fees: Value(fees),
      cashApplied: Value(cashApplied),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory InvestmentPurchase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvestmentPurchase(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      investmentId: serializer.fromJson<String>(json['investmentId']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      quantity: serializer.fromJson<double>(json['quantity']),
      fees: serializer.fromJson<double>(json['fees']),
      cashApplied: serializer.fromJson<bool>(json['cashApplied']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'investmentId': serializer.toJson<String>(investmentId),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'quantity': serializer.toJson<double>(quantity),
      'fees': serializer.toJson<double>(fees),
      'cashApplied': serializer.toJson<bool>(cashApplied),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  InvestmentPurchase copyWith({
    String? id,
    String? userId,
    String? investmentId,
    DateTime? purchaseDate,
    double? purchasePrice,
    double? quantity,
    double? fees,
    bool? cashApplied,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => InvestmentPurchase(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    investmentId: investmentId ?? this.investmentId,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    quantity: quantity ?? this.quantity,
    fees: fees ?? this.fees,
    cashApplied: cashApplied ?? this.cashApplied,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  InvestmentPurchase copyWithCompanion(InvestmentPurchasesCompanion data) {
    return InvestmentPurchase(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      investmentId: data.investmentId.present
          ? data.investmentId.value
          : this.investmentId,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      fees: data.fees.present ? data.fees.value : this.fees,
      cashApplied: data.cashApplied.present
          ? data.cashApplied.value
          : this.cashApplied,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentPurchase(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('investmentId: $investmentId, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('quantity: $quantity, ')
          ..write('fees: $fees, ')
          ..write('cashApplied: $cashApplied, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    investmentId,
    purchaseDate,
    purchasePrice,
    quantity,
    fees,
    cashApplied,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvestmentPurchase &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.investmentId == this.investmentId &&
          other.purchaseDate == this.purchaseDate &&
          other.purchasePrice == this.purchasePrice &&
          other.quantity == this.quantity &&
          other.fees == this.fees &&
          other.cashApplied == this.cashApplied &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class InvestmentPurchasesCompanion extends UpdateCompanion<InvestmentPurchase> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> investmentId;
  final Value<DateTime> purchaseDate;
  final Value<double> purchasePrice;
  final Value<double> quantity;
  final Value<double> fees;
  final Value<bool> cashApplied;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const InvestmentPurchasesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.investmentId = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.quantity = const Value.absent(),
    this.fees = const Value.absent(),
    this.cashApplied = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentPurchasesCompanion.insert({
    required String id,
    required String userId,
    required String investmentId,
    required DateTime purchaseDate,
    required double purchasePrice,
    required double quantity,
    this.fees = const Value.absent(),
    this.cashApplied = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       investmentId = Value(investmentId),
       purchaseDate = Value(purchaseDate),
       purchasePrice = Value(purchasePrice),
       quantity = Value(quantity),
       createdAt = Value(createdAt);
  static Insertable<InvestmentPurchase> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? investmentId,
    Expression<DateTime>? purchaseDate,
    Expression<double>? purchasePrice,
    Expression<double>? quantity,
    Expression<double>? fees,
    Expression<bool>? cashApplied,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (investmentId != null) 'investment_id': investmentId,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (quantity != null) 'quantity': quantity,
      if (fees != null) 'fees': fees,
      if (cashApplied != null) 'cash_applied': cashApplied,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentPurchasesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? investmentId,
    Value<DateTime>? purchaseDate,
    Value<double>? purchasePrice,
    Value<double>? quantity,
    Value<double>? fees,
    Value<bool>? cashApplied,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return InvestmentPurchasesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      investmentId: investmentId ?? this.investmentId,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      quantity: quantity ?? this.quantity,
      fees: fees ?? this.fees,
      cashApplied: cashApplied ?? this.cashApplied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (investmentId.present) {
      map['investment_id'] = Variable<String>(investmentId.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (fees.present) {
      map['fees'] = Variable<double>(fees.value);
    }
    if (cashApplied.present) {
      map['cash_applied'] = Variable<bool>(cashApplied.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentPurchasesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('investmentId: $investmentId, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('quantity: $quantity, ')
          ..write('fees: $fees, ')
          ..write('cashApplied: $cashApplied, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DividendSchedulesTable extends DividendSchedules
    with TableInfo<$DividendSchedulesTable, DividendSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DividendSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _investmentIdMeta = const VerificationMeta(
    'investmentId',
  );
  @override
  late final GeneratedColumn<String> investmentId = GeneratedColumn<String>(
    'investment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES investments (id)',
    ),
  );
  static const VerificationMeta _paymentMonthMeta = const VerificationMeta(
    'paymentMonth',
  );
  @override
  late final GeneratedColumn<int> paymentMonth = GeneratedColumn<int>(
    'payment_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPerShareMeta = const VerificationMeta(
    'amountPerShare',
  );
  @override
  late final GeneratedColumn<double> amountPerShare = GeneratedColumn<double>(
    'amount_per_share',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exDateMeta = const VerificationMeta('exDate');
  @override
  late final GeneratedColumn<DateTime> exDate = GeneratedColumn<DateTime>(
    'ex_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentYearMeta = const VerificationMeta(
    'paymentYear',
  );
  @override
  late final GeneratedColumn<int> paymentYear = GeneratedColumn<int>(
    'payment_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _exchangeRateMeta = const VerificationMeta(
    'exchangeRate',
  );
  @override
  late final GeneratedColumn<double> exchangeRate = GeneratedColumn<double>(
    'exchange_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _withholdingTaxRateMeta =
      const VerificationMeta('withholdingTaxRate');
  @override
  late final GeneratedColumn<double> withholdingTaxRate =
      GeneratedColumn<double>(
        'withholding_tax_rate',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    investmentId,
    paymentMonth,
    amountPerShare,
    exDate,
    paymentDate,
    paymentYear,
    currency,
    exchangeRate,
    withholdingTaxRate,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dividend_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<DividendSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('investment_id')) {
      context.handle(
        _investmentIdMeta,
        investmentId.isAcceptableOrUnknown(
          data['investment_id']!,
          _investmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_investmentIdMeta);
    }
    if (data.containsKey('payment_month')) {
      context.handle(
        _paymentMonthMeta,
        paymentMonth.isAcceptableOrUnknown(
          data['payment_month']!,
          _paymentMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMonthMeta);
    }
    if (data.containsKey('amount_per_share')) {
      context.handle(
        _amountPerShareMeta,
        amountPerShare.isAcceptableOrUnknown(
          data['amount_per_share']!,
          _amountPerShareMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPerShareMeta);
    }
    if (data.containsKey('ex_date')) {
      context.handle(
        _exDateMeta,
        exDate.isAcceptableOrUnknown(data['ex_date']!, _exDateMeta),
      );
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    }
    if (data.containsKey('payment_year')) {
      context.handle(
        _paymentYearMeta,
        paymentYear.isAcceptableOrUnknown(
          data['payment_year']!,
          _paymentYearMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('exchange_rate')) {
      context.handle(
        _exchangeRateMeta,
        exchangeRate.isAcceptableOrUnknown(
          data['exchange_rate']!,
          _exchangeRateMeta,
        ),
      );
    }
    if (data.containsKey('withholding_tax_rate')) {
      context.handle(
        _withholdingTaxRateMeta,
        withholdingTaxRate.isAcceptableOrUnknown(
          data['withholding_tax_rate']!,
          _withholdingTaxRateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DividendSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DividendSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      investmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}investment_id'],
      )!,
      paymentMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_month'],
      )!,
      amountPerShare: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_per_share'],
      )!,
      exDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ex_date'],
      ),
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      ),
      paymentYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_year'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      exchangeRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}exchange_rate'],
      )!,
      withholdingTaxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}withholding_tax_rate'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $DividendSchedulesTable createAlias(String alias) {
    return $DividendSchedulesTable(attachedDatabase, alias);
  }
}

class DividendSchedule extends DataClass
    implements Insertable<DividendSchedule> {
  final String id;
  final String userId;
  final String investmentId;
  final int paymentMonth;
  final double amountPerShare;
  final DateTime? exDate;
  final DateTime? paymentDate;
  final int paymentYear;
  final String currency;
  final double exchangeRate;
  final double withholdingTaxRate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const DividendSchedule({
    required this.id,
    required this.userId,
    required this.investmentId,
    required this.paymentMonth,
    required this.amountPerShare,
    this.exDate,
    this.paymentDate,
    required this.paymentYear,
    required this.currency,
    required this.exchangeRate,
    required this.withholdingTaxRate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['investment_id'] = Variable<String>(investmentId);
    map['payment_month'] = Variable<int>(paymentMonth);
    map['amount_per_share'] = Variable<double>(amountPerShare);
    if (!nullToAbsent || exDate != null) {
      map['ex_date'] = Variable<DateTime>(exDate);
    }
    if (!nullToAbsent || paymentDate != null) {
      map['payment_date'] = Variable<DateTime>(paymentDate);
    }
    map['payment_year'] = Variable<int>(paymentYear);
    map['currency'] = Variable<String>(currency);
    map['exchange_rate'] = Variable<double>(exchangeRate);
    map['withholding_tax_rate'] = Variable<double>(withholdingTaxRate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  DividendSchedulesCompanion toCompanion(bool nullToAbsent) {
    return DividendSchedulesCompanion(
      id: Value(id),
      userId: Value(userId),
      investmentId: Value(investmentId),
      paymentMonth: Value(paymentMonth),
      amountPerShare: Value(amountPerShare),
      exDate: exDate == null && nullToAbsent
          ? const Value.absent()
          : Value(exDate),
      paymentDate: paymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDate),
      paymentYear: Value(paymentYear),
      currency: Value(currency),
      exchangeRate: Value(exchangeRate),
      withholdingTaxRate: Value(withholdingTaxRate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory DividendSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DividendSchedule(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      investmentId: serializer.fromJson<String>(json['investmentId']),
      paymentMonth: serializer.fromJson<int>(json['paymentMonth']),
      amountPerShare: serializer.fromJson<double>(json['amountPerShare']),
      exDate: serializer.fromJson<DateTime?>(json['exDate']),
      paymentDate: serializer.fromJson<DateTime?>(json['paymentDate']),
      paymentYear: serializer.fromJson<int>(json['paymentYear']),
      currency: serializer.fromJson<String>(json['currency']),
      exchangeRate: serializer.fromJson<double>(json['exchangeRate']),
      withholdingTaxRate: serializer.fromJson<double>(
        json['withholdingTaxRate'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'investmentId': serializer.toJson<String>(investmentId),
      'paymentMonth': serializer.toJson<int>(paymentMonth),
      'amountPerShare': serializer.toJson<double>(amountPerShare),
      'exDate': serializer.toJson<DateTime?>(exDate),
      'paymentDate': serializer.toJson<DateTime?>(paymentDate),
      'paymentYear': serializer.toJson<int>(paymentYear),
      'currency': serializer.toJson<String>(currency),
      'exchangeRate': serializer.toJson<double>(exchangeRate),
      'withholdingTaxRate': serializer.toJson<double>(withholdingTaxRate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  DividendSchedule copyWith({
    String? id,
    String? userId,
    String? investmentId,
    int? paymentMonth,
    double? amountPerShare,
    Value<DateTime?> exDate = const Value.absent(),
    Value<DateTime?> paymentDate = const Value.absent(),
    int? paymentYear,
    String? currency,
    double? exchangeRate,
    double? withholdingTaxRate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => DividendSchedule(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    investmentId: investmentId ?? this.investmentId,
    paymentMonth: paymentMonth ?? this.paymentMonth,
    amountPerShare: amountPerShare ?? this.amountPerShare,
    exDate: exDate.present ? exDate.value : this.exDate,
    paymentDate: paymentDate.present ? paymentDate.value : this.paymentDate,
    paymentYear: paymentYear ?? this.paymentYear,
    currency: currency ?? this.currency,
    exchangeRate: exchangeRate ?? this.exchangeRate,
    withholdingTaxRate: withholdingTaxRate ?? this.withholdingTaxRate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  DividendSchedule copyWithCompanion(DividendSchedulesCompanion data) {
    return DividendSchedule(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      investmentId: data.investmentId.present
          ? data.investmentId.value
          : this.investmentId,
      paymentMonth: data.paymentMonth.present
          ? data.paymentMonth.value
          : this.paymentMonth,
      amountPerShare: data.amountPerShare.present
          ? data.amountPerShare.value
          : this.amountPerShare,
      exDate: data.exDate.present ? data.exDate.value : this.exDate,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      paymentYear: data.paymentYear.present
          ? data.paymentYear.value
          : this.paymentYear,
      currency: data.currency.present ? data.currency.value : this.currency,
      exchangeRate: data.exchangeRate.present
          ? data.exchangeRate.value
          : this.exchangeRate,
      withholdingTaxRate: data.withholdingTaxRate.present
          ? data.withholdingTaxRate.value
          : this.withholdingTaxRate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DividendSchedule(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('investmentId: $investmentId, ')
          ..write('paymentMonth: $paymentMonth, ')
          ..write('amountPerShare: $amountPerShare, ')
          ..write('exDate: $exDate, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('paymentYear: $paymentYear, ')
          ..write('currency: $currency, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('withholdingTaxRate: $withholdingTaxRate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    investmentId,
    paymentMonth,
    amountPerShare,
    exDate,
    paymentDate,
    paymentYear,
    currency,
    exchangeRate,
    withholdingTaxRate,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DividendSchedule &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.investmentId == this.investmentId &&
          other.paymentMonth == this.paymentMonth &&
          other.amountPerShare == this.amountPerShare &&
          other.exDate == this.exDate &&
          other.paymentDate == this.paymentDate &&
          other.paymentYear == this.paymentYear &&
          other.currency == this.currency &&
          other.exchangeRate == this.exchangeRate &&
          other.withholdingTaxRate == this.withholdingTaxRate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class DividendSchedulesCompanion extends UpdateCompanion<DividendSchedule> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> investmentId;
  final Value<int> paymentMonth;
  final Value<double> amountPerShare;
  final Value<DateTime?> exDate;
  final Value<DateTime?> paymentDate;
  final Value<int> paymentYear;
  final Value<String> currency;
  final Value<double> exchangeRate;
  final Value<double> withholdingTaxRate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const DividendSchedulesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.investmentId = const Value.absent(),
    this.paymentMonth = const Value.absent(),
    this.amountPerShare = const Value.absent(),
    this.exDate = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.paymentYear = const Value.absent(),
    this.currency = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.withholdingTaxRate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DividendSchedulesCompanion.insert({
    required String id,
    required String userId,
    required String investmentId,
    required int paymentMonth,
    required double amountPerShare,
    this.exDate = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.paymentYear = const Value.absent(),
    this.currency = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.withholdingTaxRate = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       investmentId = Value(investmentId),
       paymentMonth = Value(paymentMonth),
       amountPerShare = Value(amountPerShare),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DividendSchedule> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? investmentId,
    Expression<int>? paymentMonth,
    Expression<double>? amountPerShare,
    Expression<DateTime>? exDate,
    Expression<DateTime>? paymentDate,
    Expression<int>? paymentYear,
    Expression<String>? currency,
    Expression<double>? exchangeRate,
    Expression<double>? withholdingTaxRate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (investmentId != null) 'investment_id': investmentId,
      if (paymentMonth != null) 'payment_month': paymentMonth,
      if (amountPerShare != null) 'amount_per_share': amountPerShare,
      if (exDate != null) 'ex_date': exDate,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (paymentYear != null) 'payment_year': paymentYear,
      if (currency != null) 'currency': currency,
      if (exchangeRate != null) 'exchange_rate': exchangeRate,
      if (withholdingTaxRate != null)
        'withholding_tax_rate': withholdingTaxRate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DividendSchedulesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? investmentId,
    Value<int>? paymentMonth,
    Value<double>? amountPerShare,
    Value<DateTime?>? exDate,
    Value<DateTime?>? paymentDate,
    Value<int>? paymentYear,
    Value<String>? currency,
    Value<double>? exchangeRate,
    Value<double>? withholdingTaxRate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return DividendSchedulesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      investmentId: investmentId ?? this.investmentId,
      paymentMonth: paymentMonth ?? this.paymentMonth,
      amountPerShare: amountPerShare ?? this.amountPerShare,
      exDate: exDate ?? this.exDate,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentYear: paymentYear ?? this.paymentYear,
      currency: currency ?? this.currency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      withholdingTaxRate: withholdingTaxRate ?? this.withholdingTaxRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (investmentId.present) {
      map['investment_id'] = Variable<String>(investmentId.value);
    }
    if (paymentMonth.present) {
      map['payment_month'] = Variable<int>(paymentMonth.value);
    }
    if (amountPerShare.present) {
      map['amount_per_share'] = Variable<double>(amountPerShare.value);
    }
    if (exDate.present) {
      map['ex_date'] = Variable<DateTime>(exDate.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (paymentYear.present) {
      map['payment_year'] = Variable<int>(paymentYear.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (exchangeRate.present) {
      map['exchange_rate'] = Variable<double>(exchangeRate.value);
    }
    if (withholdingTaxRate.present) {
      map['withholding_tax_rate'] = Variable<double>(withholdingTaxRate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DividendSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('investmentId: $investmentId, ')
          ..write('paymentMonth: $paymentMonth, ')
          ..write('amountPerShare: $amountPerShare, ')
          ..write('exDate: $exDate, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('paymentYear: $paymentYear, ')
          ..write('currency: $currency, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('withholdingTaxRate: $withholdingTaxRate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerEntriesTable extends LedgerEntries
    with TableInfo<$LedgerEntriesTable, LedgerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _bookingDateMeta = const VerificationMeta(
    'bookingDate',
  );
  @override
  late final GeneratedColumn<DateTime> bookingDate = GeneratedColumn<DateTime>(
    'booking_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _budgetMonthMeta = const VerificationMeta(
    'budgetMonth',
  );
  @override
  late final GeneratedColumn<DateTime> budgetMonth = GeneratedColumn<DateTime>(
    'budget_month',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isIncomeMeta = const VerificationMeta(
    'isIncome',
  );
  @override
  late final GeneratedColumn<bool> isIncome = GeneratedColumn<bool>(
    'is_income',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_income" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _recurrenceIdMeta = const VerificationMeta(
    'recurrenceId',
  );
  @override
  late final GeneratedColumn<String> recurrenceId = GeneratedColumn<String>(
    'recurrence_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _accountAppliedMeta = const VerificationMeta(
    'accountApplied',
  );
  @override
  late final GeneratedColumn<bool> accountApplied = GeneratedColumn<bool>(
    'account_applied',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("account_applied" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    bookingDate,
    budgetMonth,
    amount,
    isIncome,
    category,
    merchant,
    description,
    paymentMethod,
    recurrenceId,
    sourceType,
    sourceId,
    vehicleId,
    accountId,
    accountApplied,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('booking_date')) {
      context.handle(
        _bookingDateMeta,
        bookingDate.isAcceptableOrUnknown(
          data['booking_date']!,
          _bookingDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bookingDateMeta);
    }
    if (data.containsKey('budget_month')) {
      context.handle(
        _budgetMonthMeta,
        budgetMonth.isAcceptableOrUnknown(
          data['budget_month']!,
          _budgetMonthMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('is_income')) {
      context.handle(
        _isIncomeMeta,
        isIncome.isAcceptableOrUnknown(data['is_income']!, _isIncomeMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_id')) {
      context.handle(
        _recurrenceIdMeta,
        recurrenceId.isAcceptableOrUnknown(
          data['recurrence_id']!,
          _recurrenceIdMeta,
        ),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('account_applied')) {
      context.handle(
        _accountAppliedMeta,
        accountApplied.isAcceptableOrUnknown(
          data['account_applied']!,
          _accountAppliedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      bookingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}booking_date'],
      )!,
      budgetMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}budget_month'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      isIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_income'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      recurrenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_id'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      accountApplied: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}account_applied'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerEntry extends DataClass implements Insertable<LedgerEntry> {
  final String id;
  final String userId;
  final DateTime bookingDate;
  final DateTime? budgetMonth;
  final double amount;
  final bool isIncome;
  final String category;
  final String merchant;
  final String description;
  final String paymentMethod;
  final String recurrenceId;
  final String sourceType;
  final String sourceId;
  final String vehicleId;
  final String accountId;
  final bool accountApplied;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const LedgerEntry({
    required this.id,
    required this.userId,
    required this.bookingDate,
    this.budgetMonth,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.merchant,
    required this.description,
    required this.paymentMethod,
    required this.recurrenceId,
    required this.sourceType,
    required this.sourceId,
    required this.vehicleId,
    required this.accountId,
    required this.accountApplied,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['booking_date'] = Variable<DateTime>(bookingDate);
    if (!nullToAbsent || budgetMonth != null) {
      map['budget_month'] = Variable<DateTime>(budgetMonth);
    }
    map['amount'] = Variable<double>(amount);
    map['is_income'] = Variable<bool>(isIncome);
    map['category'] = Variable<String>(category);
    map['merchant'] = Variable<String>(merchant);
    map['description'] = Variable<String>(description);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['recurrence_id'] = Variable<String>(recurrenceId);
    map['source_type'] = Variable<String>(sourceType);
    map['source_id'] = Variable<String>(sourceId);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['account_id'] = Variable<String>(accountId);
    map['account_applied'] = Variable<bool>(accountApplied);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      id: Value(id),
      userId: Value(userId),
      bookingDate: Value(bookingDate),
      budgetMonth: budgetMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetMonth),
      amount: Value(amount),
      isIncome: Value(isIncome),
      category: Value(category),
      merchant: Value(merchant),
      description: Value(description),
      paymentMethod: Value(paymentMethod),
      recurrenceId: Value(recurrenceId),
      sourceType: Value(sourceType),
      sourceId: Value(sourceId),
      vehicleId: Value(vehicleId),
      accountId: Value(accountId),
      accountApplied: Value(accountApplied),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LedgerEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      bookingDate: serializer.fromJson<DateTime>(json['bookingDate']),
      budgetMonth: serializer.fromJson<DateTime?>(json['budgetMonth']),
      amount: serializer.fromJson<double>(json['amount']),
      isIncome: serializer.fromJson<bool>(json['isIncome']),
      category: serializer.fromJson<String>(json['category']),
      merchant: serializer.fromJson<String>(json['merchant']),
      description: serializer.fromJson<String>(json['description']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      recurrenceId: serializer.fromJson<String>(json['recurrenceId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      accountApplied: serializer.fromJson<bool>(json['accountApplied']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'bookingDate': serializer.toJson<DateTime>(bookingDate),
      'budgetMonth': serializer.toJson<DateTime?>(budgetMonth),
      'amount': serializer.toJson<double>(amount),
      'isIncome': serializer.toJson<bool>(isIncome),
      'category': serializer.toJson<String>(category),
      'merchant': serializer.toJson<String>(merchant),
      'description': serializer.toJson<String>(description),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'recurrenceId': serializer.toJson<String>(recurrenceId),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String>(sourceId),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'accountId': serializer.toJson<String>(accountId),
      'accountApplied': serializer.toJson<bool>(accountApplied),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LedgerEntry copyWith({
    String? id,
    String? userId,
    DateTime? bookingDate,
    Value<DateTime?> budgetMonth = const Value.absent(),
    double? amount,
    bool? isIncome,
    String? category,
    String? merchant,
    String? description,
    String? paymentMethod,
    String? recurrenceId,
    String? sourceType,
    String? sourceId,
    String? vehicleId,
    String? accountId,
    bool? accountApplied,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LedgerEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    bookingDate: bookingDate ?? this.bookingDate,
    budgetMonth: budgetMonth.present ? budgetMonth.value : this.budgetMonth,
    amount: amount ?? this.amount,
    isIncome: isIncome ?? this.isIncome,
    category: category ?? this.category,
    merchant: merchant ?? this.merchant,
    description: description ?? this.description,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    recurrenceId: recurrenceId ?? this.recurrenceId,
    sourceType: sourceType ?? this.sourceType,
    sourceId: sourceId ?? this.sourceId,
    vehicleId: vehicleId ?? this.vehicleId,
    accountId: accountId ?? this.accountId,
    accountApplied: accountApplied ?? this.accountApplied,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LedgerEntry copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      bookingDate: data.bookingDate.present
          ? data.bookingDate.value
          : this.bookingDate,
      budgetMonth: data.budgetMonth.present
          ? data.budgetMonth.value
          : this.budgetMonth,
      amount: data.amount.present ? data.amount.value : this.amount,
      isIncome: data.isIncome.present ? data.isIncome.value : this.isIncome,
      category: data.category.present ? data.category.value : this.category,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      description: data.description.present
          ? data.description.value
          : this.description,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      recurrenceId: data.recurrenceId.present
          ? data.recurrenceId.value
          : this.recurrenceId,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      accountApplied: data.accountApplied.present
          ? data.accountApplied.value
          : this.accountApplied,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('bookingDate: $bookingDate, ')
          ..write('budgetMonth: $budgetMonth, ')
          ..write('amount: $amount, ')
          ..write('isIncome: $isIncome, ')
          ..write('category: $category, ')
          ..write('merchant: $merchant, ')
          ..write('description: $description, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('recurrenceId: $recurrenceId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('accountId: $accountId, ')
          ..write('accountApplied: $accountApplied, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    bookingDate,
    budgetMonth,
    amount,
    isIncome,
    category,
    merchant,
    description,
    paymentMethod,
    recurrenceId,
    sourceType,
    sourceId,
    vehicleId,
    accountId,
    accountApplied,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.bookingDate == this.bookingDate &&
          other.budgetMonth == this.budgetMonth &&
          other.amount == this.amount &&
          other.isIncome == this.isIncome &&
          other.category == this.category &&
          other.merchant == this.merchant &&
          other.description == this.description &&
          other.paymentMethod == this.paymentMethod &&
          other.recurrenceId == this.recurrenceId &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.vehicleId == this.vehicleId &&
          other.accountId == this.accountId &&
          other.accountApplied == this.accountApplied &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> bookingDate;
  final Value<DateTime?> budgetMonth;
  final Value<double> amount;
  final Value<bool> isIncome;
  final Value<String> category;
  final Value<String> merchant;
  final Value<String> description;
  final Value<String> paymentMethod;
  final Value<String> recurrenceId;
  final Value<String> sourceType;
  final Value<String> sourceId;
  final Value<String> vehicleId;
  final Value<String> accountId;
  final Value<bool> accountApplied;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.bookingDate = const Value.absent(),
    this.budgetMonth = const Value.absent(),
    this.amount = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.category = const Value.absent(),
    this.merchant = const Value.absent(),
    this.description = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.recurrenceId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.accountApplied = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    required String id,
    required String userId,
    required DateTime bookingDate,
    this.budgetMonth = const Value.absent(),
    required double amount,
    this.isIncome = const Value.absent(),
    required String category,
    this.merchant = const Value.absent(),
    this.description = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.recurrenceId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.accountApplied = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       bookingDate = Value(bookingDate),
       amount = Value(amount),
       category = Value(category),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LedgerEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? bookingDate,
    Expression<DateTime>? budgetMonth,
    Expression<double>? amount,
    Expression<bool>? isIncome,
    Expression<String>? category,
    Expression<String>? merchant,
    Expression<String>? description,
    Expression<String>? paymentMethod,
    Expression<String>? recurrenceId,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? vehicleId,
    Expression<String>? accountId,
    Expression<bool>? accountApplied,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (bookingDate != null) 'booking_date': bookingDate,
      if (budgetMonth != null) 'budget_month': budgetMonth,
      if (amount != null) 'amount': amount,
      if (isIncome != null) 'is_income': isIncome,
      if (category != null) 'category': category,
      if (merchant != null) 'merchant': merchant,
      if (description != null) 'description': description,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (recurrenceId != null) 'recurrence_id': recurrenceId,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (accountId != null) 'account_id': accountId,
      if (accountApplied != null) 'account_applied': accountApplied,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<DateTime>? bookingDate,
    Value<DateTime?>? budgetMonth,
    Value<double>? amount,
    Value<bool>? isIncome,
    Value<String>? category,
    Value<String>? merchant,
    Value<String>? description,
    Value<String>? paymentMethod,
    Value<String>? recurrenceId,
    Value<String>? sourceType,
    Value<String>? sourceId,
    Value<String>? vehicleId,
    Value<String>? accountId,
    Value<bool>? accountApplied,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LedgerEntriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookingDate: bookingDate ?? this.bookingDate,
      budgetMonth: budgetMonth ?? this.budgetMonth,
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      category: category ?? this.category,
      merchant: merchant ?? this.merchant,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      recurrenceId: recurrenceId ?? this.recurrenceId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      vehicleId: vehicleId ?? this.vehicleId,
      accountId: accountId ?? this.accountId,
      accountApplied: accountApplied ?? this.accountApplied,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (bookingDate.present) {
      map['booking_date'] = Variable<DateTime>(bookingDate.value);
    }
    if (budgetMonth.present) {
      map['budget_month'] = Variable<DateTime>(budgetMonth.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (isIncome.present) {
      map['is_income'] = Variable<bool>(isIncome.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (recurrenceId.present) {
      map['recurrence_id'] = Variable<String>(recurrenceId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (accountApplied.present) {
      map['account_applied'] = Variable<bool>(accountApplied.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('bookingDate: $bookingDate, ')
          ..write('budgetMonth: $budgetMonth, ')
          ..write('amount: $amount, ')
          ..write('isIncome: $isIncome, ')
          ..write('category: $category, ')
          ..write('merchant: $merchant, ')
          ..write('description: $description, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('recurrenceId: $recurrenceId, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('accountId: $accountId, ')
          ..write('accountApplied: $accountApplied, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MasterDataTable extends MasterData
    with TableInfo<$MasterDataTable, MasterDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MasterDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    kind,
    value,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'master_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<MasterDataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, kind, value},
  ];
  @override
  MasterDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MasterDataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $MasterDataTable createAlias(String alias) {
    return $MasterDataTable(attachedDatabase, alias);
  }
}

class MasterDataData extends DataClass implements Insertable<MasterDataData> {
  final String id;
  final String userId;
  final String kind;
  final String value;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const MasterDataData({
    required this.id,
    required this.userId,
    required this.kind,
    required this.value,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['kind'] = Variable<String>(kind);
    map['value'] = Variable<String>(value);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  MasterDataCompanion toCompanion(bool nullToAbsent) {
    return MasterDataCompanion(
      id: Value(id),
      userId: Value(userId),
      kind: Value(kind),
      value: Value(value),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory MasterDataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MasterDataData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      kind: serializer.fromJson<String>(json['kind']),
      value: serializer.fromJson<String>(json['value']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'kind': serializer.toJson<String>(kind),
      'value': serializer.toJson<String>(value),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  MasterDataData copyWith({
    String? id,
    String? userId,
    String? kind,
    String? value,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => MasterDataData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    kind: kind ?? this.kind,
    value: value ?? this.value,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  MasterDataData copyWithCompanion(MasterDataCompanion data) {
    return MasterDataData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      kind: data.kind.present ? data.kind.value : this.kind,
      value: data.value.present ? data.value.value : this.value,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MasterDataData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, kind, value, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MasterDataData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.kind == this.kind &&
          other.value == this.value &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class MasterDataCompanion extends UpdateCompanion<MasterDataData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> kind;
  final Value<String> value;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const MasterDataCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.kind = const Value.absent(),
    this.value = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MasterDataCompanion.insert({
    required String id,
    required String userId,
    required String kind,
    required String value,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       kind = Value(kind),
       value = Value(value),
       createdAt = Value(createdAt);
  static Insertable<MasterDataData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? kind,
    Expression<String>? value,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (kind != null) 'kind': kind,
      if (value != null) 'value': value,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MasterDataCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? kind,
    Value<String>? value,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return MasterDataCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      kind: kind ?? this.kind,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MasterDataCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, AppReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ledgerEntryIdMeta = const VerificationMeta(
    'ledgerEntryId',
  );
  @override
  late final GeneratedColumn<String> ledgerEntryId = GeneratedColumn<String>(
    'ledger_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    scheduledAt,
    ledgerEntryId,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppReminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('ledger_entry_id')) {
      context.handle(
        _ledgerEntryIdMeta,
        ledgerEntryId.isAcceptableOrUnknown(
          data['ledger_entry_id']!,
          _ledgerEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppReminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      ledgerEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_entry_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class AppReminder extends DataClass implements Insertable<AppReminder> {
  final String id;
  final String userId;
  final String title;
  final DateTime scheduledAt;
  final String ledgerEntryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const AppReminder({
    required this.id,
    required this.userId,
    required this.title,
    required this.scheduledAt,
    required this.ledgerEntryId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['ledger_entry_id'] = Variable<String>(ledgerEntryId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      scheduledAt: Value(scheduledAt),
      ledgerEntryId: Value(ledgerEntryId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory AppReminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppReminder(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      ledgerEntryId: serializer.fromJson<String>(json['ledgerEntryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'ledgerEntryId': serializer.toJson<String>(ledgerEntryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  AppReminder copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? scheduledAt,
    String? ledgerEntryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => AppReminder(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    ledgerEntryId: ledgerEntryId ?? this.ledgerEntryId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  AppReminder copyWithCompanion(RemindersCompanion data) {
    return AppReminder(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      ledgerEntryId: data.ledgerEntryId.present
          ? data.ledgerEntryId.value
          : this.ledgerEntryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppReminder(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('ledgerEntryId: $ledgerEntryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    title,
    scheduledAt,
    ledgerEntryId,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppReminder &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.scheduledAt == this.scheduledAt &&
          other.ledgerEntryId == this.ledgerEntryId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class RemindersCompanion extends UpdateCompanion<AppReminder> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<DateTime> scheduledAt;
  final Value<String> ledgerEntryId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.ledgerEntryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String userId,
    required String title,
    required DateTime scheduledAt,
    this.ledgerEntryId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       scheduledAt = Value(scheduledAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AppReminder> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<DateTime>? scheduledAt,
    Expression<String>? ledgerEntryId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (ledgerEntryId != null) 'ledger_entry_id': ledgerEntryId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<DateTime>? scheduledAt,
    Value<String>? ledgerEntryId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      ledgerEntryId: ledgerEntryId ?? this.ledgerEntryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (ledgerEntryId.present) {
      map['ledger_entry_id'] = Variable<String>(ledgerEntryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('ledgerEntryId: $ledgerEntryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _vehicleTypeMeta = const VerificationMeta(
    'vehicleType',
  );
  @override
  late final GeneratedColumn<String> vehicleType = GeneratedColumn<String>(
    'vehicle_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _makeMeta = const VerificationMeta('make');
  @override
  late final GeneratedColumn<String> make = GeneratedColumn<String>(
    'make',
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
  static const VerificationMeta _licensePlateMeta = const VerificationMeta(
    'licensePlate',
  );
  @override
  late final GeneratedColumn<String> licensePlate = GeneratedColumn<String>(
    'license_plate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fuelTypeMeta = const VerificationMeta(
    'fuelType',
  );
  @override
  late final GeneratedColumn<String> fuelType = GeneratedColumn<String>(
    'fuel_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Benzin'),
  );
  static const VerificationMeta _tankCapacityMeta = const VerificationMeta(
    'tankCapacity',
  );
  @override
  late final GeneratedColumn<double> tankCapacity = GeneratedColumn<double>(
    'tank_capacity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentValueMeta = const VerificationMeta(
    'currentValue',
  );
  @override
  late final GeneratedColumn<double> currentValue = GeneratedColumn<double>(
    'current_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    vehicleType,
    make,
    model,
    licensePlate,
    year,
    fuelType,
    tankCapacity,
    purchasePrice,
    currentValue,
    purchaseDate,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vehicle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('vehicle_type')) {
      context.handle(
        _vehicleTypeMeta,
        vehicleType.isAcceptableOrUnknown(
          data['vehicle_type']!,
          _vehicleTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vehicleTypeMeta);
    }
    if (data.containsKey('make')) {
      context.handle(
        _makeMeta,
        make.isAcceptableOrUnknown(data['make']!, _makeMeta),
      );
    } else if (isInserting) {
      context.missing(_makeMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('license_plate')) {
      context.handle(
        _licensePlateMeta,
        licensePlate.isAcceptableOrUnknown(
          data['license_plate']!,
          _licensePlateMeta,
        ),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('fuel_type')) {
      context.handle(
        _fuelTypeMeta,
        fuelType.isAcceptableOrUnknown(data['fuel_type']!, _fuelTypeMeta),
      );
    }
    if (data.containsKey('tank_capacity')) {
      context.handle(
        _tankCapacityMeta,
        tankCapacity.isAcceptableOrUnknown(
          data['tank_capacity']!,
          _tankCapacityMeta,
        ),
      );
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    }
    if (data.containsKey('current_value')) {
      context.handle(
        _currentValueMeta,
        currentValue.isAcceptableOrUnknown(
          data['current_value']!,
          _currentValueMeta,
        ),
      );
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      vehicleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_type'],
      )!,
      make: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      licensePlate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_plate'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      fuelType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuel_type'],
      )!,
      tankCapacity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tank_capacity'],
      )!,
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      )!,
      currentValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_value'],
      )!,
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final String id;
  final String userId;
  final String vehicleType;
  final String make;
  final String model;
  final String licensePlate;
  final int year;
  final String fuelType;
  final double tankCapacity;
  final double purchasePrice;
  final double currentValue;
  final DateTime? purchaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Vehicle({
    required this.id,
    required this.userId,
    required this.vehicleType,
    required this.make,
    required this.model,
    required this.licensePlate,
    required this.year,
    required this.fuelType,
    required this.tankCapacity,
    required this.purchasePrice,
    required this.currentValue,
    this.purchaseDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['vehicle_type'] = Variable<String>(vehicleType);
    map['make'] = Variable<String>(make);
    map['model'] = Variable<String>(model);
    map['license_plate'] = Variable<String>(licensePlate);
    map['year'] = Variable<int>(year);
    map['fuel_type'] = Variable<String>(fuelType);
    map['tank_capacity'] = Variable<double>(tankCapacity);
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['current_value'] = Variable<double>(currentValue);
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      userId: Value(userId),
      vehicleType: Value(vehicleType),
      make: Value(make),
      model: Value(model),
      licensePlate: Value(licensePlate),
      year: Value(year),
      fuelType: Value(fuelType),
      tankCapacity: Value(tankCapacity),
      purchasePrice: Value(purchasePrice),
      currentValue: Value(currentValue),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Vehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      vehicleType: serializer.fromJson<String>(json['vehicleType']),
      make: serializer.fromJson<String>(json['make']),
      model: serializer.fromJson<String>(json['model']),
      licensePlate: serializer.fromJson<String>(json['licensePlate']),
      year: serializer.fromJson<int>(json['year']),
      fuelType: serializer.fromJson<String>(json['fuelType']),
      tankCapacity: serializer.fromJson<double>(json['tankCapacity']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      currentValue: serializer.fromJson<double>(json['currentValue']),
      purchaseDate: serializer.fromJson<DateTime?>(json['purchaseDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'vehicleType': serializer.toJson<String>(vehicleType),
      'make': serializer.toJson<String>(make),
      'model': serializer.toJson<String>(model),
      'licensePlate': serializer.toJson<String>(licensePlate),
      'year': serializer.toJson<int>(year),
      'fuelType': serializer.toJson<String>(fuelType),
      'tankCapacity': serializer.toJson<double>(tankCapacity),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'currentValue': serializer.toJson<double>(currentValue),
      'purchaseDate': serializer.toJson<DateTime?>(purchaseDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Vehicle copyWith({
    String? id,
    String? userId,
    String? vehicleType,
    String? make,
    String? model,
    String? licensePlate,
    int? year,
    String? fuelType,
    double? tankCapacity,
    double? purchasePrice,
    double? currentValue,
    Value<DateTime?> purchaseDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Vehicle(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    vehicleType: vehicleType ?? this.vehicleType,
    make: make ?? this.make,
    model: model ?? this.model,
    licensePlate: licensePlate ?? this.licensePlate,
    year: year ?? this.year,
    fuelType: fuelType ?? this.fuelType,
    tankCapacity: tankCapacity ?? this.tankCapacity,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    currentValue: currentValue ?? this.currentValue,
    purchaseDate: purchaseDate.present ? purchaseDate.value : this.purchaseDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      vehicleType: data.vehicleType.present
          ? data.vehicleType.value
          : this.vehicleType,
      make: data.make.present ? data.make.value : this.make,
      model: data.model.present ? data.model.value : this.model,
      licensePlate: data.licensePlate.present
          ? data.licensePlate.value
          : this.licensePlate,
      year: data.year.present ? data.year.value : this.year,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      tankCapacity: data.tankCapacity.present
          ? data.tankCapacity.value
          : this.tankCapacity,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('vehicleType: $vehicleType, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('year: $year, ')
          ..write('fuelType: $fuelType, ')
          ..write('tankCapacity: $tankCapacity, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('currentValue: $currentValue, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    vehicleType,
    make,
    model,
    licensePlate,
    year,
    fuelType,
    tankCapacity,
    purchasePrice,
    currentValue,
    purchaseDate,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.vehicleType == this.vehicleType &&
          other.make == this.make &&
          other.model == this.model &&
          other.licensePlate == this.licensePlate &&
          other.year == this.year &&
          other.fuelType == this.fuelType &&
          other.tankCapacity == this.tankCapacity &&
          other.purchasePrice == this.purchasePrice &&
          other.currentValue == this.currentValue &&
          other.purchaseDate == this.purchaseDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> vehicleType;
  final Value<String> make;
  final Value<String> model;
  final Value<String> licensePlate;
  final Value<int> year;
  final Value<String> fuelType;
  final Value<double> tankCapacity;
  final Value<double> purchasePrice;
  final Value<double> currentValue;
  final Value<DateTime?> purchaseDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.vehicleType = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.licensePlate = const Value.absent(),
    this.year = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.tankCapacity = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiclesCompanion.insert({
    required String id,
    required String userId,
    required String vehicleType,
    required String make,
    required String model,
    this.licensePlate = const Value.absent(),
    required int year,
    this.fuelType = const Value.absent(),
    this.tankCapacity = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       vehicleType = Value(vehicleType),
       make = Value(make),
       model = Value(model),
       year = Value(year),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Vehicle> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? vehicleType,
    Expression<String>? make,
    Expression<String>? model,
    Expression<String>? licensePlate,
    Expression<int>? year,
    Expression<String>? fuelType,
    Expression<double>? tankCapacity,
    Expression<double>? purchasePrice,
    Expression<double>? currentValue,
    Expression<DateTime>? purchaseDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (vehicleType != null) 'vehicle_type': vehicleType,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (licensePlate != null) 'license_plate': licensePlate,
      if (year != null) 'year': year,
      if (fuelType != null) 'fuel_type': fuelType,
      if (tankCapacity != null) 'tank_capacity': tankCapacity,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (currentValue != null) 'current_value': currentValue,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiclesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? vehicleType,
    Value<String>? make,
    Value<String>? model,
    Value<String>? licensePlate,
    Value<int>? year,
    Value<String>? fuelType,
    Value<double>? tankCapacity,
    Value<double>? purchasePrice,
    Value<double>? currentValue,
    Value<DateTime?>? purchaseDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleType: vehicleType ?? this.vehicleType,
      make: make ?? this.make,
      model: model ?? this.model,
      licensePlate: licensePlate ?? this.licensePlate,
      year: year ?? this.year,
      fuelType: fuelType ?? this.fuelType,
      tankCapacity: tankCapacity ?? this.tankCapacity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentValue: currentValue ?? this.currentValue,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (vehicleType.present) {
      map['vehicle_type'] = Variable<String>(vehicleType.value);
    }
    if (make.present) {
      map['make'] = Variable<String>(make.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (licensePlate.present) {
      map['license_plate'] = Variable<String>(licensePlate.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(fuelType.value);
    }
    if (tankCapacity.present) {
      map['tank_capacity'] = Variable<double>(tankCapacity.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<double>(currentValue.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('vehicleType: $vehicleType, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('year: $year, ')
          ..write('fuelType: $fuelType, ')
          ..write('tankCapacity: $tankCapacity, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('currentValue: $currentValue, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehicleCostsTable extends VehicleCosts
    with TableInfo<$VehicleCostsTable, VehicleCost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehicleCostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _bookingDateMeta = const VerificationMeta(
    'bookingDate',
  );
  @override
  late final GeneratedColumn<DateTime> bookingDate = GeneratedColumn<DateTime>(
    'booking_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerMeta = const VerificationMeta(
    'odometer',
  );
  @override
  late final GeneratedColumn<double> odometer = GeneratedColumn<double>(
    'odometer',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    vehicleId,
    bookingDate,
    category,
    amount,
    odometer,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicle_costs';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleCost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('booking_date')) {
      context.handle(
        _bookingDateMeta,
        bookingDate.isAcceptableOrUnknown(
          data['booking_date']!,
          _bookingDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bookingDateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('odometer')) {
      context.handle(
        _odometerMeta,
        odometer.isAcceptableOrUnknown(data['odometer']!, _odometerMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleCost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleCost(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      bookingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}booking_date'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      odometer: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}odometer'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $VehicleCostsTable createAlias(String alias) {
    return $VehicleCostsTable(attachedDatabase, alias);
  }
}

class VehicleCost extends DataClass implements Insertable<VehicleCost> {
  final String id;
  final String userId;
  final String vehicleId;
  final DateTime bookingDate;
  final String category;
  final double amount;
  final double? odometer;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const VehicleCost({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.bookingDate,
    required this.category,
    required this.amount,
    this.odometer,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['booking_date'] = Variable<DateTime>(bookingDate);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || odometer != null) {
      map['odometer'] = Variable<double>(odometer);
    }
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  VehicleCostsCompanion toCompanion(bool nullToAbsent) {
    return VehicleCostsCompanion(
      id: Value(id),
      userId: Value(userId),
      vehicleId: Value(vehicleId),
      bookingDate: Value(bookingDate),
      category: Value(category),
      amount: Value(amount),
      odometer: odometer == null && nullToAbsent
          ? const Value.absent()
          : Value(odometer),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory VehicleCost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleCost(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      bookingDate: serializer.fromJson<DateTime>(json['bookingDate']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      odometer: serializer.fromJson<double?>(json['odometer']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'bookingDate': serializer.toJson<DateTime>(bookingDate),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'odometer': serializer.toJson<double?>(odometer),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  VehicleCost copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    DateTime? bookingDate,
    String? category,
    double? amount,
    Value<double?> odometer = const Value.absent(),
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => VehicleCost(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    vehicleId: vehicleId ?? this.vehicleId,
    bookingDate: bookingDate ?? this.bookingDate,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    odometer: odometer.present ? odometer.value : this.odometer,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  VehicleCost copyWithCompanion(VehicleCostsCompanion data) {
    return VehicleCost(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      bookingDate: data.bookingDate.present
          ? data.bookingDate.value
          : this.bookingDate,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      odometer: data.odometer.present ? data.odometer.value : this.odometer,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleCost(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('bookingDate: $bookingDate, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('odometer: $odometer, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    vehicleId,
    bookingDate,
    category,
    amount,
    odometer,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleCost &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.vehicleId == this.vehicleId &&
          other.bookingDate == this.bookingDate &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.odometer == this.odometer &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class VehicleCostsCompanion extends UpdateCompanion<VehicleCost> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> vehicleId;
  final Value<DateTime> bookingDate;
  final Value<String> category;
  final Value<double> amount;
  final Value<double?> odometer;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const VehicleCostsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.bookingDate = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.odometer = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehicleCostsCompanion.insert({
    required String id,
    required String userId,
    required String vehicleId,
    required DateTime bookingDate,
    required String category,
    required double amount,
    this.odometer = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       vehicleId = Value(vehicleId),
       bookingDate = Value(bookingDate),
       category = Value(category),
       amount = Value(amount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<VehicleCost> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? vehicleId,
    Expression<DateTime>? bookingDate,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<double>? odometer,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (bookingDate != null) 'booking_date': bookingDate,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (odometer != null) 'odometer': odometer,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehicleCostsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? vehicleId,
    Value<DateTime>? bookingDate,
    Value<String>? category,
    Value<double>? amount,
    Value<double?>? odometer,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return VehicleCostsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      bookingDate: bookingDate ?? this.bookingDate,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      odometer: odometer ?? this.odometer,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (bookingDate.present) {
      map['booking_date'] = Variable<DateTime>(bookingDate.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (odometer.present) {
      map['odometer'] = Variable<double>(odometer.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehicleCostsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('bookingDate: $bookingDate, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('odometer: $odometer, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTable extends UserPreferences
    with TableInfo<$UserPreferencesTable, UserPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('dark'),
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('de'),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _dateFormatMeta = const VerificationMeta(
    'dateFormat',
  );
  @override
  late final GeneratedColumn<String> dateFormat = GeneratedColumn<String>(
    'date_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('dd.MM.yyyy'),
  );
  static const VerificationMeta _serverModeMeta = const VerificationMeta(
    'serverMode',
  );
  @override
  late final GeneratedColumn<bool> serverMode = GeneratedColumn<bool>(
    'server_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("server_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _serverUrlMeta = const VerificationMeta(
    'serverUrl',
  );
  @override
  late final GeneratedColumn<String> serverUrl = GeneratedColumn<String>(
    'server_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _serverPortMeta = const VerificationMeta(
    'serverPort',
  );
  @override
  late final GeneratedColumn<int> serverPort = GeneratedColumn<int>(
    'server_port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(443),
  );
  static const VerificationMeta _serverUsernameMeta = const VerificationMeta(
    'serverUsername',
  );
  @override
  late final GeneratedColumn<String> serverUsername = GeneratedColumn<String>(
    'server_username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _selectedHouseholdAccountIdMeta =
      const VerificationMeta('selectedHouseholdAccountId');
  @override
  late final GeneratedColumn<String> selectedHouseholdAccountId =
      GeneratedColumn<String>(
        'selected_household_account_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _selectedPortfolioAccountIdMeta =
      const VerificationMeta('selectedPortfolioAccountId');
  @override
  late final GeneratedColumn<String> selectedPortfolioAccountId =
      GeneratedColumn<String>(
        'selected_portfolio_account_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _taxAllowanceMeta = const VerificationMeta(
    'taxAllowance',
  );
  @override
  late final GeneratedColumn<double> taxAllowance = GeneratedColumn<double>(
    'tax_allowance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1000),
  );
  static const VerificationMeta _defaultInvestmentFeeMeta =
      const VerificationMeta('defaultInvestmentFee');
  @override
  late final GeneratedColumn<double> defaultInvestmentFee =
      GeneratedColumn<double>(
        'default_investment_fee',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _includePhysicalAssetsInTaxAllowanceMeta =
      const VerificationMeta('includePhysicalAssetsInTaxAllowance');
  @override
  late final GeneratedColumn<bool> includePhysicalAssetsInTaxAllowance =
      GeneratedColumn<bool>(
        'include_physical_assets_in_tax_allowance',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("include_physical_assets_in_tax_allowance" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _dataFilePathMeta = const VerificationMeta(
    'dataFilePath',
  );
  @override
  late final GeneratedColumn<String> dataFilePath = GeneratedColumn<String>(
    'data_file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _freedomAgeMeta = const VerificationMeta(
    'freedomAge',
  );
  @override
  late final GeneratedColumn<double> freedomAge = GeneratedColumn<double>(
    'freedom_age',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(35),
  );
  static const VerificationMeta _freedomStartCapitalMeta =
      const VerificationMeta('freedomStartCapital');
  @override
  late final GeneratedColumn<double> freedomStartCapital =
      GeneratedColumn<double>(
        'freedom_start_capital',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(50000),
      );
  static const VerificationMeta _freedomUsePortfolioMeta =
      const VerificationMeta('freedomUsePortfolio');
  @override
  late final GeneratedColumn<bool> freedomUsePortfolio = GeneratedColumn<bool>(
    'freedom_use_portfolio',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("freedom_use_portfolio" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    themeMode,
    locale,
    currency,
    dateFormat,
    serverMode,
    serverUrl,
    serverPort,
    serverUsername,
    selectedHouseholdAccountId,
    selectedPortfolioAccountId,
    taxAllowance,
    defaultInvestmentFee,
    includePhysicalAssetsInTaxAllowance,
    dataFilePath,
    freedomAge,
    freedomStartCapital,
    freedomUsePortfolio,
    lastSyncAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('date_format')) {
      context.handle(
        _dateFormatMeta,
        dateFormat.isAcceptableOrUnknown(data['date_format']!, _dateFormatMeta),
      );
    }
    if (data.containsKey('server_mode')) {
      context.handle(
        _serverModeMeta,
        serverMode.isAcceptableOrUnknown(data['server_mode']!, _serverModeMeta),
      );
    }
    if (data.containsKey('server_url')) {
      context.handle(
        _serverUrlMeta,
        serverUrl.isAcceptableOrUnknown(data['server_url']!, _serverUrlMeta),
      );
    }
    if (data.containsKey('server_port')) {
      context.handle(
        _serverPortMeta,
        serverPort.isAcceptableOrUnknown(data['server_port']!, _serverPortMeta),
      );
    }
    if (data.containsKey('server_username')) {
      context.handle(
        _serverUsernameMeta,
        serverUsername.isAcceptableOrUnknown(
          data['server_username']!,
          _serverUsernameMeta,
        ),
      );
    }
    if (data.containsKey('selected_household_account_id')) {
      context.handle(
        _selectedHouseholdAccountIdMeta,
        selectedHouseholdAccountId.isAcceptableOrUnknown(
          data['selected_household_account_id']!,
          _selectedHouseholdAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('selected_portfolio_account_id')) {
      context.handle(
        _selectedPortfolioAccountIdMeta,
        selectedPortfolioAccountId.isAcceptableOrUnknown(
          data['selected_portfolio_account_id']!,
          _selectedPortfolioAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('tax_allowance')) {
      context.handle(
        _taxAllowanceMeta,
        taxAllowance.isAcceptableOrUnknown(
          data['tax_allowance']!,
          _taxAllowanceMeta,
        ),
      );
    }
    if (data.containsKey('default_investment_fee')) {
      context.handle(
        _defaultInvestmentFeeMeta,
        defaultInvestmentFee.isAcceptableOrUnknown(
          data['default_investment_fee']!,
          _defaultInvestmentFeeMeta,
        ),
      );
    }
    if (data.containsKey('include_physical_assets_in_tax_allowance')) {
      context.handle(
        _includePhysicalAssetsInTaxAllowanceMeta,
        includePhysicalAssetsInTaxAllowance.isAcceptableOrUnknown(
          data['include_physical_assets_in_tax_allowance']!,
          _includePhysicalAssetsInTaxAllowanceMeta,
        ),
      );
    }
    if (data.containsKey('data_file_path')) {
      context.handle(
        _dataFilePathMeta,
        dataFilePath.isAcceptableOrUnknown(
          data['data_file_path']!,
          _dataFilePathMeta,
        ),
      );
    }
    if (data.containsKey('freedom_age')) {
      context.handle(
        _freedomAgeMeta,
        freedomAge.isAcceptableOrUnknown(data['freedom_age']!, _freedomAgeMeta),
      );
    }
    if (data.containsKey('freedom_start_capital')) {
      context.handle(
        _freedomStartCapitalMeta,
        freedomStartCapital.isAcceptableOrUnknown(
          data['freedom_start_capital']!,
          _freedomStartCapitalMeta,
        ),
      );
    }
    if (data.containsKey('freedom_use_portfolio')) {
      context.handle(
        _freedomUsePortfolioMeta,
        freedomUsePortfolio.isAcceptableOrUnknown(
          data['freedom_use_portfolio']!,
          _freedomUsePortfolioMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreference(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      dateFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_format'],
      )!,
      serverMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}server_mode'],
      )!,
      serverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_url'],
      )!,
      serverPort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_port'],
      )!,
      serverUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_username'],
      )!,
      selectedHouseholdAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_household_account_id'],
      )!,
      selectedPortfolioAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_portfolio_account_id'],
      )!,
      taxAllowance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_allowance'],
      )!,
      defaultInvestmentFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_investment_fee'],
      )!,
      includePhysicalAssetsInTaxAllowance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_physical_assets_in_tax_allowance'],
      )!,
      dataFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_file_path'],
      )!,
      freedomAge: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}freedom_age'],
      )!,
      freedomStartCapital: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}freedom_start_capital'],
      )!,
      freedomUsePortfolio: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}freedom_use_portfolio'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserPreferencesTable createAlias(String alias) {
    return $UserPreferencesTable(attachedDatabase, alias);
  }
}

class UserPreference extends DataClass implements Insertable<UserPreference> {
  final String userId;
  final String themeMode;
  final String locale;
  final String currency;
  final String dateFormat;
  final bool serverMode;
  final String serverUrl;
  final int serverPort;
  final String serverUsername;
  final String selectedHouseholdAccountId;
  final String selectedPortfolioAccountId;
  final double taxAllowance;
  final double defaultInvestmentFee;
  final bool includePhysicalAssetsInTaxAllowance;
  final String dataFilePath;
  final double freedomAge;
  final double freedomStartCapital;
  final bool freedomUsePortfolio;
  final DateTime? lastSyncAt;
  final DateTime updatedAt;
  const UserPreference({
    required this.userId,
    required this.themeMode,
    required this.locale,
    required this.currency,
    required this.dateFormat,
    required this.serverMode,
    required this.serverUrl,
    required this.serverPort,
    required this.serverUsername,
    required this.selectedHouseholdAccountId,
    required this.selectedPortfolioAccountId,
    required this.taxAllowance,
    required this.defaultInvestmentFee,
    required this.includePhysicalAssetsInTaxAllowance,
    required this.dataFilePath,
    required this.freedomAge,
    required this.freedomStartCapital,
    required this.freedomUsePortfolio,
    this.lastSyncAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['theme_mode'] = Variable<String>(themeMode);
    map['locale'] = Variable<String>(locale);
    map['currency'] = Variable<String>(currency);
    map['date_format'] = Variable<String>(dateFormat);
    map['server_mode'] = Variable<bool>(serverMode);
    map['server_url'] = Variable<String>(serverUrl);
    map['server_port'] = Variable<int>(serverPort);
    map['server_username'] = Variable<String>(serverUsername);
    map['selected_household_account_id'] = Variable<String>(
      selectedHouseholdAccountId,
    );
    map['selected_portfolio_account_id'] = Variable<String>(
      selectedPortfolioAccountId,
    );
    map['tax_allowance'] = Variable<double>(taxAllowance);
    map['default_investment_fee'] = Variable<double>(defaultInvestmentFee);
    map['include_physical_assets_in_tax_allowance'] = Variable<bool>(
      includePhysicalAssetsInTaxAllowance,
    );
    map['data_file_path'] = Variable<String>(dataFilePath);
    map['freedom_age'] = Variable<double>(freedomAge);
    map['freedom_start_capital'] = Variable<double>(freedomStartCapital);
    map['freedom_use_portfolio'] = Variable<bool>(freedomUsePortfolio);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesCompanion(
      userId: Value(userId),
      themeMode: Value(themeMode),
      locale: Value(locale),
      currency: Value(currency),
      dateFormat: Value(dateFormat),
      serverMode: Value(serverMode),
      serverUrl: Value(serverUrl),
      serverPort: Value(serverPort),
      serverUsername: Value(serverUsername),
      selectedHouseholdAccountId: Value(selectedHouseholdAccountId),
      selectedPortfolioAccountId: Value(selectedPortfolioAccountId),
      taxAllowance: Value(taxAllowance),
      defaultInvestmentFee: Value(defaultInvestmentFee),
      includePhysicalAssetsInTaxAllowance: Value(
        includePhysicalAssetsInTaxAllowance,
      ),
      dataFilePath: Value(dataFilePath),
      freedomAge: Value(freedomAge),
      freedomStartCapital: Value(freedomStartCapital),
      freedomUsePortfolio: Value(freedomUsePortfolio),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreference(
      userId: serializer.fromJson<String>(json['userId']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      locale: serializer.fromJson<String>(json['locale']),
      currency: serializer.fromJson<String>(json['currency']),
      dateFormat: serializer.fromJson<String>(json['dateFormat']),
      serverMode: serializer.fromJson<bool>(json['serverMode']),
      serverUrl: serializer.fromJson<String>(json['serverUrl']),
      serverPort: serializer.fromJson<int>(json['serverPort']),
      serverUsername: serializer.fromJson<String>(json['serverUsername']),
      selectedHouseholdAccountId: serializer.fromJson<String>(
        json['selectedHouseholdAccountId'],
      ),
      selectedPortfolioAccountId: serializer.fromJson<String>(
        json['selectedPortfolioAccountId'],
      ),
      taxAllowance: serializer.fromJson<double>(json['taxAllowance']),
      defaultInvestmentFee: serializer.fromJson<double>(
        json['defaultInvestmentFee'],
      ),
      includePhysicalAssetsInTaxAllowance: serializer.fromJson<bool>(
        json['includePhysicalAssetsInTaxAllowance'],
      ),
      dataFilePath: serializer.fromJson<String>(json['dataFilePath']),
      freedomAge: serializer.fromJson<double>(json['freedomAge']),
      freedomStartCapital: serializer.fromJson<double>(
        json['freedomStartCapital'],
      ),
      freedomUsePortfolio: serializer.fromJson<bool>(
        json['freedomUsePortfolio'],
      ),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'themeMode': serializer.toJson<String>(themeMode),
      'locale': serializer.toJson<String>(locale),
      'currency': serializer.toJson<String>(currency),
      'dateFormat': serializer.toJson<String>(dateFormat),
      'serverMode': serializer.toJson<bool>(serverMode),
      'serverUrl': serializer.toJson<String>(serverUrl),
      'serverPort': serializer.toJson<int>(serverPort),
      'serverUsername': serializer.toJson<String>(serverUsername),
      'selectedHouseholdAccountId': serializer.toJson<String>(
        selectedHouseholdAccountId,
      ),
      'selectedPortfolioAccountId': serializer.toJson<String>(
        selectedPortfolioAccountId,
      ),
      'taxAllowance': serializer.toJson<double>(taxAllowance),
      'defaultInvestmentFee': serializer.toJson<double>(defaultInvestmentFee),
      'includePhysicalAssetsInTaxAllowance': serializer.toJson<bool>(
        includePhysicalAssetsInTaxAllowance,
      ),
      'dataFilePath': serializer.toJson<String>(dataFilePath),
      'freedomAge': serializer.toJson<double>(freedomAge),
      'freedomStartCapital': serializer.toJson<double>(freedomStartCapital),
      'freedomUsePortfolio': serializer.toJson<bool>(freedomUsePortfolio),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserPreference copyWith({
    String? userId,
    String? themeMode,
    String? locale,
    String? currency,
    String? dateFormat,
    bool? serverMode,
    String? serverUrl,
    int? serverPort,
    String? serverUsername,
    String? selectedHouseholdAccountId,
    String? selectedPortfolioAccountId,
    double? taxAllowance,
    double? defaultInvestmentFee,
    bool? includePhysicalAssetsInTaxAllowance,
    String? dataFilePath,
    double? freedomAge,
    double? freedomStartCapital,
    bool? freedomUsePortfolio,
    Value<DateTime?> lastSyncAt = const Value.absent(),
    DateTime? updatedAt,
  }) => UserPreference(
    userId: userId ?? this.userId,
    themeMode: themeMode ?? this.themeMode,
    locale: locale ?? this.locale,
    currency: currency ?? this.currency,
    dateFormat: dateFormat ?? this.dateFormat,
    serverMode: serverMode ?? this.serverMode,
    serverUrl: serverUrl ?? this.serverUrl,
    serverPort: serverPort ?? this.serverPort,
    serverUsername: serverUsername ?? this.serverUsername,
    selectedHouseholdAccountId:
        selectedHouseholdAccountId ?? this.selectedHouseholdAccountId,
    selectedPortfolioAccountId:
        selectedPortfolioAccountId ?? this.selectedPortfolioAccountId,
    taxAllowance: taxAllowance ?? this.taxAllowance,
    defaultInvestmentFee: defaultInvestmentFee ?? this.defaultInvestmentFee,
    includePhysicalAssetsInTaxAllowance:
        includePhysicalAssetsInTaxAllowance ??
        this.includePhysicalAssetsInTaxAllowance,
    dataFilePath: dataFilePath ?? this.dataFilePath,
    freedomAge: freedomAge ?? this.freedomAge,
    freedomStartCapital: freedomStartCapital ?? this.freedomStartCapital,
    freedomUsePortfolio: freedomUsePortfolio ?? this.freedomUsePortfolio,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserPreference copyWithCompanion(UserPreferencesCompanion data) {
    return UserPreference(
      userId: data.userId.present ? data.userId.value : this.userId,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      locale: data.locale.present ? data.locale.value : this.locale,
      currency: data.currency.present ? data.currency.value : this.currency,
      dateFormat: data.dateFormat.present
          ? data.dateFormat.value
          : this.dateFormat,
      serverMode: data.serverMode.present
          ? data.serverMode.value
          : this.serverMode,
      serverUrl: data.serverUrl.present ? data.serverUrl.value : this.serverUrl,
      serverPort: data.serverPort.present
          ? data.serverPort.value
          : this.serverPort,
      serverUsername: data.serverUsername.present
          ? data.serverUsername.value
          : this.serverUsername,
      selectedHouseholdAccountId: data.selectedHouseholdAccountId.present
          ? data.selectedHouseholdAccountId.value
          : this.selectedHouseholdAccountId,
      selectedPortfolioAccountId: data.selectedPortfolioAccountId.present
          ? data.selectedPortfolioAccountId.value
          : this.selectedPortfolioAccountId,
      taxAllowance: data.taxAllowance.present
          ? data.taxAllowance.value
          : this.taxAllowance,
      defaultInvestmentFee: data.defaultInvestmentFee.present
          ? data.defaultInvestmentFee.value
          : this.defaultInvestmentFee,
      includePhysicalAssetsInTaxAllowance:
          data.includePhysicalAssetsInTaxAllowance.present
          ? data.includePhysicalAssetsInTaxAllowance.value
          : this.includePhysicalAssetsInTaxAllowance,
      dataFilePath: data.dataFilePath.present
          ? data.dataFilePath.value
          : this.dataFilePath,
      freedomAge: data.freedomAge.present
          ? data.freedomAge.value
          : this.freedomAge,
      freedomStartCapital: data.freedomStartCapital.present
          ? data.freedomStartCapital.value
          : this.freedomStartCapital,
      freedomUsePortfolio: data.freedomUsePortfolio.present
          ? data.freedomUsePortfolio.value
          : this.freedomUsePortfolio,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreference(')
          ..write('userId: $userId, ')
          ..write('themeMode: $themeMode, ')
          ..write('locale: $locale, ')
          ..write('currency: $currency, ')
          ..write('dateFormat: $dateFormat, ')
          ..write('serverMode: $serverMode, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('serverPort: $serverPort, ')
          ..write('serverUsername: $serverUsername, ')
          ..write('selectedHouseholdAccountId: $selectedHouseholdAccountId, ')
          ..write('selectedPortfolioAccountId: $selectedPortfolioAccountId, ')
          ..write('taxAllowance: $taxAllowance, ')
          ..write('defaultInvestmentFee: $defaultInvestmentFee, ')
          ..write(
            'includePhysicalAssetsInTaxAllowance: $includePhysicalAssetsInTaxAllowance, ',
          )
          ..write('dataFilePath: $dataFilePath, ')
          ..write('freedomAge: $freedomAge, ')
          ..write('freedomStartCapital: $freedomStartCapital, ')
          ..write('freedomUsePortfolio: $freedomUsePortfolio, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    themeMode,
    locale,
    currency,
    dateFormat,
    serverMode,
    serverUrl,
    serverPort,
    serverUsername,
    selectedHouseholdAccountId,
    selectedPortfolioAccountId,
    taxAllowance,
    defaultInvestmentFee,
    includePhysicalAssetsInTaxAllowance,
    dataFilePath,
    freedomAge,
    freedomStartCapital,
    freedomUsePortfolio,
    lastSyncAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreference &&
          other.userId == this.userId &&
          other.themeMode == this.themeMode &&
          other.locale == this.locale &&
          other.currency == this.currency &&
          other.dateFormat == this.dateFormat &&
          other.serverMode == this.serverMode &&
          other.serverUrl == this.serverUrl &&
          other.serverPort == this.serverPort &&
          other.serverUsername == this.serverUsername &&
          other.selectedHouseholdAccountId == this.selectedHouseholdAccountId &&
          other.selectedPortfolioAccountId == this.selectedPortfolioAccountId &&
          other.taxAllowance == this.taxAllowance &&
          other.defaultInvestmentFee == this.defaultInvestmentFee &&
          other.includePhysicalAssetsInTaxAllowance ==
              this.includePhysicalAssetsInTaxAllowance &&
          other.dataFilePath == this.dataFilePath &&
          other.freedomAge == this.freedomAge &&
          other.freedomStartCapital == this.freedomStartCapital &&
          other.freedomUsePortfolio == this.freedomUsePortfolio &&
          other.lastSyncAt == this.lastSyncAt &&
          other.updatedAt == this.updatedAt);
}

class UserPreferencesCompanion extends UpdateCompanion<UserPreference> {
  final Value<String> userId;
  final Value<String> themeMode;
  final Value<String> locale;
  final Value<String> currency;
  final Value<String> dateFormat;
  final Value<bool> serverMode;
  final Value<String> serverUrl;
  final Value<int> serverPort;
  final Value<String> serverUsername;
  final Value<String> selectedHouseholdAccountId;
  final Value<String> selectedPortfolioAccountId;
  final Value<double> taxAllowance;
  final Value<double> defaultInvestmentFee;
  final Value<bool> includePhysicalAssetsInTaxAllowance;
  final Value<String> dataFilePath;
  final Value<double> freedomAge;
  final Value<double> freedomStartCapital;
  final Value<bool> freedomUsePortfolio;
  final Value<DateTime?> lastSyncAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserPreferencesCompanion({
    this.userId = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.locale = const Value.absent(),
    this.currency = const Value.absent(),
    this.dateFormat = const Value.absent(),
    this.serverMode = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.serverPort = const Value.absent(),
    this.serverUsername = const Value.absent(),
    this.selectedHouseholdAccountId = const Value.absent(),
    this.selectedPortfolioAccountId = const Value.absent(),
    this.taxAllowance = const Value.absent(),
    this.defaultInvestmentFee = const Value.absent(),
    this.includePhysicalAssetsInTaxAllowance = const Value.absent(),
    this.dataFilePath = const Value.absent(),
    this.freedomAge = const Value.absent(),
    this.freedomStartCapital = const Value.absent(),
    this.freedomUsePortfolio = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPreferencesCompanion.insert({
    required String userId,
    this.themeMode = const Value.absent(),
    this.locale = const Value.absent(),
    this.currency = const Value.absent(),
    this.dateFormat = const Value.absent(),
    this.serverMode = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.serverPort = const Value.absent(),
    this.serverUsername = const Value.absent(),
    this.selectedHouseholdAccountId = const Value.absent(),
    this.selectedPortfolioAccountId = const Value.absent(),
    this.taxAllowance = const Value.absent(),
    this.defaultInvestmentFee = const Value.absent(),
    this.includePhysicalAssetsInTaxAllowance = const Value.absent(),
    this.dataFilePath = const Value.absent(),
    this.freedomAge = const Value.absent(),
    this.freedomStartCapital = const Value.absent(),
    this.freedomUsePortfolio = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       updatedAt = Value(updatedAt);
  static Insertable<UserPreference> custom({
    Expression<String>? userId,
    Expression<String>? themeMode,
    Expression<String>? locale,
    Expression<String>? currency,
    Expression<String>? dateFormat,
    Expression<bool>? serverMode,
    Expression<String>? serverUrl,
    Expression<int>? serverPort,
    Expression<String>? serverUsername,
    Expression<String>? selectedHouseholdAccountId,
    Expression<String>? selectedPortfolioAccountId,
    Expression<double>? taxAllowance,
    Expression<double>? defaultInvestmentFee,
    Expression<bool>? includePhysicalAssetsInTaxAllowance,
    Expression<String>? dataFilePath,
    Expression<double>? freedomAge,
    Expression<double>? freedomStartCapital,
    Expression<bool>? freedomUsePortfolio,
    Expression<DateTime>? lastSyncAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (themeMode != null) 'theme_mode': themeMode,
      if (locale != null) 'locale': locale,
      if (currency != null) 'currency': currency,
      if (dateFormat != null) 'date_format': dateFormat,
      if (serverMode != null) 'server_mode': serverMode,
      if (serverUrl != null) 'server_url': serverUrl,
      if (serverPort != null) 'server_port': serverPort,
      if (serverUsername != null) 'server_username': serverUsername,
      if (selectedHouseholdAccountId != null)
        'selected_household_account_id': selectedHouseholdAccountId,
      if (selectedPortfolioAccountId != null)
        'selected_portfolio_account_id': selectedPortfolioAccountId,
      if (taxAllowance != null) 'tax_allowance': taxAllowance,
      if (defaultInvestmentFee != null)
        'default_investment_fee': defaultInvestmentFee,
      if (includePhysicalAssetsInTaxAllowance != null)
        'include_physical_assets_in_tax_allowance':
            includePhysicalAssetsInTaxAllowance,
      if (dataFilePath != null) 'data_file_path': dataFilePath,
      if (freedomAge != null) 'freedom_age': freedomAge,
      if (freedomStartCapital != null)
        'freedom_start_capital': freedomStartCapital,
      if (freedomUsePortfolio != null)
        'freedom_use_portfolio': freedomUsePortfolio,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPreferencesCompanion copyWith({
    Value<String>? userId,
    Value<String>? themeMode,
    Value<String>? locale,
    Value<String>? currency,
    Value<String>? dateFormat,
    Value<bool>? serverMode,
    Value<String>? serverUrl,
    Value<int>? serverPort,
    Value<String>? serverUsername,
    Value<String>? selectedHouseholdAccountId,
    Value<String>? selectedPortfolioAccountId,
    Value<double>? taxAllowance,
    Value<double>? defaultInvestmentFee,
    Value<bool>? includePhysicalAssetsInTaxAllowance,
    Value<String>? dataFilePath,
    Value<double>? freedomAge,
    Value<double>? freedomStartCapital,
    Value<bool>? freedomUsePortfolio,
    Value<DateTime?>? lastSyncAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserPreferencesCompanion(
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      serverMode: serverMode ?? this.serverMode,
      serverUrl: serverUrl ?? this.serverUrl,
      serverPort: serverPort ?? this.serverPort,
      serverUsername: serverUsername ?? this.serverUsername,
      selectedHouseholdAccountId:
          selectedHouseholdAccountId ?? this.selectedHouseholdAccountId,
      selectedPortfolioAccountId:
          selectedPortfolioAccountId ?? this.selectedPortfolioAccountId,
      taxAllowance: taxAllowance ?? this.taxAllowance,
      defaultInvestmentFee: defaultInvestmentFee ?? this.defaultInvestmentFee,
      includePhysicalAssetsInTaxAllowance:
          includePhysicalAssetsInTaxAllowance ??
          this.includePhysicalAssetsInTaxAllowance,
      dataFilePath: dataFilePath ?? this.dataFilePath,
      freedomAge: freedomAge ?? this.freedomAge,
      freedomStartCapital: freedomStartCapital ?? this.freedomStartCapital,
      freedomUsePortfolio: freedomUsePortfolio ?? this.freedomUsePortfolio,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (dateFormat.present) {
      map['date_format'] = Variable<String>(dateFormat.value);
    }
    if (serverMode.present) {
      map['server_mode'] = Variable<bool>(serverMode.value);
    }
    if (serverUrl.present) {
      map['server_url'] = Variable<String>(serverUrl.value);
    }
    if (serverPort.present) {
      map['server_port'] = Variable<int>(serverPort.value);
    }
    if (serverUsername.present) {
      map['server_username'] = Variable<String>(serverUsername.value);
    }
    if (selectedHouseholdAccountId.present) {
      map['selected_household_account_id'] = Variable<String>(
        selectedHouseholdAccountId.value,
      );
    }
    if (selectedPortfolioAccountId.present) {
      map['selected_portfolio_account_id'] = Variable<String>(
        selectedPortfolioAccountId.value,
      );
    }
    if (taxAllowance.present) {
      map['tax_allowance'] = Variable<double>(taxAllowance.value);
    }
    if (defaultInvestmentFee.present) {
      map['default_investment_fee'] = Variable<double>(
        defaultInvestmentFee.value,
      );
    }
    if (includePhysicalAssetsInTaxAllowance.present) {
      map['include_physical_assets_in_tax_allowance'] = Variable<bool>(
        includePhysicalAssetsInTaxAllowance.value,
      );
    }
    if (dataFilePath.present) {
      map['data_file_path'] = Variable<String>(dataFilePath.value);
    }
    if (freedomAge.present) {
      map['freedom_age'] = Variable<double>(freedomAge.value);
    }
    if (freedomStartCapital.present) {
      map['freedom_start_capital'] = Variable<double>(
        freedomStartCapital.value,
      );
    }
    if (freedomUsePortfolio.present) {
      map['freedom_use_portfolio'] = Variable<bool>(freedomUsePortfolio.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesCompanion(')
          ..write('userId: $userId, ')
          ..write('themeMode: $themeMode, ')
          ..write('locale: $locale, ')
          ..write('currency: $currency, ')
          ..write('dateFormat: $dateFormat, ')
          ..write('serverMode: $serverMode, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('serverPort: $serverPort, ')
          ..write('serverUsername: $serverUsername, ')
          ..write('selectedHouseholdAccountId: $selectedHouseholdAccountId, ')
          ..write('selectedPortfolioAccountId: $selectedPortfolioAccountId, ')
          ..write('taxAllowance: $taxAllowance, ')
          ..write('defaultInvestmentFee: $defaultInvestmentFee, ')
          ..write(
            'includePhysicalAssetsInTaxAllowance: $includePhysicalAssetsInTaxAllowance, ',
          )
          ..write('dataFilePath: $dataFilePath, ')
          ..write('freedomAge: $freedomAge, ')
          ..write('freedomStartCapital: $freedomStartCapital, ')
          ..write('freedomUsePortfolio: $freedomUsePortfolio, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NetWorthSnapshotsTable extends NetWorthSnapshots
    with TableInfo<$NetWorthSnapshotsTable, NetWorthSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NetWorthSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountBalanceMeta = const VerificationMeta(
    'accountBalance',
  );
  @override
  late final GeneratedColumn<double> accountBalance = GeneratedColumn<double>(
    'account_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portfolioValueMeta = const VerificationMeta(
    'portfolioValue',
  );
  @override
  late final GeneratedColumn<double> portfolioValue = GeneratedColumn<double>(
    'portfolio_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalNetWorthMeta = const VerificationMeta(
    'totalNetWorth',
  );
  @override
  late final GeneratedColumn<double> totalNetWorth = GeneratedColumn<double>(
    'total_net_worth',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    capturedAt,
    accountBalance,
    portfolioValue,
    totalNetWorth,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'net_worth_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<NetWorthSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('account_balance')) {
      context.handle(
        _accountBalanceMeta,
        accountBalance.isAcceptableOrUnknown(
          data['account_balance']!,
          _accountBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountBalanceMeta);
    }
    if (data.containsKey('portfolio_value')) {
      context.handle(
        _portfolioValueMeta,
        portfolioValue.isAcceptableOrUnknown(
          data['portfolio_value']!,
          _portfolioValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_portfolioValueMeta);
    }
    if (data.containsKey('total_net_worth')) {
      context.handle(
        _totalNetWorthMeta,
        totalNetWorth.isAcceptableOrUnknown(
          data['total_net_worth']!,
          _totalNetWorthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalNetWorthMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NetWorthSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NetWorthSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      accountBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}account_balance'],
      )!,
      portfolioValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}portfolio_value'],
      )!,
      totalNetWorth: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_net_worth'],
      )!,
    );
  }

  @override
  $NetWorthSnapshotsTable createAlias(String alias) {
    return $NetWorthSnapshotsTable(attachedDatabase, alias);
  }
}

class NetWorthSnapshot extends DataClass
    implements Insertable<NetWorthSnapshot> {
  final String id;
  final String userId;
  final DateTime capturedAt;
  final double accountBalance;
  final double portfolioValue;
  final double totalNetWorth;
  const NetWorthSnapshot({
    required this.id,
    required this.userId,
    required this.capturedAt,
    required this.accountBalance,
    required this.portfolioValue,
    required this.totalNetWorth,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['account_balance'] = Variable<double>(accountBalance);
    map['portfolio_value'] = Variable<double>(portfolioValue);
    map['total_net_worth'] = Variable<double>(totalNetWorth);
    return map;
  }

  NetWorthSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return NetWorthSnapshotsCompanion(
      id: Value(id),
      userId: Value(userId),
      capturedAt: Value(capturedAt),
      accountBalance: Value(accountBalance),
      portfolioValue: Value(portfolioValue),
      totalNetWorth: Value(totalNetWorth),
    );
  }

  factory NetWorthSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NetWorthSnapshot(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      accountBalance: serializer.fromJson<double>(json['accountBalance']),
      portfolioValue: serializer.fromJson<double>(json['portfolioValue']),
      totalNetWorth: serializer.fromJson<double>(json['totalNetWorth']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'accountBalance': serializer.toJson<double>(accountBalance),
      'portfolioValue': serializer.toJson<double>(portfolioValue),
      'totalNetWorth': serializer.toJson<double>(totalNetWorth),
    };
  }

  NetWorthSnapshot copyWith({
    String? id,
    String? userId,
    DateTime? capturedAt,
    double? accountBalance,
    double? portfolioValue,
    double? totalNetWorth,
  }) => NetWorthSnapshot(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    capturedAt: capturedAt ?? this.capturedAt,
    accountBalance: accountBalance ?? this.accountBalance,
    portfolioValue: portfolioValue ?? this.portfolioValue,
    totalNetWorth: totalNetWorth ?? this.totalNetWorth,
  );
  NetWorthSnapshot copyWithCompanion(NetWorthSnapshotsCompanion data) {
    return NetWorthSnapshot(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      accountBalance: data.accountBalance.present
          ? data.accountBalance.value
          : this.accountBalance,
      portfolioValue: data.portfolioValue.present
          ? data.portfolioValue.value
          : this.portfolioValue,
      totalNetWorth: data.totalNetWorth.present
          ? data.totalNetWorth.value
          : this.totalNetWorth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NetWorthSnapshot(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('accountBalance: $accountBalance, ')
          ..write('portfolioValue: $portfolioValue, ')
          ..write('totalNetWorth: $totalNetWorth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    capturedAt,
    accountBalance,
    portfolioValue,
    totalNetWorth,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NetWorthSnapshot &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.capturedAt == this.capturedAt &&
          other.accountBalance == this.accountBalance &&
          other.portfolioValue == this.portfolioValue &&
          other.totalNetWorth == this.totalNetWorth);
}

class NetWorthSnapshotsCompanion extends UpdateCompanion<NetWorthSnapshot> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> capturedAt;
  final Value<double> accountBalance;
  final Value<double> portfolioValue;
  final Value<double> totalNetWorth;
  final Value<int> rowid;
  const NetWorthSnapshotsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.accountBalance = const Value.absent(),
    this.portfolioValue = const Value.absent(),
    this.totalNetWorth = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NetWorthSnapshotsCompanion.insert({
    required String id,
    required String userId,
    required DateTime capturedAt,
    required double accountBalance,
    required double portfolioValue,
    required double totalNetWorth,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       capturedAt = Value(capturedAt),
       accountBalance = Value(accountBalance),
       portfolioValue = Value(portfolioValue),
       totalNetWorth = Value(totalNetWorth);
  static Insertable<NetWorthSnapshot> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? capturedAt,
    Expression<double>? accountBalance,
    Expression<double>? portfolioValue,
    Expression<double>? totalNetWorth,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (accountBalance != null) 'account_balance': accountBalance,
      if (portfolioValue != null) 'portfolio_value': portfolioValue,
      if (totalNetWorth != null) 'total_net_worth': totalNetWorth,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NetWorthSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<DateTime>? capturedAt,
    Value<double>? accountBalance,
    Value<double>? portfolioValue,
    Value<double>? totalNetWorth,
    Value<int>? rowid,
  }) {
    return NetWorthSnapshotsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      capturedAt: capturedAt ?? this.capturedAt,
      accountBalance: accountBalance ?? this.accountBalance,
      portfolioValue: portfolioValue ?? this.portfolioValue,
      totalNetWorth: totalNetWorth ?? this.totalNetWorth,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (accountBalance.present) {
      map['account_balance'] = Variable<double>(accountBalance.value);
    }
    if (portfolioValue.present) {
      map['portfolio_value'] = Variable<double>(portfolioValue.value);
    }
    if (totalNetWorth.present) {
      map['total_net_worth'] = Variable<double>(totalNetWorth.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NetWorthSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('accountBalance: $accountBalance, ')
          ..write('portfolioValue: $portfolioValue, ')
          ..write('totalNetWorth: $totalNetWorth, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMastersTable extends StockMasters
    with TableInfo<$StockMastersTable, StockMaster> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMastersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isinMeta = const VerificationMeta('isin');
  @override
  late final GeneratedColumn<String> isin = GeneratedColumn<String>(
    'isin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _wknMeta = const VerificationMeta('wkn');
  @override
  late final GeneratedColumn<String> wkn = GeneratedColumn<String>(
    'wkn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _dividendCurrencyMeta = const VerificationMeta(
    'dividendCurrency',
  );
  @override
  late final GeneratedColumn<String> dividendCurrency = GeneratedColumn<String>(
    'dividend_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _exchangeMeta = const VerificationMeta(
    'exchange',
  );
  @override
  late final GeneratedColumn<String> exchange = GeneratedColumn<String>(
    'exchange',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _brokerMeta = const VerificationMeta('broker');
  @override
  late final GeneratedColumn<String> broker = GeneratedColumn<String>(
    'broker',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sectorMeta = const VerificationMeta('sector');
  @override
  late final GeneratedColumn<String> sector = GeneratedColumn<String>(
    'sector',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dividendFrequencyMeta = const VerificationMeta(
    'dividendFrequency',
  );
  @override
  late final GeneratedColumn<String> dividendFrequency =
      GeneratedColumn<String>(
        'dividend_frequency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('jährlich'),
      );
  static const VerificationMeta _dividendStartMonthMeta =
      const VerificationMeta('dividendStartMonth');
  @override
  late final GeneratedColumn<int> dividendStartMonth = GeneratedColumn<int>(
    'dividend_start_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _companyDataMeta = const VerificationMeta(
    'companyData',
  );
  @override
  late final GeneratedColumn<String> companyData = GeneratedColumn<String>(
    'company_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    symbol,
    isin,
    wkn,
    currency,
    dividendCurrency,
    country,
    exchange,
    broker,
    sector,
    dividendFrequency,
    dividendStartMonth,
    companyData,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_masters';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMaster> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('isin')) {
      context.handle(
        _isinMeta,
        isin.isAcceptableOrUnknown(data['isin']!, _isinMeta),
      );
    }
    if (data.containsKey('wkn')) {
      context.handle(
        _wknMeta,
        wkn.isAcceptableOrUnknown(data['wkn']!, _wknMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('dividend_currency')) {
      context.handle(
        _dividendCurrencyMeta,
        dividendCurrency.isAcceptableOrUnknown(
          data['dividend_currency']!,
          _dividendCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('exchange')) {
      context.handle(
        _exchangeMeta,
        exchange.isAcceptableOrUnknown(data['exchange']!, _exchangeMeta),
      );
    }
    if (data.containsKey('broker')) {
      context.handle(
        _brokerMeta,
        broker.isAcceptableOrUnknown(data['broker']!, _brokerMeta),
      );
    }
    if (data.containsKey('sector')) {
      context.handle(
        _sectorMeta,
        sector.isAcceptableOrUnknown(data['sector']!, _sectorMeta),
      );
    }
    if (data.containsKey('dividend_frequency')) {
      context.handle(
        _dividendFrequencyMeta,
        dividendFrequency.isAcceptableOrUnknown(
          data['dividend_frequency']!,
          _dividendFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('dividend_start_month')) {
      context.handle(
        _dividendStartMonthMeta,
        dividendStartMonth.isAcceptableOrUnknown(
          data['dividend_start_month']!,
          _dividendStartMonthMeta,
        ),
      );
    }
    if (data.containsKey('company_data')) {
      context.handle(
        _companyDataMeta,
        companyData.isAcceptableOrUnknown(
          data['company_data']!,
          _companyDataMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMaster map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMaster(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      isin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isin'],
      )!,
      wkn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wkn'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      dividendCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dividend_currency'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      exchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exchange'],
      )!,
      broker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}broker'],
      )!,
      sector: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector'],
      )!,
      dividendFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dividend_frequency'],
      )!,
      dividendStartMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dividend_start_month'],
      )!,
      companyData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_data'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $StockMastersTable createAlias(String alias) {
    return $StockMastersTable(attachedDatabase, alias);
  }
}

class StockMaster extends DataClass implements Insertable<StockMaster> {
  final String id;
  final String name;
  final String symbol;
  final String isin;
  final String wkn;
  final String currency;
  final String dividendCurrency;
  final String country;
  final String exchange;
  final String broker;
  final String sector;
  final String dividendFrequency;
  final int dividendStartMonth;
  final String companyData;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const StockMaster({
    required this.id,
    required this.name,
    required this.symbol,
    required this.isin,
    required this.wkn,
    required this.currency,
    required this.dividendCurrency,
    required this.country,
    required this.exchange,
    required this.broker,
    required this.sector,
    required this.dividendFrequency,
    required this.dividendStartMonth,
    required this.companyData,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['symbol'] = Variable<String>(symbol);
    map['isin'] = Variable<String>(isin);
    map['wkn'] = Variable<String>(wkn);
    map['currency'] = Variable<String>(currency);
    map['dividend_currency'] = Variable<String>(dividendCurrency);
    map['country'] = Variable<String>(country);
    map['exchange'] = Variable<String>(exchange);
    map['broker'] = Variable<String>(broker);
    map['sector'] = Variable<String>(sector);
    map['dividend_frequency'] = Variable<String>(dividendFrequency);
    map['dividend_start_month'] = Variable<int>(dividendStartMonth);
    map['company_data'] = Variable<String>(companyData);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  StockMastersCompanion toCompanion(bool nullToAbsent) {
    return StockMastersCompanion(
      id: Value(id),
      name: Value(name),
      symbol: Value(symbol),
      isin: Value(isin),
      wkn: Value(wkn),
      currency: Value(currency),
      dividendCurrency: Value(dividendCurrency),
      country: Value(country),
      exchange: Value(exchange),
      broker: Value(broker),
      sector: Value(sector),
      dividendFrequency: Value(dividendFrequency),
      dividendStartMonth: Value(dividendStartMonth),
      companyData: Value(companyData),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory StockMaster.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMaster(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      symbol: serializer.fromJson<String>(json['symbol']),
      isin: serializer.fromJson<String>(json['isin']),
      wkn: serializer.fromJson<String>(json['wkn']),
      currency: serializer.fromJson<String>(json['currency']),
      dividendCurrency: serializer.fromJson<String>(json['dividendCurrency']),
      country: serializer.fromJson<String>(json['country']),
      exchange: serializer.fromJson<String>(json['exchange']),
      broker: serializer.fromJson<String>(json['broker']),
      sector: serializer.fromJson<String>(json['sector']),
      dividendFrequency: serializer.fromJson<String>(json['dividendFrequency']),
      dividendStartMonth: serializer.fromJson<int>(json['dividendStartMonth']),
      companyData: serializer.fromJson<String>(json['companyData']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'symbol': serializer.toJson<String>(symbol),
      'isin': serializer.toJson<String>(isin),
      'wkn': serializer.toJson<String>(wkn),
      'currency': serializer.toJson<String>(currency),
      'dividendCurrency': serializer.toJson<String>(dividendCurrency),
      'country': serializer.toJson<String>(country),
      'exchange': serializer.toJson<String>(exchange),
      'broker': serializer.toJson<String>(broker),
      'sector': serializer.toJson<String>(sector),
      'dividendFrequency': serializer.toJson<String>(dividendFrequency),
      'dividendStartMonth': serializer.toJson<int>(dividendStartMonth),
      'companyData': serializer.toJson<String>(companyData),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  StockMaster copyWith({
    String? id,
    String? name,
    String? symbol,
    String? isin,
    String? wkn,
    String? currency,
    String? dividendCurrency,
    String? country,
    String? exchange,
    String? broker,
    String? sector,
    String? dividendFrequency,
    int? dividendStartMonth,
    String? companyData,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => StockMaster(
    id: id ?? this.id,
    name: name ?? this.name,
    symbol: symbol ?? this.symbol,
    isin: isin ?? this.isin,
    wkn: wkn ?? this.wkn,
    currency: currency ?? this.currency,
    dividendCurrency: dividendCurrency ?? this.dividendCurrency,
    country: country ?? this.country,
    exchange: exchange ?? this.exchange,
    broker: broker ?? this.broker,
    sector: sector ?? this.sector,
    dividendFrequency: dividendFrequency ?? this.dividendFrequency,
    dividendStartMonth: dividendStartMonth ?? this.dividendStartMonth,
    companyData: companyData ?? this.companyData,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  StockMaster copyWithCompanion(StockMastersCompanion data) {
    return StockMaster(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      isin: data.isin.present ? data.isin.value : this.isin,
      wkn: data.wkn.present ? data.wkn.value : this.wkn,
      currency: data.currency.present ? data.currency.value : this.currency,
      dividendCurrency: data.dividendCurrency.present
          ? data.dividendCurrency.value
          : this.dividendCurrency,
      country: data.country.present ? data.country.value : this.country,
      exchange: data.exchange.present ? data.exchange.value : this.exchange,
      broker: data.broker.present ? data.broker.value : this.broker,
      sector: data.sector.present ? data.sector.value : this.sector,
      dividendFrequency: data.dividendFrequency.present
          ? data.dividendFrequency.value
          : this.dividendFrequency,
      dividendStartMonth: data.dividendStartMonth.present
          ? data.dividendStartMonth.value
          : this.dividendStartMonth,
      companyData: data.companyData.present
          ? data.companyData.value
          : this.companyData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMaster(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('isin: $isin, ')
          ..write('wkn: $wkn, ')
          ..write('currency: $currency, ')
          ..write('dividendCurrency: $dividendCurrency, ')
          ..write('country: $country, ')
          ..write('exchange: $exchange, ')
          ..write('broker: $broker, ')
          ..write('sector: $sector, ')
          ..write('dividendFrequency: $dividendFrequency, ')
          ..write('dividendStartMonth: $dividendStartMonth, ')
          ..write('companyData: $companyData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    symbol,
    isin,
    wkn,
    currency,
    dividendCurrency,
    country,
    exchange,
    broker,
    sector,
    dividendFrequency,
    dividendStartMonth,
    companyData,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMaster &&
          other.id == this.id &&
          other.name == this.name &&
          other.symbol == this.symbol &&
          other.isin == this.isin &&
          other.wkn == this.wkn &&
          other.currency == this.currency &&
          other.dividendCurrency == this.dividendCurrency &&
          other.country == this.country &&
          other.exchange == this.exchange &&
          other.broker == this.broker &&
          other.sector == this.sector &&
          other.dividendFrequency == this.dividendFrequency &&
          other.dividendStartMonth == this.dividendStartMonth &&
          other.companyData == this.companyData &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class StockMastersCompanion extends UpdateCompanion<StockMaster> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> symbol;
  final Value<String> isin;
  final Value<String> wkn;
  final Value<String> currency;
  final Value<String> dividendCurrency;
  final Value<String> country;
  final Value<String> exchange;
  final Value<String> broker;
  final Value<String> sector;
  final Value<String> dividendFrequency;
  final Value<int> dividendStartMonth;
  final Value<String> companyData;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const StockMastersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.symbol = const Value.absent(),
    this.isin = const Value.absent(),
    this.wkn = const Value.absent(),
    this.currency = const Value.absent(),
    this.dividendCurrency = const Value.absent(),
    this.country = const Value.absent(),
    this.exchange = const Value.absent(),
    this.broker = const Value.absent(),
    this.sector = const Value.absent(),
    this.dividendFrequency = const Value.absent(),
    this.dividendStartMonth = const Value.absent(),
    this.companyData = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMastersCompanion.insert({
    required String id,
    required String name,
    required String symbol,
    this.isin = const Value.absent(),
    this.wkn = const Value.absent(),
    this.currency = const Value.absent(),
    this.dividendCurrency = const Value.absent(),
    this.country = const Value.absent(),
    this.exchange = const Value.absent(),
    this.broker = const Value.absent(),
    this.sector = const Value.absent(),
    this.dividendFrequency = const Value.absent(),
    this.dividendStartMonth = const Value.absent(),
    this.companyData = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       symbol = Value(symbol),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<StockMaster> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? symbol,
    Expression<String>? isin,
    Expression<String>? wkn,
    Expression<String>? currency,
    Expression<String>? dividendCurrency,
    Expression<String>? country,
    Expression<String>? exchange,
    Expression<String>? broker,
    Expression<String>? sector,
    Expression<String>? dividendFrequency,
    Expression<int>? dividendStartMonth,
    Expression<String>? companyData,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (symbol != null) 'symbol': symbol,
      if (isin != null) 'isin': isin,
      if (wkn != null) 'wkn': wkn,
      if (currency != null) 'currency': currency,
      if (dividendCurrency != null) 'dividend_currency': dividendCurrency,
      if (country != null) 'country': country,
      if (exchange != null) 'exchange': exchange,
      if (broker != null) 'broker': broker,
      if (sector != null) 'sector': sector,
      if (dividendFrequency != null) 'dividend_frequency': dividendFrequency,
      if (dividendStartMonth != null)
        'dividend_start_month': dividendStartMonth,
      if (companyData != null) 'company_data': companyData,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMastersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? symbol,
    Value<String>? isin,
    Value<String>? wkn,
    Value<String>? currency,
    Value<String>? dividendCurrency,
    Value<String>? country,
    Value<String>? exchange,
    Value<String>? broker,
    Value<String>? sector,
    Value<String>? dividendFrequency,
    Value<int>? dividendStartMonth,
    Value<String>? companyData,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return StockMastersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      isin: isin ?? this.isin,
      wkn: wkn ?? this.wkn,
      currency: currency ?? this.currency,
      dividendCurrency: dividendCurrency ?? this.dividendCurrency,
      country: country ?? this.country,
      exchange: exchange ?? this.exchange,
      broker: broker ?? this.broker,
      sector: sector ?? this.sector,
      dividendFrequency: dividendFrequency ?? this.dividendFrequency,
      dividendStartMonth: dividendStartMonth ?? this.dividendStartMonth,
      companyData: companyData ?? this.companyData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (isin.present) {
      map['isin'] = Variable<String>(isin.value);
    }
    if (wkn.present) {
      map['wkn'] = Variable<String>(wkn.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (dividendCurrency.present) {
      map['dividend_currency'] = Variable<String>(dividendCurrency.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (exchange.present) {
      map['exchange'] = Variable<String>(exchange.value);
    }
    if (broker.present) {
      map['broker'] = Variable<String>(broker.value);
    }
    if (sector.present) {
      map['sector'] = Variable<String>(sector.value);
    }
    if (dividendFrequency.present) {
      map['dividend_frequency'] = Variable<String>(dividendFrequency.value);
    }
    if (dividendStartMonth.present) {
      map['dividend_start_month'] = Variable<int>(dividendStartMonth.value);
    }
    if (companyData.present) {
      map['company_data'] = Variable<String>(companyData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMastersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('isin: $isin, ')
          ..write('wkn: $wkn, ')
          ..write('currency: $currency, ')
          ..write('dividendCurrency: $dividendCurrency, ')
          ..write('country: $country, ')
          ..write('exchange: $exchange, ')
          ..write('broker: $broker, ')
          ..write('sector: $sector, ')
          ..write('dividendFrequency: $dividendFrequency, ')
          ..write('dividendStartMonth: $dividendStartMonth, ')
          ..write('companyData: $companyData, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockPricesTable extends StockPrices
    with TableInfo<$StockPricesTable, StockPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stockIdMeta = const VerificationMeta(
    'stockId',
  );
  @override
  late final GeneratedColumn<String> stockId = GeneratedColumn<String>(
    'stock_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stock_masters (id)',
    ),
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _quotedAtMeta = const VerificationMeta(
    'quotedAt',
  );
  @override
  late final GeneratedColumn<DateTime> quotedAt = GeneratedColumn<DateTime>(
    'quoted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [stockId, price, currency, quotedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockPrice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('stock_id')) {
      context.handle(
        _stockIdMeta,
        stockId.isAcceptableOrUnknown(data['stock_id']!, _stockIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stockIdMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('quoted_at')) {
      context.handle(
        _quotedAtMeta,
        quotedAt.isAcceptableOrUnknown(data['quoted_at']!, _quotedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_quotedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stockId};
  @override
  StockPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockPrice(
      stockId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_id'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      quotedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}quoted_at'],
      )!,
    );
  }

  @override
  $StockPricesTable createAlias(String alias) {
    return $StockPricesTable(attachedDatabase, alias);
  }
}

class StockPrice extends DataClass implements Insertable<StockPrice> {
  final String stockId;
  final double price;
  final String currency;
  final DateTime quotedAt;
  const StockPrice({
    required this.stockId,
    required this.price,
    required this.currency,
    required this.quotedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['stock_id'] = Variable<String>(stockId);
    map['price'] = Variable<double>(price);
    map['currency'] = Variable<String>(currency);
    map['quoted_at'] = Variable<DateTime>(quotedAt);
    return map;
  }

  StockPricesCompanion toCompanion(bool nullToAbsent) {
    return StockPricesCompanion(
      stockId: Value(stockId),
      price: Value(price),
      currency: Value(currency),
      quotedAt: Value(quotedAt),
    );
  }

  factory StockPrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockPrice(
      stockId: serializer.fromJson<String>(json['stockId']),
      price: serializer.fromJson<double>(json['price']),
      currency: serializer.fromJson<String>(json['currency']),
      quotedAt: serializer.fromJson<DateTime>(json['quotedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stockId': serializer.toJson<String>(stockId),
      'price': serializer.toJson<double>(price),
      'currency': serializer.toJson<String>(currency),
      'quotedAt': serializer.toJson<DateTime>(quotedAt),
    };
  }

  StockPrice copyWith({
    String? stockId,
    double? price,
    String? currency,
    DateTime? quotedAt,
  }) => StockPrice(
    stockId: stockId ?? this.stockId,
    price: price ?? this.price,
    currency: currency ?? this.currency,
    quotedAt: quotedAt ?? this.quotedAt,
  );
  StockPrice copyWithCompanion(StockPricesCompanion data) {
    return StockPrice(
      stockId: data.stockId.present ? data.stockId.value : this.stockId,
      price: data.price.present ? data.price.value : this.price,
      currency: data.currency.present ? data.currency.value : this.currency,
      quotedAt: data.quotedAt.present ? data.quotedAt.value : this.quotedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockPrice(')
          ..write('stockId: $stockId, ')
          ..write('price: $price, ')
          ..write('currency: $currency, ')
          ..write('quotedAt: $quotedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(stockId, price, currency, quotedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockPrice &&
          other.stockId == this.stockId &&
          other.price == this.price &&
          other.currency == this.currency &&
          other.quotedAt == this.quotedAt);
}

class StockPricesCompanion extends UpdateCompanion<StockPrice> {
  final Value<String> stockId;
  final Value<double> price;
  final Value<String> currency;
  final Value<DateTime> quotedAt;
  final Value<int> rowid;
  const StockPricesCompanion({
    this.stockId = const Value.absent(),
    this.price = const Value.absent(),
    this.currency = const Value.absent(),
    this.quotedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockPricesCompanion.insert({
    required String stockId,
    required double price,
    this.currency = const Value.absent(),
    required DateTime quotedAt,
    this.rowid = const Value.absent(),
  }) : stockId = Value(stockId),
       price = Value(price),
       quotedAt = Value(quotedAt);
  static Insertable<StockPrice> custom({
    Expression<String>? stockId,
    Expression<double>? price,
    Expression<String>? currency,
    Expression<DateTime>? quotedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stockId != null) 'stock_id': stockId,
      if (price != null) 'price': price,
      if (currency != null) 'currency': currency,
      if (quotedAt != null) 'quoted_at': quotedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockPricesCompanion copyWith({
    Value<String>? stockId,
    Value<double>? price,
    Value<String>? currency,
    Value<DateTime>? quotedAt,
    Value<int>? rowid,
  }) {
    return StockPricesCompanion(
      stockId: stockId ?? this.stockId,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      quotedAt: quotedAt ?? this.quotedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stockId.present) {
      map['stock_id'] = Variable<String>(stockId.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (quotedAt.present) {
      map['quoted_at'] = Variable<DateTime>(quotedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockPricesCompanion(')
          ..write('stockId: $stockId, ')
          ..write('price: $price, ')
          ..write('currency: $currency, ')
          ..write('quotedAt: $quotedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockDividendsTable extends StockDividends
    with TableInfo<$StockDividendsTable, StockDividend> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockDividendsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockIdMeta = const VerificationMeta(
    'stockId',
  );
  @override
  late final GeneratedColumn<String> stockId = GeneratedColumn<String>(
    'stock_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stock_masters (id)',
    ),
  );
  static const VerificationMeta _exDateMeta = const VerificationMeta('exDate');
  @override
  late final GeneratedColumn<DateTime> exDate = GeneratedColumn<DateTime>(
    'ex_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stockId,
    exDate,
    paymentDate,
    amount,
    currency,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_dividends';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockDividend> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('stock_id')) {
      context.handle(
        _stockIdMeta,
        stockId.isAcceptableOrUnknown(data['stock_id']!, _stockIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stockIdMeta);
    }
    if (data.containsKey('ex_date')) {
      context.handle(
        _exDateMeta,
        exDate.isAcceptableOrUnknown(data['ex_date']!, _exDateMeta),
      );
    } else if (isInserting) {
      context.missing(_exDateMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockDividend map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockDividend(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      stockId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_id'],
      )!,
      exDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ex_date'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $StockDividendsTable createAlias(String alias) {
    return $StockDividendsTable(attachedDatabase, alias);
  }
}

class StockDividend extends DataClass implements Insertable<StockDividend> {
  final String id;
  final String stockId;
  final DateTime exDate;
  final DateTime? paymentDate;
  final double amount;
  final String currency;
  final DateTime fetchedAt;
  const StockDividend({
    required this.id,
    required this.stockId,
    required this.exDate,
    this.paymentDate,
    required this.amount,
    required this.currency,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['stock_id'] = Variable<String>(stockId);
    map['ex_date'] = Variable<DateTime>(exDate);
    if (!nullToAbsent || paymentDate != null) {
      map['payment_date'] = Variable<DateTime>(paymentDate);
    }
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  StockDividendsCompanion toCompanion(bool nullToAbsent) {
    return StockDividendsCompanion(
      id: Value(id),
      stockId: Value(stockId),
      exDate: Value(exDate),
      paymentDate: paymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDate),
      amount: Value(amount),
      currency: Value(currency),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory StockDividend.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockDividend(
      id: serializer.fromJson<String>(json['id']),
      stockId: serializer.fromJson<String>(json['stockId']),
      exDate: serializer.fromJson<DateTime>(json['exDate']),
      paymentDate: serializer.fromJson<DateTime?>(json['paymentDate']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'stockId': serializer.toJson<String>(stockId),
      'exDate': serializer.toJson<DateTime>(exDate),
      'paymentDate': serializer.toJson<DateTime?>(paymentDate),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  StockDividend copyWith({
    String? id,
    String? stockId,
    DateTime? exDate,
    Value<DateTime?> paymentDate = const Value.absent(),
    double? amount,
    String? currency,
    DateTime? fetchedAt,
  }) => StockDividend(
    id: id ?? this.id,
    stockId: stockId ?? this.stockId,
    exDate: exDate ?? this.exDate,
    paymentDate: paymentDate.present ? paymentDate.value : this.paymentDate,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  StockDividend copyWithCompanion(StockDividendsCompanion data) {
    return StockDividend(
      id: data.id.present ? data.id.value : this.id,
      stockId: data.stockId.present ? data.stockId.value : this.stockId,
      exDate: data.exDate.present ? data.exDate.value : this.exDate,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockDividend(')
          ..write('id: $id, ')
          ..write('stockId: $stockId, ')
          ..write('exDate: $exDate, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    stockId,
    exDate,
    paymentDate,
    amount,
    currency,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockDividend &&
          other.id == this.id &&
          other.stockId == this.stockId &&
          other.exDate == this.exDate &&
          other.paymentDate == this.paymentDate &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.fetchedAt == this.fetchedAt);
}

class StockDividendsCompanion extends UpdateCompanion<StockDividend> {
  final Value<String> id;
  final Value<String> stockId;
  final Value<DateTime> exDate;
  final Value<DateTime?> paymentDate;
  final Value<double> amount;
  final Value<String> currency;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const StockDividendsCompanion({
    this.id = const Value.absent(),
    this.stockId = const Value.absent(),
    this.exDate = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockDividendsCompanion.insert({
    required String id,
    required String stockId,
    required DateTime exDate,
    this.paymentDate = const Value.absent(),
    required double amount,
    this.currency = const Value.absent(),
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       stockId = Value(stockId),
       exDate = Value(exDate),
       amount = Value(amount),
       fetchedAt = Value(fetchedAt);
  static Insertable<StockDividend> custom({
    Expression<String>? id,
    Expression<String>? stockId,
    Expression<DateTime>? exDate,
    Expression<DateTime>? paymentDate,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stockId != null) 'stock_id': stockId,
      if (exDate != null) 'ex_date': exDate,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockDividendsCompanion copyWith({
    Value<String>? id,
    Value<String>? stockId,
    Value<DateTime>? exDate,
    Value<DateTime?>? paymentDate,
    Value<double>? amount,
    Value<String>? currency,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return StockDividendsCompanion(
      id: id ?? this.id,
      stockId: stockId ?? this.stockId,
      exDate: exDate ?? this.exDate,
      paymentDate: paymentDate ?? this.paymentDate,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (stockId.present) {
      map['stock_id'] = Variable<String>(stockId.value);
    }
    if (exDate.present) {
      map['ex_date'] = Variable<DateTime>(exDate.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockDividendsCompanion(')
          ..write('id: $id, ')
          ..write('stockId: $stockId, ')
          ..write('exDate: $exDate, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MarketDataRefreshesTable extends MarketDataRefreshes
    with TableInfo<$MarketDataRefreshesTable, MarketDataRefreshe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarketDataRefreshesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dataTypeMeta = const VerificationMeta(
    'dataType',
  );
  @override
  late final GeneratedColumn<String> dataType = GeneratedColumn<String>(
    'data_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeKeyMeta = const VerificationMeta(
    'scopeKey',
  );
  @override
  late final GeneratedColumn<String> scopeKey = GeneratedColumn<String>(
    'scope_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refreshedAtMeta = const VerificationMeta(
    'refreshedAt',
  );
  @override
  late final GeneratedColumn<DateTime> refreshedAt = GeneratedColumn<DateTime>(
    'refreshed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [dataType, scopeKey, refreshedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'market_data_refreshes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarketDataRefreshe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('data_type')) {
      context.handle(
        _dataTypeMeta,
        dataType.isAcceptableOrUnknown(data['data_type']!, _dataTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_dataTypeMeta);
    }
    if (data.containsKey('scope_key')) {
      context.handle(
        _scopeKeyMeta,
        scopeKey.isAcceptableOrUnknown(data['scope_key']!, _scopeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeKeyMeta);
    }
    if (data.containsKey('refreshed_at')) {
      context.handle(
        _refreshedAtMeta,
        refreshedAt.isAcceptableOrUnknown(
          data['refreshed_at']!,
          _refreshedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refreshedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dataType, scopeKey};
  @override
  MarketDataRefreshe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarketDataRefreshe(
      dataType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_type'],
      )!,
      scopeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_key'],
      )!,
      refreshedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}refreshed_at'],
      )!,
    );
  }

  @override
  $MarketDataRefreshesTable createAlias(String alias) {
    return $MarketDataRefreshesTable(attachedDatabase, alias);
  }
}

class MarketDataRefreshe extends DataClass
    implements Insertable<MarketDataRefreshe> {
  final String dataType;
  final String scopeKey;
  final DateTime refreshedAt;
  const MarketDataRefreshe({
    required this.dataType,
    required this.scopeKey,
    required this.refreshedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['data_type'] = Variable<String>(dataType);
    map['scope_key'] = Variable<String>(scopeKey);
    map['refreshed_at'] = Variable<DateTime>(refreshedAt);
    return map;
  }

  MarketDataRefreshesCompanion toCompanion(bool nullToAbsent) {
    return MarketDataRefreshesCompanion(
      dataType: Value(dataType),
      scopeKey: Value(scopeKey),
      refreshedAt: Value(refreshedAt),
    );
  }

  factory MarketDataRefreshe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarketDataRefreshe(
      dataType: serializer.fromJson<String>(json['dataType']),
      scopeKey: serializer.fromJson<String>(json['scopeKey']),
      refreshedAt: serializer.fromJson<DateTime>(json['refreshedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dataType': serializer.toJson<String>(dataType),
      'scopeKey': serializer.toJson<String>(scopeKey),
      'refreshedAt': serializer.toJson<DateTime>(refreshedAt),
    };
  }

  MarketDataRefreshe copyWith({
    String? dataType,
    String? scopeKey,
    DateTime? refreshedAt,
  }) => MarketDataRefreshe(
    dataType: dataType ?? this.dataType,
    scopeKey: scopeKey ?? this.scopeKey,
    refreshedAt: refreshedAt ?? this.refreshedAt,
  );
  MarketDataRefreshe copyWithCompanion(MarketDataRefreshesCompanion data) {
    return MarketDataRefreshe(
      dataType: data.dataType.present ? data.dataType.value : this.dataType,
      scopeKey: data.scopeKey.present ? data.scopeKey.value : this.scopeKey,
      refreshedAt: data.refreshedAt.present
          ? data.refreshedAt.value
          : this.refreshedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarketDataRefreshe(')
          ..write('dataType: $dataType, ')
          ..write('scopeKey: $scopeKey, ')
          ..write('refreshedAt: $refreshedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dataType, scopeKey, refreshedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarketDataRefreshe &&
          other.dataType == this.dataType &&
          other.scopeKey == this.scopeKey &&
          other.refreshedAt == this.refreshedAt);
}

class MarketDataRefreshesCompanion extends UpdateCompanion<MarketDataRefreshe> {
  final Value<String> dataType;
  final Value<String> scopeKey;
  final Value<DateTime> refreshedAt;
  final Value<int> rowid;
  const MarketDataRefreshesCompanion({
    this.dataType = const Value.absent(),
    this.scopeKey = const Value.absent(),
    this.refreshedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarketDataRefreshesCompanion.insert({
    required String dataType,
    required String scopeKey,
    required DateTime refreshedAt,
    this.rowid = const Value.absent(),
  }) : dataType = Value(dataType),
       scopeKey = Value(scopeKey),
       refreshedAt = Value(refreshedAt);
  static Insertable<MarketDataRefreshe> custom({
    Expression<String>? dataType,
    Expression<String>? scopeKey,
    Expression<DateTime>? refreshedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dataType != null) 'data_type': dataType,
      if (scopeKey != null) 'scope_key': scopeKey,
      if (refreshedAt != null) 'refreshed_at': refreshedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarketDataRefreshesCompanion copyWith({
    Value<String>? dataType,
    Value<String>? scopeKey,
    Value<DateTime>? refreshedAt,
    Value<int>? rowid,
  }) {
    return MarketDataRefreshesCompanion(
      dataType: dataType ?? this.dataType,
      scopeKey: scopeKey ?? this.scopeKey,
      refreshedAt: refreshedAt ?? this.refreshedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dataType.present) {
      map['data_type'] = Variable<String>(dataType.value);
    }
    if (scopeKey.present) {
      map['scope_key'] = Variable<String>(scopeKey.value);
    }
    if (refreshedAt.present) {
      map['refreshed_at'] = Variable<DateTime>(refreshedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarketDataRefreshesCompanion(')
          ..write('dataType: $dataType, ')
          ..write('scopeKey: $scopeKey, ')
          ..write('refreshedAt: $refreshedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApiRequestDaysTable extends ApiRequestDays
    with TableInfo<$ApiRequestDaysTable, ApiRequestDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApiRequestDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestCountMeta = const VerificationMeta(
    'requestCount',
  );
  @override
  late final GeneratedColumn<int> requestCount = GeneratedColumn<int>(
    'request_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day, requestCount, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'api_request_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApiRequestDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('request_count')) {
      context.handle(
        _requestCountMeta,
        requestCount.isAcceptableOrUnknown(
          data['request_count']!,
          _requestCountMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  ApiRequestDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApiRequestDay(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      requestCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}request_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ApiRequestDaysTable createAlias(String alias) {
    return $ApiRequestDaysTable(attachedDatabase, alias);
  }
}

class ApiRequestDay extends DataClass implements Insertable<ApiRequestDay> {
  final String day;
  final int requestCount;
  final DateTime updatedAt;
  const ApiRequestDay({
    required this.day,
    required this.requestCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['request_count'] = Variable<int>(requestCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ApiRequestDaysCompanion toCompanion(bool nullToAbsent) {
    return ApiRequestDaysCompanion(
      day: Value(day),
      requestCount: Value(requestCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory ApiRequestDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApiRequestDay(
      day: serializer.fromJson<String>(json['day']),
      requestCount: serializer.fromJson<int>(json['requestCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'requestCount': serializer.toJson<int>(requestCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ApiRequestDay copyWith({
    String? day,
    int? requestCount,
    DateTime? updatedAt,
  }) => ApiRequestDay(
    day: day ?? this.day,
    requestCount: requestCount ?? this.requestCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ApiRequestDay copyWithCompanion(ApiRequestDaysCompanion data) {
    return ApiRequestDay(
      day: data.day.present ? data.day.value : this.day,
      requestCount: data.requestCount.present
          ? data.requestCount.value
          : this.requestCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApiRequestDay(')
          ..write('day: $day, ')
          ..write('requestCount: $requestCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, requestCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApiRequestDay &&
          other.day == this.day &&
          other.requestCount == this.requestCount &&
          other.updatedAt == this.updatedAt);
}

class ApiRequestDaysCompanion extends UpdateCompanion<ApiRequestDay> {
  final Value<String> day;
  final Value<int> requestCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ApiRequestDaysCompanion({
    this.day = const Value.absent(),
    this.requestCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApiRequestDaysCompanion.insert({
    required String day,
    this.requestCount = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       updatedAt = Value(updatedAt);
  static Insertable<ApiRequestDay> custom({
    Expression<String>? day,
    Expression<int>? requestCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (requestCount != null) 'request_count': requestCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApiRequestDaysCompanion copyWith({
    Value<String>? day,
    Value<int>? requestCount,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ApiRequestDaysCompanion(
      day: day ?? this.day,
      requestCount: requestCount ?? this.requestCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (requestCount.present) {
      map['request_count'] = Variable<int>(requestCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApiRequestDaysCompanion(')
          ..write('day: $day, ')
          ..write('requestCount: $requestCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CountryTaxRatesTable extends CountryTaxRates
    with TableInfo<$CountryTaxRatesTable, CountryTaxRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountryTaxRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _withholdingTaxRateMeta =
      const VerificationMeta('withholdingTaxRate');
  @override
  late final GeneratedColumn<double> withholdingTaxRate =
      GeneratedColumn<double>(
        'withholding_tax_rate',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _exchangeRateMeta = const VerificationMeta(
    'exchangeRate',
  );
  @override
  late final GeneratedColumn<double> exchangeRate = GeneratedColumn<double>(
    'exchange_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _allowManualExchangeRateMeta =
      const VerificationMeta('allowManualExchangeRate');
  @override
  late final GeneratedColumn<bool> allowManualExchangeRate =
      GeneratedColumn<bool>(
        'allow_manual_exchange_rate',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("allow_manual_exchange_rate" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _exchangeRateUpdatedAtMeta =
      const VerificationMeta('exchangeRateUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> exchangeRateUpdatedAt =
      GeneratedColumn<DateTime>(
        'exchange_rate_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    country,
    withholdingTaxRate,
    currency,
    exchangeRate,
    allowManualExchangeRate,
    exchangeRateUpdatedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'country_tax_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<CountryTaxRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    if (data.containsKey('withholding_tax_rate')) {
      context.handle(
        _withholdingTaxRateMeta,
        withholdingTaxRate.isAcceptableOrUnknown(
          data['withholding_tax_rate']!,
          _withholdingTaxRateMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('exchange_rate')) {
      context.handle(
        _exchangeRateMeta,
        exchangeRate.isAcceptableOrUnknown(
          data['exchange_rate']!,
          _exchangeRateMeta,
        ),
      );
    }
    if (data.containsKey('allow_manual_exchange_rate')) {
      context.handle(
        _allowManualExchangeRateMeta,
        allowManualExchangeRate.isAcceptableOrUnknown(
          data['allow_manual_exchange_rate']!,
          _allowManualExchangeRateMeta,
        ),
      );
    }
    if (data.containsKey('exchange_rate_updated_at')) {
      context.handle(
        _exchangeRateUpdatedAtMeta,
        exchangeRateUpdatedAt.isAcceptableOrUnknown(
          data['exchange_rate_updated_at']!,
          _exchangeRateUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {country};
  @override
  CountryTaxRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CountryTaxRate(
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      withholdingTaxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}withholding_tax_rate'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      exchangeRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}exchange_rate'],
      )!,
      allowManualExchangeRate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_manual_exchange_rate'],
      )!,
      exchangeRateUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}exchange_rate_updated_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CountryTaxRatesTable createAlias(String alias) {
    return $CountryTaxRatesTable(attachedDatabase, alias);
  }
}

class CountryTaxRate extends DataClass implements Insertable<CountryTaxRate> {
  final String country;
  final double withholdingTaxRate;
  final String currency;
  final double exchangeRate;
  final bool allowManualExchangeRate;
  final DateTime? exchangeRateUpdatedAt;
  final DateTime updatedAt;
  const CountryTaxRate({
    required this.country,
    required this.withholdingTaxRate,
    required this.currency,
    required this.exchangeRate,
    required this.allowManualExchangeRate,
    this.exchangeRateUpdatedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['country'] = Variable<String>(country);
    map['withholding_tax_rate'] = Variable<double>(withholdingTaxRate);
    map['currency'] = Variable<String>(currency);
    map['exchange_rate'] = Variable<double>(exchangeRate);
    map['allow_manual_exchange_rate'] = Variable<bool>(allowManualExchangeRate);
    if (!nullToAbsent || exchangeRateUpdatedAt != null) {
      map['exchange_rate_updated_at'] = Variable<DateTime>(
        exchangeRateUpdatedAt,
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CountryTaxRatesCompanion toCompanion(bool nullToAbsent) {
    return CountryTaxRatesCompanion(
      country: Value(country),
      withholdingTaxRate: Value(withholdingTaxRate),
      currency: Value(currency),
      exchangeRate: Value(exchangeRate),
      allowManualExchangeRate: Value(allowManualExchangeRate),
      exchangeRateUpdatedAt: exchangeRateUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRateUpdatedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CountryTaxRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CountryTaxRate(
      country: serializer.fromJson<String>(json['country']),
      withholdingTaxRate: serializer.fromJson<double>(
        json['withholdingTaxRate'],
      ),
      currency: serializer.fromJson<String>(json['currency']),
      exchangeRate: serializer.fromJson<double>(json['exchangeRate']),
      allowManualExchangeRate: serializer.fromJson<bool>(
        json['allowManualExchangeRate'],
      ),
      exchangeRateUpdatedAt: serializer.fromJson<DateTime?>(
        json['exchangeRateUpdatedAt'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'country': serializer.toJson<String>(country),
      'withholdingTaxRate': serializer.toJson<double>(withholdingTaxRate),
      'currency': serializer.toJson<String>(currency),
      'exchangeRate': serializer.toJson<double>(exchangeRate),
      'allowManualExchangeRate': serializer.toJson<bool>(
        allowManualExchangeRate,
      ),
      'exchangeRateUpdatedAt': serializer.toJson<DateTime?>(
        exchangeRateUpdatedAt,
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CountryTaxRate copyWith({
    String? country,
    double? withholdingTaxRate,
    String? currency,
    double? exchangeRate,
    bool? allowManualExchangeRate,
    Value<DateTime?> exchangeRateUpdatedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => CountryTaxRate(
    country: country ?? this.country,
    withholdingTaxRate: withholdingTaxRate ?? this.withholdingTaxRate,
    currency: currency ?? this.currency,
    exchangeRate: exchangeRate ?? this.exchangeRate,
    allowManualExchangeRate:
        allowManualExchangeRate ?? this.allowManualExchangeRate,
    exchangeRateUpdatedAt: exchangeRateUpdatedAt.present
        ? exchangeRateUpdatedAt.value
        : this.exchangeRateUpdatedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CountryTaxRate copyWithCompanion(CountryTaxRatesCompanion data) {
    return CountryTaxRate(
      country: data.country.present ? data.country.value : this.country,
      withholdingTaxRate: data.withholdingTaxRate.present
          ? data.withholdingTaxRate.value
          : this.withholdingTaxRate,
      currency: data.currency.present ? data.currency.value : this.currency,
      exchangeRate: data.exchangeRate.present
          ? data.exchangeRate.value
          : this.exchangeRate,
      allowManualExchangeRate: data.allowManualExchangeRate.present
          ? data.allowManualExchangeRate.value
          : this.allowManualExchangeRate,
      exchangeRateUpdatedAt: data.exchangeRateUpdatedAt.present
          ? data.exchangeRateUpdatedAt.value
          : this.exchangeRateUpdatedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CountryTaxRate(')
          ..write('country: $country, ')
          ..write('withholdingTaxRate: $withholdingTaxRate, ')
          ..write('currency: $currency, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('allowManualExchangeRate: $allowManualExchangeRate, ')
          ..write('exchangeRateUpdatedAt: $exchangeRateUpdatedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    country,
    withholdingTaxRate,
    currency,
    exchangeRate,
    allowManualExchangeRate,
    exchangeRateUpdatedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountryTaxRate &&
          other.country == this.country &&
          other.withholdingTaxRate == this.withholdingTaxRate &&
          other.currency == this.currency &&
          other.exchangeRate == this.exchangeRate &&
          other.allowManualExchangeRate == this.allowManualExchangeRate &&
          other.exchangeRateUpdatedAt == this.exchangeRateUpdatedAt &&
          other.updatedAt == this.updatedAt);
}

class CountryTaxRatesCompanion extends UpdateCompanion<CountryTaxRate> {
  final Value<String> country;
  final Value<double> withholdingTaxRate;
  final Value<String> currency;
  final Value<double> exchangeRate;
  final Value<bool> allowManualExchangeRate;
  final Value<DateTime?> exchangeRateUpdatedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CountryTaxRatesCompanion({
    this.country = const Value.absent(),
    this.withholdingTaxRate = const Value.absent(),
    this.currency = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.allowManualExchangeRate = const Value.absent(),
    this.exchangeRateUpdatedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountryTaxRatesCompanion.insert({
    required String country,
    this.withholdingTaxRate = const Value.absent(),
    this.currency = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.allowManualExchangeRate = const Value.absent(),
    this.exchangeRateUpdatedAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : country = Value(country),
       updatedAt = Value(updatedAt);
  static Insertable<CountryTaxRate> custom({
    Expression<String>? country,
    Expression<double>? withholdingTaxRate,
    Expression<String>? currency,
    Expression<double>? exchangeRate,
    Expression<bool>? allowManualExchangeRate,
    Expression<DateTime>? exchangeRateUpdatedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (country != null) 'country': country,
      if (withholdingTaxRate != null)
        'withholding_tax_rate': withholdingTaxRate,
      if (currency != null) 'currency': currency,
      if (exchangeRate != null) 'exchange_rate': exchangeRate,
      if (allowManualExchangeRate != null)
        'allow_manual_exchange_rate': allowManualExchangeRate,
      if (exchangeRateUpdatedAt != null)
        'exchange_rate_updated_at': exchangeRateUpdatedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountryTaxRatesCompanion copyWith({
    Value<String>? country,
    Value<double>? withholdingTaxRate,
    Value<String>? currency,
    Value<double>? exchangeRate,
    Value<bool>? allowManualExchangeRate,
    Value<DateTime?>? exchangeRateUpdatedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CountryTaxRatesCompanion(
      country: country ?? this.country,
      withholdingTaxRate: withholdingTaxRate ?? this.withholdingTaxRate,
      currency: currency ?? this.currency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      allowManualExchangeRate:
          allowManualExchangeRate ?? this.allowManualExchangeRate,
      exchangeRateUpdatedAt:
          exchangeRateUpdatedAt ?? this.exchangeRateUpdatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (withholdingTaxRate.present) {
      map['withholding_tax_rate'] = Variable<double>(withholdingTaxRate.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (exchangeRate.present) {
      map['exchange_rate'] = Variable<double>(exchangeRate.value);
    }
    if (allowManualExchangeRate.present) {
      map['allow_manual_exchange_rate'] = Variable<bool>(
        allowManualExchangeRate.value,
      );
    }
    if (exchangeRateUpdatedAt.present) {
      map['exchange_rate_updated_at'] = Variable<DateTime>(
        exchangeRateUpdatedAt.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountryTaxRatesCompanion(')
          ..write('country: $country, ')
          ..write('withholdingTaxRate: $withholdingTaxRate, ')
          ..write('currency: $currency, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('allowManualExchangeRate: $allowManualExchangeRate, ')
          ..write('exchangeRateUpdatedAt: $exchangeRateUpdatedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetClassesTable extends AssetClasses
    with TableInfo<$AssetClassesTable, AssetClassesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetClassesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, displayOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_classes';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetClassesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  AssetClassesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetClassesData(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AssetClassesTable createAlias(String alias) {
    return $AssetClassesTable(attachedDatabase, alias);
  }
}

class AssetClassesData extends DataClass
    implements Insertable<AssetClassesData> {
  final String name;
  final int displayOrder;
  final DateTime createdAt;
  const AssetClassesData({
    required this.name,
    required this.displayOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['display_order'] = Variable<int>(displayOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AssetClassesCompanion toCompanion(bool nullToAbsent) {
    return AssetClassesCompanion(
      name: Value(name),
      displayOrder: Value(displayOrder),
      createdAt: Value(createdAt),
    );
  }

  factory AssetClassesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetClassesData(
      name: serializer.fromJson<String>(json['name']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AssetClassesData copyWith({
    String? name,
    int? displayOrder,
    DateTime? createdAt,
  }) => AssetClassesData(
    name: name ?? this.name,
    displayOrder: displayOrder ?? this.displayOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  AssetClassesData copyWithCompanion(AssetClassesCompanion data) {
    return AssetClassesData(
      name: data.name.present ? data.name.value : this.name,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetClassesData(')
          ..write('name: $name, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, displayOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetClassesData &&
          other.name == this.name &&
          other.displayOrder == this.displayOrder &&
          other.createdAt == this.createdAt);
}

class AssetClassesCompanion extends UpdateCompanion<AssetClassesData> {
  final Value<String> name;
  final Value<int> displayOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AssetClassesCompanion({
    this.name = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetClassesCompanion.insert({
    required String name,
    this.displayOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<AssetClassesData> custom({
    Expression<String>? name,
    Expression<int>? displayOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (displayOrder != null) 'display_order': displayOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetClassesCompanion copyWith({
    Value<String>? name,
    Value<int>? displayOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AssetClassesCompanion(
      name: name ?? this.name,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetClassesCompanion(')
          ..write('name: $name, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppConfigurationsTable extends AppConfigurations
    with TableInfo<$AppConfigurationsTable, AppConfiguration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppConfigurationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maximumTaxAllowanceMeta =
      const VerificationMeta('maximumTaxAllowance');
  @override
  late final GeneratedColumn<double> maximumTaxAllowance =
      GeneratedColumn<double>(
        'maximum_tax_allowance',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1000),
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, maximumTaxAllowance, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_configurations';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppConfiguration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('maximum_tax_allowance')) {
      context.handle(
        _maximumTaxAllowanceMeta,
        maximumTaxAllowance.isAcceptableOrUnknown(
          data['maximum_tax_allowance']!,
          _maximumTaxAllowanceMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppConfiguration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppConfiguration(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      maximumTaxAllowance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}maximum_tax_allowance'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppConfigurationsTable createAlias(String alias) {
    return $AppConfigurationsTable(attachedDatabase, alias);
  }
}

class AppConfiguration extends DataClass
    implements Insertable<AppConfiguration> {
  final String id;
  final double maximumTaxAllowance;
  final DateTime updatedAt;
  const AppConfiguration({
    required this.id,
    required this.maximumTaxAllowance,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['maximum_tax_allowance'] = Variable<double>(maximumTaxAllowance);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppConfigurationsCompanion toCompanion(bool nullToAbsent) {
    return AppConfigurationsCompanion(
      id: Value(id),
      maximumTaxAllowance: Value(maximumTaxAllowance),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppConfiguration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppConfiguration(
      id: serializer.fromJson<String>(json['id']),
      maximumTaxAllowance: serializer.fromJson<double>(
        json['maximumTaxAllowance'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'maximumTaxAllowance': serializer.toJson<double>(maximumTaxAllowance),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppConfiguration copyWith({
    String? id,
    double? maximumTaxAllowance,
    DateTime? updatedAt,
  }) => AppConfiguration(
    id: id ?? this.id,
    maximumTaxAllowance: maximumTaxAllowance ?? this.maximumTaxAllowance,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppConfiguration copyWithCompanion(AppConfigurationsCompanion data) {
    return AppConfiguration(
      id: data.id.present ? data.id.value : this.id,
      maximumTaxAllowance: data.maximumTaxAllowance.present
          ? data.maximumTaxAllowance.value
          : this.maximumTaxAllowance,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppConfiguration(')
          ..write('id: $id, ')
          ..write('maximumTaxAllowance: $maximumTaxAllowance, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, maximumTaxAllowance, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppConfiguration &&
          other.id == this.id &&
          other.maximumTaxAllowance == this.maximumTaxAllowance &&
          other.updatedAt == this.updatedAt);
}

class AppConfigurationsCompanion extends UpdateCompanion<AppConfiguration> {
  final Value<String> id;
  final Value<double> maximumTaxAllowance;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppConfigurationsCompanion({
    this.id = const Value.absent(),
    this.maximumTaxAllowance = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppConfigurationsCompanion.insert({
    required String id,
    this.maximumTaxAllowance = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt);
  static Insertable<AppConfiguration> custom({
    Expression<String>? id,
    Expression<double>? maximumTaxAllowance,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (maximumTaxAllowance != null)
        'maximum_tax_allowance': maximumTaxAllowance,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppConfigurationsCompanion copyWith({
    Value<String>? id,
    Value<double>? maximumTaxAllowance,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppConfigurationsCompanion(
      id: id ?? this.id,
      maximumTaxAllowance: maximumTaxAllowance ?? this.maximumTaxAllowance,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (maximumTaxAllowance.present) {
      map['maximum_tax_allowance'] = Variable<double>(
        maximumTaxAllowance.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppConfigurationsCompanion(')
          ..write('id: $id, ')
          ..write('maximumTaxAllowance: $maximumTaxAllowance, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhysicalAssetsTable extends PhysicalAssets
    with TableInfo<$PhysicalAssetsTable, PhysicalAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhysicalAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Sonstiges'),
  );
  static const VerificationMeta _metalTypeMeta = const VerificationMeta(
    'metalType',
  );
  @override
  late final GeneratedColumn<String> metalType = GeneratedColumn<String>(
    'metal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _weightGramsMeta = const VerificationMeta(
    'weightGrams',
  );
  @override
  late final GeneratedColumn<double> weightGrams = GeneratedColumn<double>(
    'weight_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentValueMeta = const VerificationMeta(
    'currentValue',
  );
  @override
  late final GeneratedColumn<double> currentValue = GeneratedColumn<double>(
    'current_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentPricePerGramMeta =
      const VerificationMeta('currentPricePerGram');
  @override
  late final GeneratedColumn<double> currentPricePerGram =
      GeneratedColumn<double>(
        'current_price_per_gram',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    accountId,
    name,
    category,
    metalType,
    quantity,
    weightGrams,
    purchaseDate,
    purchasePrice,
    currentValue,
    currentPricePerGram,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'physical_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhysicalAsset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
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
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('metal_type')) {
      context.handle(
        _metalTypeMeta,
        metalType.isAcceptableOrUnknown(data['metal_type']!, _metalTypeMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('weight_grams')) {
      context.handle(
        _weightGramsMeta,
        weightGrams.isAcceptableOrUnknown(
          data['weight_grams']!,
          _weightGramsMeta,
        ),
      );
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    }
    if (data.containsKey('current_value')) {
      context.handle(
        _currentValueMeta,
        currentValue.isAcceptableOrUnknown(
          data['current_value']!,
          _currentValueMeta,
        ),
      );
    }
    if (data.containsKey('current_price_per_gram')) {
      context.handle(
        _currentPricePerGramMeta,
        currentPricePerGram.isAcceptableOrUnknown(
          data['current_price_per_gram']!,
          _currentPricePerGramMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhysicalAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhysicalAsset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      metalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metal_type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      weightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_grams'],
      )!,
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      ),
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      )!,
      currentValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_value'],
      )!,
      currentPricePerGram: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_price_per_gram'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PhysicalAssetsTable createAlias(String alias) {
    return $PhysicalAssetsTable(attachedDatabase, alias);
  }
}

class PhysicalAsset extends DataClass implements Insertable<PhysicalAsset> {
  final String id;
  final String userId;
  final String accountId;
  final String name;
  final String category;
  final String metalType;
  final double quantity;
  final double weightGrams;
  final DateTime? purchaseDate;
  final double purchasePrice;
  final double currentValue;
  final double currentPricePerGram;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const PhysicalAsset({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.name,
    required this.category,
    required this.metalType,
    required this.quantity,
    required this.weightGrams,
    this.purchaseDate,
    required this.purchasePrice,
    required this.currentValue,
    required this.currentPricePerGram,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['account_id'] = Variable<String>(accountId);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['metal_type'] = Variable<String>(metalType);
    map['quantity'] = Variable<double>(quantity);
    map['weight_grams'] = Variable<double>(weightGrams);
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate);
    }
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['current_value'] = Variable<double>(currentValue);
    map['current_price_per_gram'] = Variable<double>(currentPricePerGram);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PhysicalAssetsCompanion toCompanion(bool nullToAbsent) {
    return PhysicalAssetsCompanion(
      id: Value(id),
      userId: Value(userId),
      accountId: Value(accountId),
      name: Value(name),
      category: Value(category),
      metalType: Value(metalType),
      quantity: Value(quantity),
      weightGrams: Value(weightGrams),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      purchasePrice: Value(purchasePrice),
      currentValue: Value(currentValue),
      currentPricePerGram: Value(currentPricePerGram),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PhysicalAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhysicalAsset(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      metalType: serializer.fromJson<String>(json['metalType']),
      quantity: serializer.fromJson<double>(json['quantity']),
      weightGrams: serializer.fromJson<double>(json['weightGrams']),
      purchaseDate: serializer.fromJson<DateTime?>(json['purchaseDate']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      currentValue: serializer.fromJson<double>(json['currentValue']),
      currentPricePerGram: serializer.fromJson<double>(
        json['currentPricePerGram'],
      ),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'accountId': serializer.toJson<String>(accountId),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'metalType': serializer.toJson<String>(metalType),
      'quantity': serializer.toJson<double>(quantity),
      'weightGrams': serializer.toJson<double>(weightGrams),
      'purchaseDate': serializer.toJson<DateTime?>(purchaseDate),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'currentValue': serializer.toJson<double>(currentValue),
      'currentPricePerGram': serializer.toJson<double>(currentPricePerGram),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  PhysicalAsset copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? name,
    String? category,
    String? metalType,
    double? quantity,
    double? weightGrams,
    Value<DateTime?> purchaseDate = const Value.absent(),
    double? purchasePrice,
    double? currentValue,
    double? currentPricePerGram,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => PhysicalAsset(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    accountId: accountId ?? this.accountId,
    name: name ?? this.name,
    category: category ?? this.category,
    metalType: metalType ?? this.metalType,
    quantity: quantity ?? this.quantity,
    weightGrams: weightGrams ?? this.weightGrams,
    purchaseDate: purchaseDate.present ? purchaseDate.value : this.purchaseDate,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    currentValue: currentValue ?? this.currentValue,
    currentPricePerGram: currentPricePerGram ?? this.currentPricePerGram,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  PhysicalAsset copyWithCompanion(PhysicalAssetsCompanion data) {
    return PhysicalAsset(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      metalType: data.metalType.present ? data.metalType.value : this.metalType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      weightGrams: data.weightGrams.present
          ? data.weightGrams.value
          : this.weightGrams,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      currentPricePerGram: data.currentPricePerGram.present
          ? data.currentPricePerGram.value
          : this.currentPricePerGram,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhysicalAsset(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('metalType: $metalType, ')
          ..write('quantity: $quantity, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('currentValue: $currentValue, ')
          ..write('currentPricePerGram: $currentPricePerGram, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    accountId,
    name,
    category,
    metalType,
    quantity,
    weightGrams,
    purchaseDate,
    purchasePrice,
    currentValue,
    currentPricePerGram,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhysicalAsset &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.accountId == this.accountId &&
          other.name == this.name &&
          other.category == this.category &&
          other.metalType == this.metalType &&
          other.quantity == this.quantity &&
          other.weightGrams == this.weightGrams &&
          other.purchaseDate == this.purchaseDate &&
          other.purchasePrice == this.purchasePrice &&
          other.currentValue == this.currentValue &&
          other.currentPricePerGram == this.currentPricePerGram &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PhysicalAssetsCompanion extends UpdateCompanion<PhysicalAsset> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> accountId;
  final Value<String> name;
  final Value<String> category;
  final Value<String> metalType;
  final Value<double> quantity;
  final Value<double> weightGrams;
  final Value<DateTime?> purchaseDate;
  final Value<double> purchasePrice;
  final Value<double> currentValue;
  final Value<double> currentPricePerGram;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PhysicalAssetsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.metalType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.weightGrams = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.currentPricePerGram = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhysicalAssetsCompanion.insert({
    required String id,
    required String userId,
    this.accountId = const Value.absent(),
    required String name,
    this.category = const Value.absent(),
    this.metalType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.weightGrams = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.currentPricePerGram = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PhysicalAsset> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? accountId,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? metalType,
    Expression<double>? quantity,
    Expression<double>? weightGrams,
    Expression<DateTime>? purchaseDate,
    Expression<double>? purchasePrice,
    Expression<double>? currentValue,
    Expression<double>? currentPricePerGram,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (accountId != null) 'account_id': accountId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (metalType != null) 'metal_type': metalType,
      if (quantity != null) 'quantity': quantity,
      if (weightGrams != null) 'weight_grams': weightGrams,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (currentValue != null) 'current_value': currentValue,
      if (currentPricePerGram != null)
        'current_price_per_gram': currentPricePerGram,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhysicalAssetsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? accountId,
    Value<String>? name,
    Value<String>? category,
    Value<String>? metalType,
    Value<double>? quantity,
    Value<double>? weightGrams,
    Value<DateTime?>? purchaseDate,
    Value<double>? purchasePrice,
    Value<double>? currentValue,
    Value<double>? currentPricePerGram,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PhysicalAssetsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      category: category ?? this.category,
      metalType: metalType ?? this.metalType,
      quantity: quantity ?? this.quantity,
      weightGrams: weightGrams ?? this.weightGrams,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentValue: currentValue ?? this.currentValue,
      currentPricePerGram: currentPricePerGram ?? this.currentPricePerGram,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (metalType.present) {
      map['metal_type'] = Variable<String>(metalType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (weightGrams.present) {
      map['weight_grams'] = Variable<double>(weightGrams.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<double>(currentValue.value);
    }
    if (currentPricePerGram.present) {
      map['current_price_per_gram'] = Variable<double>(
        currentPricePerGram.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhysicalAssetsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('metalType: $metalType, ')
          ..write('quantity: $quantity, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('currentValue: $currentValue, ')
          ..write('currentPricePerGram: $currentPricePerGram, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PortfolioSalesTable extends PortfolioSales
    with TableInfo<$PortfolioSalesTable, PortfolioSale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PortfolioSalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _destinationAccountIdMeta =
      const VerificationMeta('destinationAccountId');
  @override
  late final GeneratedColumn<String> destinationAccountId =
      GeneratedColumn<String>(
        'destination_account_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _accountCreditedMeta = const VerificationMeta(
    'accountCredited',
  );
  @override
  late final GeneratedColumn<bool> accountCredited = GeneratedColumn<bool>(
    'account_credited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("account_credited" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sourceCurrencyMeta = const VerificationMeta(
    'sourceCurrency',
  );
  @override
  late final GeneratedColumn<String> sourceCurrency = GeneratedColumn<String>(
    'source_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _exchangeRateMeta = const VerificationMeta(
    'exchangeRate',
  );
  @override
  late final GeneratedColumn<double> exchangeRate = GeneratedColumn<double>(
    'exchange_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _investmentIdMeta = const VerificationMeta(
    'investmentId',
  );
  @override
  late final GeneratedColumn<String> investmentId = GeneratedColumn<String>(
    'investment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _physicalAssetIdMeta = const VerificationMeta(
    'physicalAssetId',
  );
  @override
  late final GeneratedColumn<String> physicalAssetId = GeneratedColumn<String>(
    'physical_asset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assetNameMeta = const VerificationMeta(
    'assetName',
  );
  @override
  late final GeneratedColumn<String> assetName = GeneratedColumn<String>(
    'asset_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetKindMeta = const VerificationMeta(
    'assetKind',
  );
  @override
  late final GeneratedColumn<String> assetKind = GeneratedColumn<String>(
    'asset_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerUnitMeta = const VerificationMeta(
    'pricePerUnit',
  );
  @override
  late final GeneratedColumn<double> pricePerUnit = GeneratedColumn<double>(
    'price_per_unit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feesMeta = const VerificationMeta('fees');
  @override
  late final GeneratedColumn<double> fees = GeneratedColumn<double>(
    'fees',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _proceedsMeta = const VerificationMeta(
    'proceeds',
  );
  @override
  late final GeneratedColumn<double> proceeds = GeneratedColumn<double>(
    'proceeds',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costBasisMeta = const VerificationMeta(
    'costBasis',
  );
  @override
  late final GeneratedColumn<double> costBasis = GeneratedColumn<double>(
    'cost_basis',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _realizedGainMeta = const VerificationMeta(
    'realizedGain',
  );
  @override
  late final GeneratedColumn<double> realizedGain = GeneratedColumn<double>(
    'realized_gain',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _allowanceUsedMeta = const VerificationMeta(
    'allowanceUsed',
  );
  @override
  late final GeneratedColumn<double> allowanceUsed = GeneratedColumn<double>(
    'allowance_used',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _taxPaidMeta = const VerificationMeta(
    'taxPaid',
  );
  @override
  late final GeneratedColumn<double> taxPaid = GeneratedColumn<double>(
    'tax_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _soldAtMeta = const VerificationMeta('soldAt');
  @override
  late final GeneratedColumn<DateTime> soldAt = GeneratedColumn<DateTime>(
    'sold_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    accountId,
    destinationAccountId,
    accountCredited,
    sourceCurrency,
    exchangeRate,
    investmentId,
    physicalAssetId,
    assetName,
    assetKind,
    quantity,
    unit,
    pricePerUnit,
    fees,
    proceeds,
    costBasis,
    realizedGain,
    allowanceUsed,
    taxPaid,
    soldAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'portfolio_sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<PortfolioSale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('destination_account_id')) {
      context.handle(
        _destinationAccountIdMeta,
        destinationAccountId.isAcceptableOrUnknown(
          data['destination_account_id']!,
          _destinationAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('account_credited')) {
      context.handle(
        _accountCreditedMeta,
        accountCredited.isAcceptableOrUnknown(
          data['account_credited']!,
          _accountCreditedMeta,
        ),
      );
    }
    if (data.containsKey('source_currency')) {
      context.handle(
        _sourceCurrencyMeta,
        sourceCurrency.isAcceptableOrUnknown(
          data['source_currency']!,
          _sourceCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('exchange_rate')) {
      context.handle(
        _exchangeRateMeta,
        exchangeRate.isAcceptableOrUnknown(
          data['exchange_rate']!,
          _exchangeRateMeta,
        ),
      );
    }
    if (data.containsKey('investment_id')) {
      context.handle(
        _investmentIdMeta,
        investmentId.isAcceptableOrUnknown(
          data['investment_id']!,
          _investmentIdMeta,
        ),
      );
    }
    if (data.containsKey('physical_asset_id')) {
      context.handle(
        _physicalAssetIdMeta,
        physicalAssetId.isAcceptableOrUnknown(
          data['physical_asset_id']!,
          _physicalAssetIdMeta,
        ),
      );
    }
    if (data.containsKey('asset_name')) {
      context.handle(
        _assetNameMeta,
        assetName.isAcceptableOrUnknown(data['asset_name']!, _assetNameMeta),
      );
    } else if (isInserting) {
      context.missing(_assetNameMeta);
    }
    if (data.containsKey('asset_kind')) {
      context.handle(
        _assetKindMeta,
        assetKind.isAcceptableOrUnknown(data['asset_kind']!, _assetKindMeta),
      );
    } else if (isInserting) {
      context.missing(_assetKindMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('price_per_unit')) {
      context.handle(
        _pricePerUnitMeta,
        pricePerUnit.isAcceptableOrUnknown(
          data['price_per_unit']!,
          _pricePerUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerUnitMeta);
    }
    if (data.containsKey('fees')) {
      context.handle(
        _feesMeta,
        fees.isAcceptableOrUnknown(data['fees']!, _feesMeta),
      );
    }
    if (data.containsKey('proceeds')) {
      context.handle(
        _proceedsMeta,
        proceeds.isAcceptableOrUnknown(data['proceeds']!, _proceedsMeta),
      );
    } else if (isInserting) {
      context.missing(_proceedsMeta);
    }
    if (data.containsKey('cost_basis')) {
      context.handle(
        _costBasisMeta,
        costBasis.isAcceptableOrUnknown(data['cost_basis']!, _costBasisMeta),
      );
    }
    if (data.containsKey('realized_gain')) {
      context.handle(
        _realizedGainMeta,
        realizedGain.isAcceptableOrUnknown(
          data['realized_gain']!,
          _realizedGainMeta,
        ),
      );
    }
    if (data.containsKey('allowance_used')) {
      context.handle(
        _allowanceUsedMeta,
        allowanceUsed.isAcceptableOrUnknown(
          data['allowance_used']!,
          _allowanceUsedMeta,
        ),
      );
    }
    if (data.containsKey('tax_paid')) {
      context.handle(
        _taxPaidMeta,
        taxPaid.isAcceptableOrUnknown(data['tax_paid']!, _taxPaidMeta),
      );
    }
    if (data.containsKey('sold_at')) {
      context.handle(
        _soldAtMeta,
        soldAt.isAcceptableOrUnknown(data['sold_at']!, _soldAtMeta),
      );
    } else if (isInserting) {
      context.missing(_soldAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PortfolioSale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PortfolioSale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      destinationAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_account_id'],
      ),
      accountCredited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}account_credited'],
      )!,
      sourceCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_currency'],
      )!,
      exchangeRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}exchange_rate'],
      )!,
      investmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}investment_id'],
      ),
      physicalAssetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}physical_asset_id'],
      ),
      assetName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_name'],
      )!,
      assetKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_kind'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      pricePerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_per_unit'],
      )!,
      fees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fees'],
      )!,
      proceeds: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}proceeds'],
      )!,
      costBasis: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_basis'],
      )!,
      realizedGain: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}realized_gain'],
      )!,
      allowanceUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}allowance_used'],
      )!,
      taxPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_paid'],
      )!,
      soldAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sold_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PortfolioSalesTable createAlias(String alias) {
    return $PortfolioSalesTable(attachedDatabase, alias);
  }
}

class PortfolioSale extends DataClass implements Insertable<PortfolioSale> {
  final String id;
  final String userId;
  final String accountId;
  final String? destinationAccountId;
  final bool accountCredited;
  final String sourceCurrency;
  final double exchangeRate;
  final String? investmentId;
  final String? physicalAssetId;
  final String assetName;
  final String assetKind;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double fees;
  final double proceeds;
  final double costBasis;
  final double realizedGain;
  final double allowanceUsed;
  final double taxPaid;
  final DateTime soldAt;
  final DateTime createdAt;
  const PortfolioSale({
    required this.id,
    required this.userId,
    required this.accountId,
    this.destinationAccountId,
    required this.accountCredited,
    required this.sourceCurrency,
    required this.exchangeRate,
    this.investmentId,
    this.physicalAssetId,
    required this.assetName,
    required this.assetKind,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.fees,
    required this.proceeds,
    required this.costBasis,
    required this.realizedGain,
    required this.allowanceUsed,
    required this.taxPaid,
    required this.soldAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || destinationAccountId != null) {
      map['destination_account_id'] = Variable<String>(destinationAccountId);
    }
    map['account_credited'] = Variable<bool>(accountCredited);
    map['source_currency'] = Variable<String>(sourceCurrency);
    map['exchange_rate'] = Variable<double>(exchangeRate);
    if (!nullToAbsent || investmentId != null) {
      map['investment_id'] = Variable<String>(investmentId);
    }
    if (!nullToAbsent || physicalAssetId != null) {
      map['physical_asset_id'] = Variable<String>(physicalAssetId);
    }
    map['asset_name'] = Variable<String>(assetName);
    map['asset_kind'] = Variable<String>(assetKind);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    map['price_per_unit'] = Variable<double>(pricePerUnit);
    map['fees'] = Variable<double>(fees);
    map['proceeds'] = Variable<double>(proceeds);
    map['cost_basis'] = Variable<double>(costBasis);
    map['realized_gain'] = Variable<double>(realizedGain);
    map['allowance_used'] = Variable<double>(allowanceUsed);
    map['tax_paid'] = Variable<double>(taxPaid);
    map['sold_at'] = Variable<DateTime>(soldAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PortfolioSalesCompanion toCompanion(bool nullToAbsent) {
    return PortfolioSalesCompanion(
      id: Value(id),
      userId: Value(userId),
      accountId: Value(accountId),
      destinationAccountId: destinationAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAccountId),
      accountCredited: Value(accountCredited),
      sourceCurrency: Value(sourceCurrency),
      exchangeRate: Value(exchangeRate),
      investmentId: investmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(investmentId),
      physicalAssetId: physicalAssetId == null && nullToAbsent
          ? const Value.absent()
          : Value(physicalAssetId),
      assetName: Value(assetName),
      assetKind: Value(assetKind),
      quantity: Value(quantity),
      unit: Value(unit),
      pricePerUnit: Value(pricePerUnit),
      fees: Value(fees),
      proceeds: Value(proceeds),
      costBasis: Value(costBasis),
      realizedGain: Value(realizedGain),
      allowanceUsed: Value(allowanceUsed),
      taxPaid: Value(taxPaid),
      soldAt: Value(soldAt),
      createdAt: Value(createdAt),
    );
  }

  factory PortfolioSale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PortfolioSale(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      destinationAccountId: serializer.fromJson<String?>(
        json['destinationAccountId'],
      ),
      accountCredited: serializer.fromJson<bool>(json['accountCredited']),
      sourceCurrency: serializer.fromJson<String>(json['sourceCurrency']),
      exchangeRate: serializer.fromJson<double>(json['exchangeRate']),
      investmentId: serializer.fromJson<String?>(json['investmentId']),
      physicalAssetId: serializer.fromJson<String?>(json['physicalAssetId']),
      assetName: serializer.fromJson<String>(json['assetName']),
      assetKind: serializer.fromJson<String>(json['assetKind']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      pricePerUnit: serializer.fromJson<double>(json['pricePerUnit']),
      fees: serializer.fromJson<double>(json['fees']),
      proceeds: serializer.fromJson<double>(json['proceeds']),
      costBasis: serializer.fromJson<double>(json['costBasis']),
      realizedGain: serializer.fromJson<double>(json['realizedGain']),
      allowanceUsed: serializer.fromJson<double>(json['allowanceUsed']),
      taxPaid: serializer.fromJson<double>(json['taxPaid']),
      soldAt: serializer.fromJson<DateTime>(json['soldAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'accountId': serializer.toJson<String>(accountId),
      'destinationAccountId': serializer.toJson<String?>(destinationAccountId),
      'accountCredited': serializer.toJson<bool>(accountCredited),
      'sourceCurrency': serializer.toJson<String>(sourceCurrency),
      'exchangeRate': serializer.toJson<double>(exchangeRate),
      'investmentId': serializer.toJson<String?>(investmentId),
      'physicalAssetId': serializer.toJson<String?>(physicalAssetId),
      'assetName': serializer.toJson<String>(assetName),
      'assetKind': serializer.toJson<String>(assetKind),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'pricePerUnit': serializer.toJson<double>(pricePerUnit),
      'fees': serializer.toJson<double>(fees),
      'proceeds': serializer.toJson<double>(proceeds),
      'costBasis': serializer.toJson<double>(costBasis),
      'realizedGain': serializer.toJson<double>(realizedGain),
      'allowanceUsed': serializer.toJson<double>(allowanceUsed),
      'taxPaid': serializer.toJson<double>(taxPaid),
      'soldAt': serializer.toJson<DateTime>(soldAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PortfolioSale copyWith({
    String? id,
    String? userId,
    String? accountId,
    Value<String?> destinationAccountId = const Value.absent(),
    bool? accountCredited,
    String? sourceCurrency,
    double? exchangeRate,
    Value<String?> investmentId = const Value.absent(),
    Value<String?> physicalAssetId = const Value.absent(),
    String? assetName,
    String? assetKind,
    double? quantity,
    String? unit,
    double? pricePerUnit,
    double? fees,
    double? proceeds,
    double? costBasis,
    double? realizedGain,
    double? allowanceUsed,
    double? taxPaid,
    DateTime? soldAt,
    DateTime? createdAt,
  }) => PortfolioSale(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    accountId: accountId ?? this.accountId,
    destinationAccountId: destinationAccountId.present
        ? destinationAccountId.value
        : this.destinationAccountId,
    accountCredited: accountCredited ?? this.accountCredited,
    sourceCurrency: sourceCurrency ?? this.sourceCurrency,
    exchangeRate: exchangeRate ?? this.exchangeRate,
    investmentId: investmentId.present ? investmentId.value : this.investmentId,
    physicalAssetId: physicalAssetId.present
        ? physicalAssetId.value
        : this.physicalAssetId,
    assetName: assetName ?? this.assetName,
    assetKind: assetKind ?? this.assetKind,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    pricePerUnit: pricePerUnit ?? this.pricePerUnit,
    fees: fees ?? this.fees,
    proceeds: proceeds ?? this.proceeds,
    costBasis: costBasis ?? this.costBasis,
    realizedGain: realizedGain ?? this.realizedGain,
    allowanceUsed: allowanceUsed ?? this.allowanceUsed,
    taxPaid: taxPaid ?? this.taxPaid,
    soldAt: soldAt ?? this.soldAt,
    createdAt: createdAt ?? this.createdAt,
  );
  PortfolioSale copyWithCompanion(PortfolioSalesCompanion data) {
    return PortfolioSale(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      destinationAccountId: data.destinationAccountId.present
          ? data.destinationAccountId.value
          : this.destinationAccountId,
      accountCredited: data.accountCredited.present
          ? data.accountCredited.value
          : this.accountCredited,
      sourceCurrency: data.sourceCurrency.present
          ? data.sourceCurrency.value
          : this.sourceCurrency,
      exchangeRate: data.exchangeRate.present
          ? data.exchangeRate.value
          : this.exchangeRate,
      investmentId: data.investmentId.present
          ? data.investmentId.value
          : this.investmentId,
      physicalAssetId: data.physicalAssetId.present
          ? data.physicalAssetId.value
          : this.physicalAssetId,
      assetName: data.assetName.present ? data.assetName.value : this.assetName,
      assetKind: data.assetKind.present ? data.assetKind.value : this.assetKind,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      pricePerUnit: data.pricePerUnit.present
          ? data.pricePerUnit.value
          : this.pricePerUnit,
      fees: data.fees.present ? data.fees.value : this.fees,
      proceeds: data.proceeds.present ? data.proceeds.value : this.proceeds,
      costBasis: data.costBasis.present ? data.costBasis.value : this.costBasis,
      realizedGain: data.realizedGain.present
          ? data.realizedGain.value
          : this.realizedGain,
      allowanceUsed: data.allowanceUsed.present
          ? data.allowanceUsed.value
          : this.allowanceUsed,
      taxPaid: data.taxPaid.present ? data.taxPaid.value : this.taxPaid,
      soldAt: data.soldAt.present ? data.soldAt.value : this.soldAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PortfolioSale(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('accountCredited: $accountCredited, ')
          ..write('sourceCurrency: $sourceCurrency, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('investmentId: $investmentId, ')
          ..write('physicalAssetId: $physicalAssetId, ')
          ..write('assetName: $assetName, ')
          ..write('assetKind: $assetKind, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('fees: $fees, ')
          ..write('proceeds: $proceeds, ')
          ..write('costBasis: $costBasis, ')
          ..write('realizedGain: $realizedGain, ')
          ..write('allowanceUsed: $allowanceUsed, ')
          ..write('taxPaid: $taxPaid, ')
          ..write('soldAt: $soldAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    accountId,
    destinationAccountId,
    accountCredited,
    sourceCurrency,
    exchangeRate,
    investmentId,
    physicalAssetId,
    assetName,
    assetKind,
    quantity,
    unit,
    pricePerUnit,
    fees,
    proceeds,
    costBasis,
    realizedGain,
    allowanceUsed,
    taxPaid,
    soldAt,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PortfolioSale &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.accountId == this.accountId &&
          other.destinationAccountId == this.destinationAccountId &&
          other.accountCredited == this.accountCredited &&
          other.sourceCurrency == this.sourceCurrency &&
          other.exchangeRate == this.exchangeRate &&
          other.investmentId == this.investmentId &&
          other.physicalAssetId == this.physicalAssetId &&
          other.assetName == this.assetName &&
          other.assetKind == this.assetKind &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.pricePerUnit == this.pricePerUnit &&
          other.fees == this.fees &&
          other.proceeds == this.proceeds &&
          other.costBasis == this.costBasis &&
          other.realizedGain == this.realizedGain &&
          other.allowanceUsed == this.allowanceUsed &&
          other.taxPaid == this.taxPaid &&
          other.soldAt == this.soldAt &&
          other.createdAt == this.createdAt);
}

class PortfolioSalesCompanion extends UpdateCompanion<PortfolioSale> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> accountId;
  final Value<String?> destinationAccountId;
  final Value<bool> accountCredited;
  final Value<String> sourceCurrency;
  final Value<double> exchangeRate;
  final Value<String?> investmentId;
  final Value<String?> physicalAssetId;
  final Value<String> assetName;
  final Value<String> assetKind;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<double> pricePerUnit;
  final Value<double> fees;
  final Value<double> proceeds;
  final Value<double> costBasis;
  final Value<double> realizedGain;
  final Value<double> allowanceUsed;
  final Value<double> taxPaid;
  final Value<DateTime> soldAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PortfolioSalesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    this.accountCredited = const Value.absent(),
    this.sourceCurrency = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.investmentId = const Value.absent(),
    this.physicalAssetId = const Value.absent(),
    this.assetName = const Value.absent(),
    this.assetKind = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.pricePerUnit = const Value.absent(),
    this.fees = const Value.absent(),
    this.proceeds = const Value.absent(),
    this.costBasis = const Value.absent(),
    this.realizedGain = const Value.absent(),
    this.allowanceUsed = const Value.absent(),
    this.taxPaid = const Value.absent(),
    this.soldAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PortfolioSalesCompanion.insert({
    required String id,
    required String userId,
    required String accountId,
    this.destinationAccountId = const Value.absent(),
    this.accountCredited = const Value.absent(),
    this.sourceCurrency = const Value.absent(),
    this.exchangeRate = const Value.absent(),
    this.investmentId = const Value.absent(),
    this.physicalAssetId = const Value.absent(),
    required String assetName,
    required String assetKind,
    required double quantity,
    required String unit,
    required double pricePerUnit,
    this.fees = const Value.absent(),
    required double proceeds,
    this.costBasis = const Value.absent(),
    this.realizedGain = const Value.absent(),
    this.allowanceUsed = const Value.absent(),
    this.taxPaid = const Value.absent(),
    required DateTime soldAt,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       accountId = Value(accountId),
       assetName = Value(assetName),
       assetKind = Value(assetKind),
       quantity = Value(quantity),
       unit = Value(unit),
       pricePerUnit = Value(pricePerUnit),
       proceeds = Value(proceeds),
       soldAt = Value(soldAt),
       createdAt = Value(createdAt);
  static Insertable<PortfolioSale> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? accountId,
    Expression<String>? destinationAccountId,
    Expression<bool>? accountCredited,
    Expression<String>? sourceCurrency,
    Expression<double>? exchangeRate,
    Expression<String>? investmentId,
    Expression<String>? physicalAssetId,
    Expression<String>? assetName,
    Expression<String>? assetKind,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<double>? pricePerUnit,
    Expression<double>? fees,
    Expression<double>? proceeds,
    Expression<double>? costBasis,
    Expression<double>? realizedGain,
    Expression<double>? allowanceUsed,
    Expression<double>? taxPaid,
    Expression<DateTime>? soldAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (accountId != null) 'account_id': accountId,
      if (destinationAccountId != null)
        'destination_account_id': destinationAccountId,
      if (accountCredited != null) 'account_credited': accountCredited,
      if (sourceCurrency != null) 'source_currency': sourceCurrency,
      if (exchangeRate != null) 'exchange_rate': exchangeRate,
      if (investmentId != null) 'investment_id': investmentId,
      if (physicalAssetId != null) 'physical_asset_id': physicalAssetId,
      if (assetName != null) 'asset_name': assetName,
      if (assetKind != null) 'asset_kind': assetKind,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (pricePerUnit != null) 'price_per_unit': pricePerUnit,
      if (fees != null) 'fees': fees,
      if (proceeds != null) 'proceeds': proceeds,
      if (costBasis != null) 'cost_basis': costBasis,
      if (realizedGain != null) 'realized_gain': realizedGain,
      if (allowanceUsed != null) 'allowance_used': allowanceUsed,
      if (taxPaid != null) 'tax_paid': taxPaid,
      if (soldAt != null) 'sold_at': soldAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PortfolioSalesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? accountId,
    Value<String?>? destinationAccountId,
    Value<bool>? accountCredited,
    Value<String>? sourceCurrency,
    Value<double>? exchangeRate,
    Value<String?>? investmentId,
    Value<String?>? physicalAssetId,
    Value<String>? assetName,
    Value<String>? assetKind,
    Value<double>? quantity,
    Value<String>? unit,
    Value<double>? pricePerUnit,
    Value<double>? fees,
    Value<double>? proceeds,
    Value<double>? costBasis,
    Value<double>? realizedGain,
    Value<double>? allowanceUsed,
    Value<double>? taxPaid,
    Value<DateTime>? soldAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PortfolioSalesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      accountCredited: accountCredited ?? this.accountCredited,
      sourceCurrency: sourceCurrency ?? this.sourceCurrency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      investmentId: investmentId ?? this.investmentId,
      physicalAssetId: physicalAssetId ?? this.physicalAssetId,
      assetName: assetName ?? this.assetName,
      assetKind: assetKind ?? this.assetKind,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      fees: fees ?? this.fees,
      proceeds: proceeds ?? this.proceeds,
      costBasis: costBasis ?? this.costBasis,
      realizedGain: realizedGain ?? this.realizedGain,
      allowanceUsed: allowanceUsed ?? this.allowanceUsed,
      taxPaid: taxPaid ?? this.taxPaid,
      soldAt: soldAt ?? this.soldAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (destinationAccountId.present) {
      map['destination_account_id'] = Variable<String>(
        destinationAccountId.value,
      );
    }
    if (accountCredited.present) {
      map['account_credited'] = Variable<bool>(accountCredited.value);
    }
    if (sourceCurrency.present) {
      map['source_currency'] = Variable<String>(sourceCurrency.value);
    }
    if (exchangeRate.present) {
      map['exchange_rate'] = Variable<double>(exchangeRate.value);
    }
    if (investmentId.present) {
      map['investment_id'] = Variable<String>(investmentId.value);
    }
    if (physicalAssetId.present) {
      map['physical_asset_id'] = Variable<String>(physicalAssetId.value);
    }
    if (assetName.present) {
      map['asset_name'] = Variable<String>(assetName.value);
    }
    if (assetKind.present) {
      map['asset_kind'] = Variable<String>(assetKind.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (pricePerUnit.present) {
      map['price_per_unit'] = Variable<double>(pricePerUnit.value);
    }
    if (fees.present) {
      map['fees'] = Variable<double>(fees.value);
    }
    if (proceeds.present) {
      map['proceeds'] = Variable<double>(proceeds.value);
    }
    if (costBasis.present) {
      map['cost_basis'] = Variable<double>(costBasis.value);
    }
    if (realizedGain.present) {
      map['realized_gain'] = Variable<double>(realizedGain.value);
    }
    if (allowanceUsed.present) {
      map['allowance_used'] = Variable<double>(allowanceUsed.value);
    }
    if (taxPaid.present) {
      map['tax_paid'] = Variable<double>(taxPaid.value);
    }
    if (soldAt.present) {
      map['sold_at'] = Variable<DateTime>(soldAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PortfolioSalesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('accountCredited: $accountCredited, ')
          ..write('sourceCurrency: $sourceCurrency, ')
          ..write('exchangeRate: $exchangeRate, ')
          ..write('investmentId: $investmentId, ')
          ..write('physicalAssetId: $physicalAssetId, ')
          ..write('assetName: $assetName, ')
          ..write('assetKind: $assetKind, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('fees: $fees, ')
          ..write('proceeds: $proceeds, ')
          ..write('costBasis: $costBasis, ')
          ..write('realizedGain: $realizedGain, ')
          ..write('allowanceUsed: $allowanceUsed, ')
          ..write('taxPaid: $taxPaid, ')
          ..write('soldAt: $soldAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PortfolioAuditLogsTable extends PortfolioAuditLogs
    with TableInfo<$PortfolioAuditLogsTable, PortfolioAuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PortfolioAuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    action,
    entityType,
    entityId,
    displayName,
    details,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'portfolio_audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PortfolioAuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PortfolioAuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PortfolioAuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $PortfolioAuditLogsTable createAlias(String alias) {
    return $PortfolioAuditLogsTable(attachedDatabase, alias);
  }
}

class PortfolioAuditLog extends DataClass
    implements Insertable<PortfolioAuditLog> {
  final String id;
  final String userId;
  final String action;
  final String entityType;
  final String entityId;
  final String displayName;
  final String details;
  final DateTime occurredAt;
  const PortfolioAuditLog({
    required this.id,
    required this.userId,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.displayName,
    required this.details,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['action'] = Variable<String>(action);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['display_name'] = Variable<String>(displayName);
    map['details'] = Variable<String>(details);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  PortfolioAuditLogsCompanion toCompanion(bool nullToAbsent) {
    return PortfolioAuditLogsCompanion(
      id: Value(id),
      userId: Value(userId),
      action: Value(action),
      entityType: Value(entityType),
      entityId: Value(entityId),
      displayName: Value(displayName),
      details: Value(details),
      occurredAt: Value(occurredAt),
    );
  }

  factory PortfolioAuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PortfolioAuditLog(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      action: serializer.fromJson<String>(json['action']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      details: serializer.fromJson<String>(json['details']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'action': serializer.toJson<String>(action),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'displayName': serializer.toJson<String>(displayName),
      'details': serializer.toJson<String>(details),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  PortfolioAuditLog copyWith({
    String? id,
    String? userId,
    String? action,
    String? entityType,
    String? entityId,
    String? displayName,
    String? details,
    DateTime? occurredAt,
  }) => PortfolioAuditLog(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    action: action ?? this.action,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    displayName: displayName ?? this.displayName,
    details: details ?? this.details,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  PortfolioAuditLog copyWithCompanion(PortfolioAuditLogsCompanion data) {
    return PortfolioAuditLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      action: data.action.present ? data.action.value : this.action,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      details: data.details.present ? data.details.value : this.details,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PortfolioAuditLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('displayName: $displayName, ')
          ..write('details: $details, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    action,
    entityType,
    entityId,
    displayName,
    details,
    occurredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PortfolioAuditLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.displayName == this.displayName &&
          other.details == this.details &&
          other.occurredAt == this.occurredAt);
}

class PortfolioAuditLogsCompanion extends UpdateCompanion<PortfolioAuditLog> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> action;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> displayName;
  final Value<String> details;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const PortfolioAuditLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.details = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PortfolioAuditLogsCompanion.insert({
    required String id,
    required String userId,
    required String action,
    required String entityType,
    required String entityId,
    required String displayName,
    this.details = const Value.absent(),
    required DateTime occurredAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       action = Value(action),
       entityType = Value(entityType),
       entityId = Value(entityId),
       displayName = Value(displayName),
       occurredAt = Value(occurredAt);
  static Insertable<PortfolioAuditLog> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? action,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? displayName,
    Expression<String>? details,
    Expression<DateTime>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (displayName != null) 'display_name': displayName,
      if (details != null) 'details': details,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PortfolioAuditLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? action,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? displayName,
    Value<String>? details,
    Value<DateTime>? occurredAt,
    Value<int>? rowid,
  }) {
    return PortfolioAuditLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      displayName: displayName ?? this.displayName,
      details: details ?? this.details,
      occurredAt: occurredAt ?? this.occurredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PortfolioAuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('displayName: $displayName, ')
          ..write('details: $details, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppErrorLogsTable extends AppErrorLogs
    with TableInfo<$AppErrorLogsTable, AppErrorLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppErrorLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _stackTraceMeta = const VerificationMeta(
    'stackTrace',
  );
  @override
  late final GeneratedColumn<String> stackTrace = GeneratedColumn<String>(
    'stack_trace',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    source,
    message,
    details,
    stackTrace,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_error_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppErrorLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('stack_trace')) {
      context.handle(
        _stackTraceMeta,
        stackTrace.isAcceptableOrUnknown(data['stack_trace']!, _stackTraceMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppErrorLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppErrorLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      )!,
      stackTrace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stack_trace'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $AppErrorLogsTable createAlias(String alias) {
    return $AppErrorLogsTable(attachedDatabase, alias);
  }
}

class AppErrorLog extends DataClass implements Insertable<AppErrorLog> {
  final String id;
  final String? userId;
  final String source;
  final String message;
  final String details;
  final String stackTrace;
  final DateTime occurredAt;
  const AppErrorLog({
    required this.id,
    this.userId,
    required this.source,
    required this.message,
    required this.details,
    required this.stackTrace,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['source'] = Variable<String>(source);
    map['message'] = Variable<String>(message);
    map['details'] = Variable<String>(details);
    map['stack_trace'] = Variable<String>(stackTrace);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  AppErrorLogsCompanion toCompanion(bool nullToAbsent) {
    return AppErrorLogsCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      source: Value(source),
      message: Value(message),
      details: Value(details),
      stackTrace: Value(stackTrace),
      occurredAt: Value(occurredAt),
    );
  }

  factory AppErrorLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppErrorLog(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      source: serializer.fromJson<String>(json['source']),
      message: serializer.fromJson<String>(json['message']),
      details: serializer.fromJson<String>(json['details']),
      stackTrace: serializer.fromJson<String>(json['stackTrace']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'source': serializer.toJson<String>(source),
      'message': serializer.toJson<String>(message),
      'details': serializer.toJson<String>(details),
      'stackTrace': serializer.toJson<String>(stackTrace),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  AppErrorLog copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    String? source,
    String? message,
    String? details,
    String? stackTrace,
    DateTime? occurredAt,
  }) => AppErrorLog(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    source: source ?? this.source,
    message: message ?? this.message,
    details: details ?? this.details,
    stackTrace: stackTrace ?? this.stackTrace,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  AppErrorLog copyWithCompanion(AppErrorLogsCompanion data) {
    return AppErrorLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      source: data.source.present ? data.source.value : this.source,
      message: data.message.present ? data.message.value : this.message,
      details: data.details.present ? data.details.value : this.details,
      stackTrace: data.stackTrace.present
          ? data.stackTrace.value
          : this.stackTrace,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppErrorLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('source: $source, ')
          ..write('message: $message, ')
          ..write('details: $details, ')
          ..write('stackTrace: $stackTrace, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, source, message, details, stackTrace, occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppErrorLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.source == this.source &&
          other.message == this.message &&
          other.details == this.details &&
          other.stackTrace == this.stackTrace &&
          other.occurredAt == this.occurredAt);
}

class AppErrorLogsCompanion extends UpdateCompanion<AppErrorLog> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> source;
  final Value<String> message;
  final Value<String> details;
  final Value<String> stackTrace;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const AppErrorLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.source = const Value.absent(),
    this.message = const Value.absent(),
    this.details = const Value.absent(),
    this.stackTrace = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppErrorLogsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String source,
    required String message,
    this.details = const Value.absent(),
    this.stackTrace = const Value.absent(),
    required DateTime occurredAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       source = Value(source),
       message = Value(message),
       occurredAt = Value(occurredAt);
  static Insertable<AppErrorLog> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? source,
    Expression<String>? message,
    Expression<String>? details,
    Expression<String>? stackTrace,
    Expression<DateTime>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (source != null) 'source': source,
      if (message != null) 'message': message,
      if (details != null) 'details': details,
      if (stackTrace != null) 'stack_trace': stackTrace,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppErrorLogsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String>? source,
    Value<String>? message,
    Value<String>? details,
    Value<String>? stackTrace,
    Value<DateTime>? occurredAt,
    Value<int>? rowid,
  }) {
    return AppErrorLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      source: source ?? this.source,
      message: message ?? this.message,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      occurredAt: occurredAt ?? this.occurredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (stackTrace.present) {
      map['stack_trace'] = Variable<String>(stackTrace.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppErrorLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('source: $source, ')
          ..write('message: $message, ')
          ..write('details: $details, ')
          ..write('stackTrace: $stackTrace, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $AccountBalanceHistoriesTable accountBalanceHistories =
      $AccountBalanceHistoriesTable(this);
  late final $InvestmentsTable investments = $InvestmentsTable(this);
  late final $InvestmentPurchasesTable investmentPurchases =
      $InvestmentPurchasesTable(this);
  late final $DividendSchedulesTable dividendSchedules =
      $DividendSchedulesTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $MasterDataTable masterData = $MasterDataTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $VehicleCostsTable vehicleCosts = $VehicleCostsTable(this);
  late final $UserPreferencesTable userPreferences = $UserPreferencesTable(
    this,
  );
  late final $NetWorthSnapshotsTable netWorthSnapshots =
      $NetWorthSnapshotsTable(this);
  late final $StockMastersTable stockMasters = $StockMastersTable(this);
  late final $StockPricesTable stockPrices = $StockPricesTable(this);
  late final $StockDividendsTable stockDividends = $StockDividendsTable(this);
  late final $MarketDataRefreshesTable marketDataRefreshes =
      $MarketDataRefreshesTable(this);
  late final $ApiRequestDaysTable apiRequestDays = $ApiRequestDaysTable(this);
  late final $CountryTaxRatesTable countryTaxRates = $CountryTaxRatesTable(
    this,
  );
  late final $AssetClassesTable assetClasses = $AssetClassesTable(this);
  late final $AppConfigurationsTable appConfigurations =
      $AppConfigurationsTable(this);
  late final $PhysicalAssetsTable physicalAssets = $PhysicalAssetsTable(this);
  late final $PortfolioSalesTable portfolioSales = $PortfolioSalesTable(this);
  late final $PortfolioAuditLogsTable portfolioAuditLogs =
      $PortfolioAuditLogsTable(this);
  late final $AppErrorLogsTable appErrorLogs = $AppErrorLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    accounts,
    accountBalanceHistories,
    investments,
    investmentPurchases,
    dividendSchedules,
    ledgerEntries,
    masterData,
    reminders,
    vehicles,
    vehicleCosts,
    userPreferences,
    netWorthSnapshots,
    stockMasters,
    stockPrices,
    stockDividends,
    marketDataRefreshes,
    apiRequestDays,
    countryTaxRates,
    assetClasses,
    appConfigurations,
    physicalAssets,
    portfolioSales,
    portfolioAuditLogs,
    appErrorLogs,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String email,
      required String displayName,
      required String passwordHash,
      required String passwordSalt,
      Value<String?> profileImagePath,
      Value<String> role,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String> displayName,
      Value<String> passwordHash,
      Value<String> passwordSalt,
      Value<String?> profileImagePath,
      Value<String> role,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AccountsTable, List<Account>> _accountsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.accounts,
    aliasName: 'users__id__accounts__user_id',
  );

  $$AccountsTableProcessedTableManager get accountsRefs {
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_accountsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $AccountBalanceHistoriesTable,
    List<AccountBalanceHistory>
  >
  _accountBalanceHistoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.accountBalanceHistories,
        aliasName: 'users__id__account_balance_histories__user_id',
      );

  $$AccountBalanceHistoriesTableProcessedTableManager
  get accountBalanceHistoriesRefs {
    final manager = $$AccountBalanceHistoriesTableTableManager(
      $_db,
      $_db.accountBalanceHistories,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _accountBalanceHistoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvestmentsTable, List<Investment>>
  _investmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.investments,
    aliasName: 'users__id__investments__user_id',
  );

  $$InvestmentsTableProcessedTableManager get investmentsRefs {
    final manager = $$InvestmentsTableTableManager(
      $_db,
      $_db.investments,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_investmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $InvestmentPurchasesTable,
    List<InvestmentPurchase>
  >
  _investmentPurchasesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.investmentPurchases,
        aliasName: 'users__id__investment_purchases__user_id',
      );

  $$InvestmentPurchasesTableProcessedTableManager get investmentPurchasesRefs {
    final manager = $$InvestmentPurchasesTableTableManager(
      $_db,
      $_db.investmentPurchases,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _investmentPurchasesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DividendSchedulesTable, List<DividendSchedule>>
  _dividendSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.dividendSchedules,
        aliasName: 'users__id__dividend_schedules__user_id',
      );

  $$DividendSchedulesTableProcessedTableManager get dividendSchedulesRefs {
    final manager = $$DividendSchedulesTableTableManager(
      $_db,
      $_db.dividendSchedules,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dividendSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LedgerEntriesTable, List<LedgerEntry>>
  _ledgerEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ledgerEntries,
    aliasName: 'users__id__ledger_entries__user_id',
  );

  $$LedgerEntriesTableProcessedTableManager get ledgerEntriesRefs {
    final manager = $$LedgerEntriesTableTableManager(
      $_db,
      $_db.ledgerEntries,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ledgerEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MasterDataTable, List<MasterDataData>>
  _masterDataRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.masterData,
    aliasName: 'users__id__master_data__user_id',
  );

  $$MasterDataTableProcessedTableManager get masterDataRefs {
    final manager = $$MasterDataTableTableManager(
      $_db,
      $_db.masterData,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_masterDataRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<AppReminder>>
  _remindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'users__id__reminders__user_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VehiclesTable, List<Vehicle>> _vehiclesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.vehicles,
    aliasName: 'users__id__vehicles__user_id',
  );

  $$VehiclesTableProcessedTableManager get vehiclesRefs {
    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vehiclesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VehicleCostsTable, List<VehicleCost>>
  _vehicleCostsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vehicleCosts,
    aliasName: 'users__id__vehicle_costs__user_id',
  );

  $$VehicleCostsTableProcessedTableManager get vehicleCostsRefs {
    final manager = $$VehicleCostsTableTableManager(
      $_db,
      $_db.vehicleCosts,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vehicleCostsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserPreferencesTable, List<UserPreference>>
  _userPreferencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userPreferences,
    aliasName: 'users__id__user_preferences__user_id',
  );

  $$UserPreferencesTableProcessedTableManager get userPreferencesRefs {
    final manager = $$UserPreferencesTableTableManager(
      $_db,
      $_db.userPreferences,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userPreferencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NetWorthSnapshotsTable, List<NetWorthSnapshot>>
  _netWorthSnapshotsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.netWorthSnapshots,
        aliasName: 'users__id__net_worth_snapshots__user_id',
      );

  $$NetWorthSnapshotsTableProcessedTableManager get netWorthSnapshotsRefs {
    final manager = $$NetWorthSnapshotsTableTableManager(
      $_db,
      $_db.netWorthSnapshots,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _netWorthSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PhysicalAssetsTable, List<PhysicalAsset>>
  _physicalAssetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.physicalAssets,
    aliasName: 'users__id__physical_assets__user_id',
  );

  $$PhysicalAssetsTableProcessedTableManager get physicalAssetsRefs {
    final manager = $$PhysicalAssetsTableTableManager(
      $_db,
      $_db.physicalAssets,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_physicalAssetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PortfolioSalesTable, List<PortfolioSale>>
  _portfolioSalesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.portfolioSales,
    aliasName: 'users__id__portfolio_sales__user_id',
  );

  $$PortfolioSalesTableProcessedTableManager get portfolioSalesRefs {
    final manager = $$PortfolioSalesTableTableManager(
      $_db,
      $_db.portfolioSales,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_portfolioSalesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PortfolioAuditLogsTable, List<PortfolioAuditLog>>
  _portfolioAuditLogsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.portfolioAuditLogs,
        aliasName: 'users__id__portfolio_audit_logs__user_id',
      );

  $$PortfolioAuditLogsTableProcessedTableManager get portfolioAuditLogsRefs {
    final manager = $$PortfolioAuditLogsTableTableManager(
      $_db,
      $_db.portfolioAuditLogs,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _portfolioAuditLogsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileImagePath => $composableBuilder(
    column: $table.profileImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> accountsRefs(
    Expression<bool> Function($$AccountsTableFilterComposer f) f,
  ) {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> accountBalanceHistoriesRefs(
    Expression<bool> Function($$AccountBalanceHistoriesTableFilterComposer f) f,
  ) {
    final $$AccountBalanceHistoriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.accountBalanceHistories,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AccountBalanceHistoriesTableFilterComposer(
                $db: $db,
                $table: $db.accountBalanceHistories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> investmentsRefs(
    Expression<bool> Function($$InvestmentsTableFilterComposer f) f,
  ) {
    final $$InvestmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investments,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentsTableFilterComposer(
            $db: $db,
            $table: $db.investments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> investmentPurchasesRefs(
    Expression<bool> Function($$InvestmentPurchasesTableFilterComposer f) f,
  ) {
    final $$InvestmentPurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentPurchases,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentPurchasesTableFilterComposer(
            $db: $db,
            $table: $db.investmentPurchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dividendSchedulesRefs(
    Expression<bool> Function($$DividendSchedulesTableFilterComposer f) f,
  ) {
    final $$DividendSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dividendSchedules,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DividendSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.dividendSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ledgerEntriesRefs(
    Expression<bool> Function($$LedgerEntriesTableFilterComposer f) f,
  ) {
    final $$LedgerEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerEntriesTableFilterComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> masterDataRefs(
    Expression<bool> Function($$MasterDataTableFilterComposer f) f,
  ) {
    final $$MasterDataTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.masterData,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MasterDataTableFilterComposer(
            $db: $db,
            $table: $db.masterData,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vehiclesRefs(
    Expression<bool> Function($$VehiclesTableFilterComposer f) f,
  ) {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vehicleCostsRefs(
    Expression<bool> Function($$VehicleCostsTableFilterComposer f) f,
  ) {
    final $$VehicleCostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicleCosts,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleCostsTableFilterComposer(
            $db: $db,
            $table: $db.vehicleCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userPreferencesRefs(
    Expression<bool> Function($$UserPreferencesTableFilterComposer f) f,
  ) {
    final $$UserPreferencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userPreferences,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPreferencesTableFilterComposer(
            $db: $db,
            $table: $db.userPreferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> netWorthSnapshotsRefs(
    Expression<bool> Function($$NetWorthSnapshotsTableFilterComposer f) f,
  ) {
    final $$NetWorthSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.netWorthSnapshots,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NetWorthSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.netWorthSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> physicalAssetsRefs(
    Expression<bool> Function($$PhysicalAssetsTableFilterComposer f) f,
  ) {
    final $$PhysicalAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.physicalAssets,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhysicalAssetsTableFilterComposer(
            $db: $db,
            $table: $db.physicalAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> portfolioSalesRefs(
    Expression<bool> Function($$PortfolioSalesTableFilterComposer f) f,
  ) {
    final $$PortfolioSalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.portfolioSales,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PortfolioSalesTableFilterComposer(
            $db: $db,
            $table: $db.portfolioSales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> portfolioAuditLogsRefs(
    Expression<bool> Function($$PortfolioAuditLogsTableFilterComposer f) f,
  ) {
    final $$PortfolioAuditLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.portfolioAuditLogs,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PortfolioAuditLogsTableFilterComposer(
            $db: $db,
            $table: $db.portfolioAuditLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileImagePath => $composableBuilder(
    column: $table.profileImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileImagePath => $composableBuilder(
    column: $table.profileImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> accountsRefs<T extends Object>(
    Expression<T> Function($$AccountsTableAnnotationComposer a) f,
  ) {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> accountBalanceHistoriesRefs<T extends Object>(
    Expression<T> Function($$AccountBalanceHistoriesTableAnnotationComposer a)
    f,
  ) {
    final $$AccountBalanceHistoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.accountBalanceHistories,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AccountBalanceHistoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.accountBalanceHistories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> investmentsRefs<T extends Object>(
    Expression<T> Function($$InvestmentsTableAnnotationComposer a) f,
  ) {
    final $$InvestmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investments,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.investments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> investmentPurchasesRefs<T extends Object>(
    Expression<T> Function($$InvestmentPurchasesTableAnnotationComposer a) f,
  ) {
    final $$InvestmentPurchasesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.investmentPurchases,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InvestmentPurchasesTableAnnotationComposer(
                $db: $db,
                $table: $db.investmentPurchases,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> dividendSchedulesRefs<T extends Object>(
    Expression<T> Function($$DividendSchedulesTableAnnotationComposer a) f,
  ) {
    final $$DividendSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.dividendSchedules,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DividendSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.dividendSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> ledgerEntriesRefs<T extends Object>(
    Expression<T> Function($$LedgerEntriesTableAnnotationComposer a) f,
  ) {
    final $$LedgerEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> masterDataRefs<T extends Object>(
    Expression<T> Function($$MasterDataTableAnnotationComposer a) f,
  ) {
    final $$MasterDataTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.masterData,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MasterDataTableAnnotationComposer(
            $db: $db,
            $table: $db.masterData,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vehiclesRefs<T extends Object>(
    Expression<T> Function($$VehiclesTableAnnotationComposer a) f,
  ) {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vehicleCostsRefs<T extends Object>(
    Expression<T> Function($$VehicleCostsTableAnnotationComposer a) f,
  ) {
    final $$VehicleCostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicleCosts,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleCostsTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicleCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userPreferencesRefs<T extends Object>(
    Expression<T> Function($$UserPreferencesTableAnnotationComposer a) f,
  ) {
    final $$UserPreferencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userPreferences,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPreferencesTableAnnotationComposer(
            $db: $db,
            $table: $db.userPreferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> netWorthSnapshotsRefs<T extends Object>(
    Expression<T> Function($$NetWorthSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$NetWorthSnapshotsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.netWorthSnapshots,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$NetWorthSnapshotsTableAnnotationComposer(
                $db: $db,
                $table: $db.netWorthSnapshots,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> physicalAssetsRefs<T extends Object>(
    Expression<T> Function($$PhysicalAssetsTableAnnotationComposer a) f,
  ) {
    final $$PhysicalAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.physicalAssets,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhysicalAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.physicalAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> portfolioSalesRefs<T extends Object>(
    Expression<T> Function($$PortfolioSalesTableAnnotationComposer a) f,
  ) {
    final $$PortfolioSalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.portfolioSales,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PortfolioSalesTableAnnotationComposer(
            $db: $db,
            $table: $db.portfolioSales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> portfolioAuditLogsRefs<T extends Object>(
    Expression<T> Function($$PortfolioAuditLogsTableAnnotationComposer a) f,
  ) {
    final $$PortfolioAuditLogsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.portfolioAuditLogs,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PortfolioAuditLogsTableAnnotationComposer(
                $db: $db,
                $table: $db.portfolioAuditLogs,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
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
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({
            bool accountsRefs,
            bool accountBalanceHistoriesRefs,
            bool investmentsRefs,
            bool investmentPurchasesRefs,
            bool dividendSchedulesRefs,
            bool ledgerEntriesRefs,
            bool masterDataRefs,
            bool remindersRefs,
            bool vehiclesRefs,
            bool vehicleCostsRefs,
            bool userPreferencesRefs,
            bool netWorthSnapshotsRefs,
            bool physicalAssetsRefs,
            bool portfolioSalesRefs,
            bool portfolioAuditLogsRefs,
          })
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
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> passwordSalt = const Value.absent(),
                Value<String?> profileImagePath = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                displayName: displayName,
                passwordHash: passwordHash,
                passwordSalt: passwordSalt,
                profileImagePath: profileImagePath,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                required String displayName,
                required String passwordHash,
                required String passwordSalt,
                Value<String?> profileImagePath = const Value.absent(),
                Value<String> role = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                displayName: displayName,
                passwordHash: passwordHash,
                passwordSalt: passwordSalt,
                profileImagePath: profileImagePath,
                role: role,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                accountsRefs = false,
                accountBalanceHistoriesRefs = false,
                investmentsRefs = false,
                investmentPurchasesRefs = false,
                dividendSchedulesRefs = false,
                ledgerEntriesRefs = false,
                masterDataRefs = false,
                remindersRefs = false,
                vehiclesRefs = false,
                vehicleCostsRefs = false,
                userPreferencesRefs = false,
                netWorthSnapshotsRefs = false,
                physicalAssetsRefs = false,
                portfolioSalesRefs = false,
                portfolioAuditLogsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (accountsRefs) db.accounts,
                    if (accountBalanceHistoriesRefs) db.accountBalanceHistories,
                    if (investmentsRefs) db.investments,
                    if (investmentPurchasesRefs) db.investmentPurchases,
                    if (dividendSchedulesRefs) db.dividendSchedules,
                    if (ledgerEntriesRefs) db.ledgerEntries,
                    if (masterDataRefs) db.masterData,
                    if (remindersRefs) db.reminders,
                    if (vehiclesRefs) db.vehicles,
                    if (vehicleCostsRefs) db.vehicleCosts,
                    if (userPreferencesRefs) db.userPreferences,
                    if (netWorthSnapshotsRefs) db.netWorthSnapshots,
                    if (physicalAssetsRefs) db.physicalAssets,
                    if (portfolioSalesRefs) db.portfolioSales,
                    if (portfolioAuditLogsRefs) db.portfolioAuditLogs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (accountsRefs)
                        await $_getPrefetchedData<User, $UsersTable, Account>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._accountsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).accountsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (accountBalanceHistoriesRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          AccountBalanceHistory
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._accountBalanceHistoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).accountBalanceHistoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (investmentsRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          Investment
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._investmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (investmentPurchasesRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          InvestmentPurchase
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._investmentPurchasesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentPurchasesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dividendSchedulesRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          DividendSchedule
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._dividendSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).dividendSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ledgerEntriesRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          LedgerEntry
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._ledgerEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).ledgerEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (masterDataRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          MasterDataData
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._masterDataRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).masterDataRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          AppReminder
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (vehiclesRefs)
                        await $_getPrefetchedData<User, $UsersTable, Vehicle>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._vehiclesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).vehiclesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (vehicleCostsRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          VehicleCost
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._vehicleCostsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).vehicleCostsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userPreferencesRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          UserPreference
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._userPreferencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).userPreferencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (netWorthSnapshotsRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          NetWorthSnapshot
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._netWorthSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).netWorthSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (physicalAssetsRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          PhysicalAsset
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._physicalAssetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).physicalAssetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (portfolioSalesRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          PortfolioSale
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._portfolioSalesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).portfolioSalesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (portfolioAuditLogsRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          PortfolioAuditLog
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._portfolioAuditLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).portfolioAuditLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
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
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({
        bool accountsRefs,
        bool accountBalanceHistoriesRefs,
        bool investmentsRefs,
        bool investmentPurchasesRefs,
        bool dividendSchedulesRefs,
        bool ledgerEntriesRefs,
        bool masterDataRefs,
        bool remindersRefs,
        bool vehiclesRefs,
        bool vehicleCostsRefs,
        bool userPreferencesRefs,
        bool netWorthSnapshotsRefs,
        bool physicalAssetsRefs,
        bool portfolioSalesRefs,
        bool portfolioAuditLogsRefs,
      })
    >;
typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      required String id,
      required String userId,
      required String bankName,
      required String label,
      Value<String> holder,
      Value<String> iban,
      Value<String> bic,
      Value<String> accountNumber,
      Value<String> currency,
      Value<double> balance,
      Value<double> availableBalance,
      Value<String> usageType,
      Value<String> notes,
      Value<int> displayOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> bankName,
      Value<String> label,
      Value<String> holder,
      Value<String> iban,
      Value<String> bic,
      Value<String> accountNumber,
      Value<String> currency,
      Value<double> balance,
      Value<double> availableBalance,
      Value<String> usageType,
      Value<String> notes,
      Value<int> displayOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('accounts__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $AccountBalanceHistoriesTable,
    List<AccountBalanceHistory>
  >
  _accountBalanceHistoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.accountBalanceHistories,
        aliasName: 'accounts__id__account_balance_histories__account_id',
      );

  $$AccountBalanceHistoriesTableProcessedTableManager
  get accountBalanceHistoriesRefs {
    final manager = $$AccountBalanceHistoriesTableTableManager(
      $_db,
      $_db.accountBalanceHistories,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _accountBalanceHistoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PortfolioSalesTable, List<PortfolioSale>>
  _portfolioSalesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.portfolioSales,
    aliasName: 'accounts__id__portfolio_sales__account_id',
  );

  $$PortfolioSalesTableProcessedTableManager get portfolioSalesRefs {
    final manager = $$PortfolioSalesTableTableManager(
      $_db,
      $_db.portfolioSales,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_portfolioSalesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get holder => $composableBuilder(
    column: $table.holder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iban => $composableBuilder(
    column: $table.iban,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bic => $composableBuilder(
    column: $table.bic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get availableBalance => $composableBuilder(
    column: $table.availableBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usageType => $composableBuilder(
    column: $table.usageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> accountBalanceHistoriesRefs(
    Expression<bool> Function($$AccountBalanceHistoriesTableFilterComposer f) f,
  ) {
    final $$AccountBalanceHistoriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.accountBalanceHistories,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AccountBalanceHistoriesTableFilterComposer(
                $db: $db,
                $table: $db.accountBalanceHistories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> portfolioSalesRefs(
    Expression<bool> Function($$PortfolioSalesTableFilterComposer f) f,
  ) {
    final $$PortfolioSalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.portfolioSales,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PortfolioSalesTableFilterComposer(
            $db: $db,
            $table: $db.portfolioSales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get holder => $composableBuilder(
    column: $table.holder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iban => $composableBuilder(
    column: $table.iban,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bic => $composableBuilder(
    column: $table.bic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get availableBalance => $composableBuilder(
    column: $table.availableBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usageType => $composableBuilder(
    column: $table.usageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get holder =>
      $composableBuilder(column: $table.holder, builder: (column) => column);

  GeneratedColumn<String> get iban =>
      $composableBuilder(column: $table.iban, builder: (column) => column);

  GeneratedColumn<String> get bic =>
      $composableBuilder(column: $table.bic, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<double> get availableBalance => $composableBuilder(
    column: $table.availableBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get usageType =>
      $composableBuilder(column: $table.usageType, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> accountBalanceHistoriesRefs<T extends Object>(
    Expression<T> Function($$AccountBalanceHistoriesTableAnnotationComposer a)
    f,
  ) {
    final $$AccountBalanceHistoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.accountBalanceHistories,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AccountBalanceHistoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.accountBalanceHistories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> portfolioSalesRefs<T extends Object>(
    Expression<T> Function($$PortfolioSalesTableAnnotationComposer a) f,
  ) {
    final $$PortfolioSalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.portfolioSales,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PortfolioSalesTableAnnotationComposer(
            $db: $db,
            $table: $db.portfolioSales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, $$AccountsTableReferences),
          Account,
          PrefetchHooks Function({
            bool userId,
            bool accountBalanceHistoriesRefs,
            bool portfolioSalesRefs,
          })
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> bankName = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> holder = const Value.absent(),
                Value<String> iban = const Value.absent(),
                Value<String> bic = const Value.absent(),
                Value<String> accountNumber = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<double> availableBalance = const Value.absent(),
                Value<String> usageType = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                userId: userId,
                bankName: bankName,
                label: label,
                holder: holder,
                iban: iban,
                bic: bic,
                accountNumber: accountNumber,
                currency: currency,
                balance: balance,
                availableBalance: availableBalance,
                usageType: usageType,
                notes: notes,
                displayOrder: displayOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String bankName,
                required String label,
                Value<String> holder = const Value.absent(),
                Value<String> iban = const Value.absent(),
                Value<String> bic = const Value.absent(),
                Value<String> accountNumber = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<double> availableBalance = const Value.absent(),
                Value<String> usageType = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                userId: userId,
                bankName: bankName,
                label: label,
                holder: holder,
                iban: iban,
                bic: bic,
                accountNumber: accountNumber,
                currency: currency,
                balance: balance,
                availableBalance: availableBalance,
                usageType: usageType,
                notes: notes,
                displayOrder: displayOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                userId = false,
                accountBalanceHistoriesRefs = false,
                portfolioSalesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (accountBalanceHistoriesRefs) db.accountBalanceHistories,
                    if (portfolioSalesRefs) db.portfolioSales,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable: $$AccountsTableReferences
                                        ._userIdTable(db),
                                    referencedColumn: $$AccountsTableReferences
                                        ._userIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (accountBalanceHistoriesRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          AccountBalanceHistory
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._accountBalanceHistoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).accountBalanceHistoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (portfolioSalesRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          PortfolioSale
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._portfolioSalesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).portfolioSalesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, $$AccountsTableReferences),
      Account,
      PrefetchHooks Function({
        bool userId,
        bool accountBalanceHistoriesRefs,
        bool portfolioSalesRefs,
      })
    >;
typedef $$AccountBalanceHistoriesTableCreateCompanionBuilder =
    AccountBalanceHistoriesCompanion Function({
      required String id,
      required String userId,
      required String accountId,
      required DateTime effectiveAt,
      required double balance,
      required double availableBalance,
      required DateTime createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$AccountBalanceHistoriesTableUpdateCompanionBuilder =
    AccountBalanceHistoriesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> accountId,
      Value<DateTime> effectiveAt,
      Value<double> balance,
      Value<double> availableBalance,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$AccountBalanceHistoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AccountBalanceHistoriesTable,
          AccountBalanceHistory
        > {
  $$AccountBalanceHistoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('account_balance_histories__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) => db.accounts
      .createAlias('account_balance_histories__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AccountBalanceHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $AccountBalanceHistoriesTable> {
  $$AccountBalanceHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get availableBalance => $composableBuilder(
    column: $table.availableBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountBalanceHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountBalanceHistoriesTable> {
  $$AccountBalanceHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get availableBalance => $composableBuilder(
    column: $table.availableBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountBalanceHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountBalanceHistoriesTable> {
  $$AccountBalanceHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<double> get availableBalance => $composableBuilder(
    column: $table.availableBalance,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountBalanceHistoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountBalanceHistoriesTable,
          AccountBalanceHistory,
          $$AccountBalanceHistoriesTableFilterComposer,
          $$AccountBalanceHistoriesTableOrderingComposer,
          $$AccountBalanceHistoriesTableAnnotationComposer,
          $$AccountBalanceHistoriesTableCreateCompanionBuilder,
          $$AccountBalanceHistoriesTableUpdateCompanionBuilder,
          (AccountBalanceHistory, $$AccountBalanceHistoriesTableReferences),
          AccountBalanceHistory,
          PrefetchHooks Function({bool userId, bool accountId})
        > {
  $$AccountBalanceHistoriesTableTableManager(
    _$AppDatabase db,
    $AccountBalanceHistoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountBalanceHistoriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AccountBalanceHistoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AccountBalanceHistoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<DateTime> effectiveAt = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<double> availableBalance = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountBalanceHistoriesCompanion(
                id: id,
                userId: userId,
                accountId: accountId,
                effectiveAt: effectiveAt,
                balance: balance,
                availableBalance: availableBalance,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String accountId,
                required DateTime effectiveAt,
                required double balance,
                required double availableBalance,
                required DateTime createdAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountBalanceHistoriesCompanion.insert(
                id: id,
                userId: userId,
                accountId: accountId,
                effectiveAt: effectiveAt,
                balance: balance,
                availableBalance: availableBalance,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AccountBalanceHistoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false, accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$AccountBalanceHistoriesTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$AccountBalanceHistoriesTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable:
                                    $$AccountBalanceHistoriesTableReferences
                                        ._accountIdTable(db),
                                referencedColumn:
                                    $$AccountBalanceHistoriesTableReferences
                                        ._accountIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AccountBalanceHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountBalanceHistoriesTable,
      AccountBalanceHistory,
      $$AccountBalanceHistoriesTableFilterComposer,
      $$AccountBalanceHistoriesTableOrderingComposer,
      $$AccountBalanceHistoriesTableAnnotationComposer,
      $$AccountBalanceHistoriesTableCreateCompanionBuilder,
      $$AccountBalanceHistoriesTableUpdateCompanionBuilder,
      (AccountBalanceHistory, $$AccountBalanceHistoriesTableReferences),
      AccountBalanceHistory,
      PrefetchHooks Function({bool userId, bool accountId})
    >;
typedef $$InvestmentsTableCreateCompanionBuilder =
    InvestmentsCompanion Function({
      required String id,
      required String userId,
      Value<String?> stockId,
      Value<String> accountId,
      required String name,
      Value<String> symbol,
      Value<String> isin,
      Value<String> wkn,
      required String assetType,
      Value<String> broker,
      Value<String> country,
      Value<String> sector,
      required DateTime purchaseDate,
      required double purchasePrice,
      required double quantity,
      Value<double> fees,
      required double currentPrice,
      Value<double> annualDividend,
      Value<String> dividendCurrency,
      Value<double> dividendExchangeRate,
      Value<double> dividendWithholdingTaxRate,
      Value<String> dividendFrequency,
      Value<int> dividendStartMonth,
      Value<String> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$InvestmentsTableUpdateCompanionBuilder =
    InvestmentsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> stockId,
      Value<String> accountId,
      Value<String> name,
      Value<String> symbol,
      Value<String> isin,
      Value<String> wkn,
      Value<String> assetType,
      Value<String> broker,
      Value<String> country,
      Value<String> sector,
      Value<DateTime> purchaseDate,
      Value<double> purchasePrice,
      Value<double> quantity,
      Value<double> fees,
      Value<double> currentPrice,
      Value<double> annualDividend,
      Value<String> dividendCurrency,
      Value<double> dividendExchangeRate,
      Value<double> dividendWithholdingTaxRate,
      Value<String> dividendFrequency,
      Value<int> dividendStartMonth,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$InvestmentsTableReferences
    extends BaseReferences<_$AppDatabase, $InvestmentsTable, Investment> {
  $$InvestmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('investments__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $InvestmentPurchasesTable,
    List<InvestmentPurchase>
  >
  _investmentPurchasesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.investmentPurchases,
        aliasName: 'investments__id__investment_purchases__investment_id',
      );

  $$InvestmentPurchasesTableProcessedTableManager get investmentPurchasesRefs {
    final manager = $$InvestmentPurchasesTableTableManager(
      $_db,
      $_db.investmentPurchases,
    ).filter((f) => f.investmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _investmentPurchasesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DividendSchedulesTable, List<DividendSchedule>>
  _dividendSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.dividendSchedules,
        aliasName: 'investments__id__dividend_schedules__investment_id',
      );

  $$DividendSchedulesTableProcessedTableManager get dividendSchedulesRefs {
    final manager = $$DividendSchedulesTableTableManager(
      $_db,
      $_db.dividendSchedules,
    ).filter((f) => f.investmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dividendSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InvestmentsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stockId => $composableBuilder(
    column: $table.stockId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wkn => $composableBuilder(
    column: $table.wkn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetType => $composableBuilder(
    column: $table.assetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get broker => $composableBuilder(
    column: $table.broker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentPrice => $composableBuilder(
    column: $table.currentPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get annualDividend => $composableBuilder(
    column: $table.annualDividend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dividendCurrency => $composableBuilder(
    column: $table.dividendCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dividendExchangeRate => $composableBuilder(
    column: $table.dividendExchangeRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dividendWithholdingTaxRate => $composableBuilder(
    column: $table.dividendWithholdingTaxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dividendFrequency => $composableBuilder(
    column: $table.dividendFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dividendStartMonth => $composableBuilder(
    column: $table.dividendStartMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> investmentPurchasesRefs(
    Expression<bool> Function($$InvestmentPurchasesTableFilterComposer f) f,
  ) {
    final $$InvestmentPurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentPurchases,
      getReferencedColumn: (t) => t.investmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentPurchasesTableFilterComposer(
            $db: $db,
            $table: $db.investmentPurchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dividendSchedulesRefs(
    Expression<bool> Function($$DividendSchedulesTableFilterComposer f) f,
  ) {
    final $$DividendSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dividendSchedules,
      getReferencedColumn: (t) => t.investmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DividendSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.dividendSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvestmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stockId => $composableBuilder(
    column: $table.stockId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wkn => $composableBuilder(
    column: $table.wkn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetType => $composableBuilder(
    column: $table.assetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get broker => $composableBuilder(
    column: $table.broker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentPrice => $composableBuilder(
    column: $table.currentPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get annualDividend => $composableBuilder(
    column: $table.annualDividend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dividendCurrency => $composableBuilder(
    column: $table.dividendCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dividendExchangeRate => $composableBuilder(
    column: $table.dividendExchangeRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dividendWithholdingTaxRate => $composableBuilder(
    column: $table.dividendWithholdingTaxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dividendFrequency => $composableBuilder(
    column: $table.dividendFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dividendStartMonth => $composableBuilder(
    column: $table.dividendStartMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stockId =>
      $composableBuilder(column: $table.stockId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get isin =>
      $composableBuilder(column: $table.isin, builder: (column) => column);

  GeneratedColumn<String> get wkn =>
      $composableBuilder(column: $table.wkn, builder: (column) => column);

  GeneratedColumn<String> get assetType =>
      $composableBuilder(column: $table.assetType, builder: (column) => column);

  GeneratedColumn<String> get broker =>
      $composableBuilder(column: $table.broker, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get sector =>
      $composableBuilder(column: $table.sector, builder: (column) => column);

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get fees =>
      $composableBuilder(column: $table.fees, builder: (column) => column);

  GeneratedColumn<double> get currentPrice => $composableBuilder(
    column: $table.currentPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get annualDividend => $composableBuilder(
    column: $table.annualDividend,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dividendCurrency => $composableBuilder(
    column: $table.dividendCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dividendExchangeRate => $composableBuilder(
    column: $table.dividendExchangeRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dividendWithholdingTaxRate => $composableBuilder(
    column: $table.dividendWithholdingTaxRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dividendFrequency => $composableBuilder(
    column: $table.dividendFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dividendStartMonth => $composableBuilder(
    column: $table.dividendStartMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> investmentPurchasesRefs<T extends Object>(
    Expression<T> Function($$InvestmentPurchasesTableAnnotationComposer a) f,
  ) {
    final $$InvestmentPurchasesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.investmentPurchases,
          getReferencedColumn: (t) => t.investmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InvestmentPurchasesTableAnnotationComposer(
                $db: $db,
                $table: $db.investmentPurchases,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> dividendSchedulesRefs<T extends Object>(
    Expression<T> Function($$DividendSchedulesTableAnnotationComposer a) f,
  ) {
    final $$DividendSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.dividendSchedules,
          getReferencedColumn: (t) => t.investmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DividendSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.dividendSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$InvestmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestmentsTable,
          Investment,
          $$InvestmentsTableFilterComposer,
          $$InvestmentsTableOrderingComposer,
          $$InvestmentsTableAnnotationComposer,
          $$InvestmentsTableCreateCompanionBuilder,
          $$InvestmentsTableUpdateCompanionBuilder,
          (Investment, $$InvestmentsTableReferences),
          Investment,
          PrefetchHooks Function({
            bool userId,
            bool investmentPurchasesRefs,
            bool dividendSchedulesRefs,
          })
        > {
  $$InvestmentsTableTableManager(_$AppDatabase db, $InvestmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> stockId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> isin = const Value.absent(),
                Value<String> wkn = const Value.absent(),
                Value<String> assetType = const Value.absent(),
                Value<String> broker = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> sector = const Value.absent(),
                Value<DateTime> purchaseDate = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> fees = const Value.absent(),
                Value<double> currentPrice = const Value.absent(),
                Value<double> annualDividend = const Value.absent(),
                Value<String> dividendCurrency = const Value.absent(),
                Value<double> dividendExchangeRate = const Value.absent(),
                Value<double> dividendWithholdingTaxRate = const Value.absent(),
                Value<String> dividendFrequency = const Value.absent(),
                Value<int> dividendStartMonth = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentsCompanion(
                id: id,
                userId: userId,
                stockId: stockId,
                accountId: accountId,
                name: name,
                symbol: symbol,
                isin: isin,
                wkn: wkn,
                assetType: assetType,
                broker: broker,
                country: country,
                sector: sector,
                purchaseDate: purchaseDate,
                purchasePrice: purchasePrice,
                quantity: quantity,
                fees: fees,
                currentPrice: currentPrice,
                annualDividend: annualDividend,
                dividendCurrency: dividendCurrency,
                dividendExchangeRate: dividendExchangeRate,
                dividendWithholdingTaxRate: dividendWithholdingTaxRate,
                dividendFrequency: dividendFrequency,
                dividendStartMonth: dividendStartMonth,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> stockId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                required String name,
                Value<String> symbol = const Value.absent(),
                Value<String> isin = const Value.absent(),
                Value<String> wkn = const Value.absent(),
                required String assetType,
                Value<String> broker = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> sector = const Value.absent(),
                required DateTime purchaseDate,
                required double purchasePrice,
                required double quantity,
                Value<double> fees = const Value.absent(),
                required double currentPrice,
                Value<double> annualDividend = const Value.absent(),
                Value<String> dividendCurrency = const Value.absent(),
                Value<double> dividendExchangeRate = const Value.absent(),
                Value<double> dividendWithholdingTaxRate = const Value.absent(),
                Value<String> dividendFrequency = const Value.absent(),
                Value<int> dividendStartMonth = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentsCompanion.insert(
                id: id,
                userId: userId,
                stockId: stockId,
                accountId: accountId,
                name: name,
                symbol: symbol,
                isin: isin,
                wkn: wkn,
                assetType: assetType,
                broker: broker,
                country: country,
                sector: sector,
                purchaseDate: purchaseDate,
                purchasePrice: purchasePrice,
                quantity: quantity,
                fees: fees,
                currentPrice: currentPrice,
                annualDividend: annualDividend,
                dividendCurrency: dividendCurrency,
                dividendExchangeRate: dividendExchangeRate,
                dividendWithholdingTaxRate: dividendWithholdingTaxRate,
                dividendFrequency: dividendFrequency,
                dividendStartMonth: dividendStartMonth,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvestmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                userId = false,
                investmentPurchasesRefs = false,
                dividendSchedulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (investmentPurchasesRefs) db.investmentPurchases,
                    if (dividendSchedulesRefs) db.dividendSchedules,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable:
                                        $$InvestmentsTableReferences
                                            ._userIdTable(db),
                                    referencedColumn:
                                        $$InvestmentsTableReferences
                                            ._userIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (investmentPurchasesRefs)
                        await $_getPrefetchedData<
                          Investment,
                          $InvestmentsTable,
                          InvestmentPurchase
                        >(
                          currentTable: table,
                          referencedTable: $$InvestmentsTableReferences
                              ._investmentPurchasesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvestmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentPurchasesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.investmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dividendSchedulesRefs)
                        await $_getPrefetchedData<
                          Investment,
                          $InvestmentsTable,
                          DividendSchedule
                        >(
                          currentTable: table,
                          referencedTable: $$InvestmentsTableReferences
                              ._dividendSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvestmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).dividendSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.investmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InvestmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestmentsTable,
      Investment,
      $$InvestmentsTableFilterComposer,
      $$InvestmentsTableOrderingComposer,
      $$InvestmentsTableAnnotationComposer,
      $$InvestmentsTableCreateCompanionBuilder,
      $$InvestmentsTableUpdateCompanionBuilder,
      (Investment, $$InvestmentsTableReferences),
      Investment,
      PrefetchHooks Function({
        bool userId,
        bool investmentPurchasesRefs,
        bool dividendSchedulesRefs,
      })
    >;
typedef $$InvestmentPurchasesTableCreateCompanionBuilder =
    InvestmentPurchasesCompanion Function({
      required String id,
      required String userId,
      required String investmentId,
      required DateTime purchaseDate,
      required double purchasePrice,
      required double quantity,
      Value<double> fees,
      Value<bool> cashApplied,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$InvestmentPurchasesTableUpdateCompanionBuilder =
    InvestmentPurchasesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> investmentId,
      Value<DateTime> purchaseDate,
      Value<double> purchasePrice,
      Value<double> quantity,
      Value<double> fees,
      Value<bool> cashApplied,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$InvestmentPurchasesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InvestmentPurchasesTable,
          InvestmentPurchase
        > {
  $$InvestmentPurchasesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('investment_purchases__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InvestmentsTable _investmentIdTable(_$AppDatabase db) => db
      .investments
      .createAlias('investment_purchases__investment_id__investments__id');

  $$InvestmentsTableProcessedTableManager get investmentId {
    final $_column = $_itemColumn<String>('investment_id')!;

    final manager = $$InvestmentsTableTableManager(
      $_db,
      $_db.investments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_investmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvestmentPurchasesTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentPurchasesTable> {
  $$InvestmentPurchasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cashApplied => $composableBuilder(
    column: $table.cashApplied,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestmentsTableFilterComposer get investmentId {
    final $$InvestmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investmentId,
      referencedTable: $db.investments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentsTableFilterComposer(
            $db: $db,
            $table: $db.investments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestmentPurchasesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentPurchasesTable> {
  $$InvestmentPurchasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cashApplied => $composableBuilder(
    column: $table.cashApplied,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestmentsTableOrderingComposer get investmentId {
    final $$InvestmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investmentId,
      referencedTable: $db.investments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentsTableOrderingComposer(
            $db: $db,
            $table: $db.investments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestmentPurchasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentPurchasesTable> {
  $$InvestmentPurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get fees =>
      $composableBuilder(column: $table.fees, builder: (column) => column);

  GeneratedColumn<bool> get cashApplied => $composableBuilder(
    column: $table.cashApplied,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestmentsTableAnnotationComposer get investmentId {
    final $$InvestmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investmentId,
      referencedTable: $db.investments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.investments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestmentPurchasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestmentPurchasesTable,
          InvestmentPurchase,
          $$InvestmentPurchasesTableFilterComposer,
          $$InvestmentPurchasesTableOrderingComposer,
          $$InvestmentPurchasesTableAnnotationComposer,
          $$InvestmentPurchasesTableCreateCompanionBuilder,
          $$InvestmentPurchasesTableUpdateCompanionBuilder,
          (InvestmentPurchase, $$InvestmentPurchasesTableReferences),
          InvestmentPurchase,
          PrefetchHooks Function({bool userId, bool investmentId})
        > {
  $$InvestmentPurchasesTableTableManager(
    _$AppDatabase db,
    $InvestmentPurchasesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentPurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentPurchasesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InvestmentPurchasesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> investmentId = const Value.absent(),
                Value<DateTime> purchaseDate = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> fees = const Value.absent(),
                Value<bool> cashApplied = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentPurchasesCompanion(
                id: id,
                userId: userId,
                investmentId: investmentId,
                purchaseDate: purchaseDate,
                purchasePrice: purchasePrice,
                quantity: quantity,
                fees: fees,
                cashApplied: cashApplied,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String investmentId,
                required DateTime purchaseDate,
                required double purchasePrice,
                required double quantity,
                Value<double> fees = const Value.absent(),
                Value<bool> cashApplied = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentPurchasesCompanion.insert(
                id: id,
                userId: userId,
                investmentId: investmentId,
                purchaseDate: purchaseDate,
                purchasePrice: purchasePrice,
                quantity: quantity,
                fees: fees,
                cashApplied: cashApplied,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvestmentPurchasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false, investmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$InvestmentPurchasesTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$InvestmentPurchasesTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (investmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.investmentId,
                                referencedTable:
                                    $$InvestmentPurchasesTableReferences
                                        ._investmentIdTable(db),
                                referencedColumn:
                                    $$InvestmentPurchasesTableReferences
                                        ._investmentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InvestmentPurchasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestmentPurchasesTable,
      InvestmentPurchase,
      $$InvestmentPurchasesTableFilterComposer,
      $$InvestmentPurchasesTableOrderingComposer,
      $$InvestmentPurchasesTableAnnotationComposer,
      $$InvestmentPurchasesTableCreateCompanionBuilder,
      $$InvestmentPurchasesTableUpdateCompanionBuilder,
      (InvestmentPurchase, $$InvestmentPurchasesTableReferences),
      InvestmentPurchase,
      PrefetchHooks Function({bool userId, bool investmentId})
    >;
typedef $$DividendSchedulesTableCreateCompanionBuilder =
    DividendSchedulesCompanion Function({
      required String id,
      required String userId,
      required String investmentId,
      required int paymentMonth,
      required double amountPerShare,
      Value<DateTime?> exDate,
      Value<DateTime?> paymentDate,
      Value<int> paymentYear,
      Value<String> currency,
      Value<double> exchangeRate,
      Value<double> withholdingTaxRate,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$DividendSchedulesTableUpdateCompanionBuilder =
    DividendSchedulesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> investmentId,
      Value<int> paymentMonth,
      Value<double> amountPerShare,
      Value<DateTime?> exDate,
      Value<DateTime?> paymentDate,
      Value<int> paymentYear,
      Value<String> currency,
      Value<double> exchangeRate,
      Value<double> withholdingTaxRate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$DividendSchedulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DividendSchedulesTable,
          DividendSchedule
        > {
  $$DividendSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('dividend_schedules__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InvestmentsTable _investmentIdTable(_$AppDatabase db) => db
      .investments
      .createAlias('dividend_schedules__investment_id__investments__id');

  $$InvestmentsTableProcessedTableManager get investmentId {
    final $_column = $_itemColumn<String>('investment_id')!;

    final manager = $$InvestmentsTableTableManager(
      $_db,
      $_db.investments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_investmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DividendSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $DividendSchedulesTable> {
  $$DividendSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentMonth => $composableBuilder(
    column: $table.paymentMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPerShare => $composableBuilder(
    column: $table.amountPerShare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get exDate => $composableBuilder(
    column: $table.exDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentYear => $composableBuilder(
    column: $table.paymentYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get exchangeRate => $composableBuilder(
    column: $table.exchangeRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get withholdingTaxRate => $composableBuilder(
    column: $table.withholdingTaxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestmentsTableFilterComposer get investmentId {
    final $$InvestmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investmentId,
      referencedTable: $db.investments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentsTableFilterComposer(
            $db: $db,
            $table: $db.investments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DividendSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $DividendSchedulesTable> {
  $$DividendSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentMonth => $composableBuilder(
    column: $table.paymentMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPerShare => $composableBuilder(
    column: $table.amountPerShare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get exDate => $composableBuilder(
    column: $table.exDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentYear => $composableBuilder(
    column: $table.paymentYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get exchangeRate => $composableBuilder(
    column: $table.exchangeRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get withholdingTaxRate => $composableBuilder(
    column: $table.withholdingTaxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestmentsTableOrderingComposer get investmentId {
    final $$InvestmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investmentId,
      referencedTable: $db.investments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentsTableOrderingComposer(
            $db: $db,
            $table: $db.investments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DividendSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DividendSchedulesTable> {
  $$DividendSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get paymentMonth => $composableBuilder(
    column: $table.paymentMonth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPerShare => $composableBuilder(
    column: $table.amountPerShare,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get exDate =>
      $composableBuilder(column: $table.exDate, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paymentYear => $composableBuilder(
    column: $table.paymentYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<double> get exchangeRate => $composableBuilder(
    column: $table.exchangeRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get withholdingTaxRate => $composableBuilder(
    column: $table.withholdingTaxRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestmentsTableAnnotationComposer get investmentId {
    final $$InvestmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investmentId,
      referencedTable: $db.investments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.investments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DividendSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DividendSchedulesTable,
          DividendSchedule,
          $$DividendSchedulesTableFilterComposer,
          $$DividendSchedulesTableOrderingComposer,
          $$DividendSchedulesTableAnnotationComposer,
          $$DividendSchedulesTableCreateCompanionBuilder,
          $$DividendSchedulesTableUpdateCompanionBuilder,
          (DividendSchedule, $$DividendSchedulesTableReferences),
          DividendSchedule,
          PrefetchHooks Function({bool userId, bool investmentId})
        > {
  $$DividendSchedulesTableTableManager(
    _$AppDatabase db,
    $DividendSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DividendSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DividendSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DividendSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> investmentId = const Value.absent(),
                Value<int> paymentMonth = const Value.absent(),
                Value<double> amountPerShare = const Value.absent(),
                Value<DateTime?> exDate = const Value.absent(),
                Value<DateTime?> paymentDate = const Value.absent(),
                Value<int> paymentYear = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<double> exchangeRate = const Value.absent(),
                Value<double> withholdingTaxRate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DividendSchedulesCompanion(
                id: id,
                userId: userId,
                investmentId: investmentId,
                paymentMonth: paymentMonth,
                amountPerShare: amountPerShare,
                exDate: exDate,
                paymentDate: paymentDate,
                paymentYear: paymentYear,
                currency: currency,
                exchangeRate: exchangeRate,
                withholdingTaxRate: withholdingTaxRate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String investmentId,
                required int paymentMonth,
                required double amountPerShare,
                Value<DateTime?> exDate = const Value.absent(),
                Value<DateTime?> paymentDate = const Value.absent(),
                Value<int> paymentYear = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<double> exchangeRate = const Value.absent(),
                Value<double> withholdingTaxRate = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DividendSchedulesCompanion.insert(
                id: id,
                userId: userId,
                investmentId: investmentId,
                paymentMonth: paymentMonth,
                amountPerShare: amountPerShare,
                exDate: exDate,
                paymentDate: paymentDate,
                paymentYear: paymentYear,
                currency: currency,
                exchangeRate: exchangeRate,
                withholdingTaxRate: withholdingTaxRate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DividendSchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false, investmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$DividendSchedulesTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$DividendSchedulesTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (investmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.investmentId,
                                referencedTable:
                                    $$DividendSchedulesTableReferences
                                        ._investmentIdTable(db),
                                referencedColumn:
                                    $$DividendSchedulesTableReferences
                                        ._investmentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DividendSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DividendSchedulesTable,
      DividendSchedule,
      $$DividendSchedulesTableFilterComposer,
      $$DividendSchedulesTableOrderingComposer,
      $$DividendSchedulesTableAnnotationComposer,
      $$DividendSchedulesTableCreateCompanionBuilder,
      $$DividendSchedulesTableUpdateCompanionBuilder,
      (DividendSchedule, $$DividendSchedulesTableReferences),
      DividendSchedule,
      PrefetchHooks Function({bool userId, bool investmentId})
    >;
typedef $$LedgerEntriesTableCreateCompanionBuilder =
    LedgerEntriesCompanion Function({
      required String id,
      required String userId,
      required DateTime bookingDate,
      Value<DateTime?> budgetMonth,
      required double amount,
      Value<bool> isIncome,
      required String category,
      Value<String> merchant,
      Value<String> description,
      Value<String> paymentMethod,
      Value<String> recurrenceId,
      Value<String> sourceType,
      Value<String> sourceId,
      Value<String> vehicleId,
      Value<String> accountId,
      Value<bool> accountApplied,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LedgerEntriesTableUpdateCompanionBuilder =
    LedgerEntriesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<DateTime> bookingDate,
      Value<DateTime?> budgetMonth,
      Value<double> amount,
      Value<bool> isIncome,
      Value<String> category,
      Value<String> merchant,
      Value<String> description,
      Value<String> paymentMethod,
      Value<String> recurrenceId,
      Value<String> sourceType,
      Value<String> sourceId,
      Value<String> vehicleId,
      Value<String> accountId,
      Value<bool> accountApplied,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$LedgerEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntry> {
  $$LedgerEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('ledger_entries__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get bookingDate => $composableBuilder(
    column: $table.bookingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get budgetMonth => $composableBuilder(
    column: $table.budgetMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceId => $composableBuilder(
    column: $table.recurrenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get accountApplied => $composableBuilder(
    column: $table.accountApplied,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get bookingDate => $composableBuilder(
    column: $table.bookingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get budgetMonth => $composableBuilder(
    column: $table.budgetMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceId => $composableBuilder(
    column: $table.recurrenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get accountApplied => $composableBuilder(
    column: $table.accountApplied,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get bookingDate => $composableBuilder(
    column: $table.bookingDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get budgetMonth => $composableBuilder(
    column: $table.budgetMonth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get isIncome =>
      $composableBuilder(column: $table.isIncome, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceId => $composableBuilder(
    column: $table.recurrenceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<bool> get accountApplied => $composableBuilder(
    column: $table.accountApplied,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgerEntriesTable,
          LedgerEntry,
          $$LedgerEntriesTableFilterComposer,
          $$LedgerEntriesTableOrderingComposer,
          $$LedgerEntriesTableAnnotationComposer,
          $$LedgerEntriesTableCreateCompanionBuilder,
          $$LedgerEntriesTableUpdateCompanionBuilder,
          (LedgerEntry, $$LedgerEntriesTableReferences),
          LedgerEntry,
          PrefetchHooks Function({bool userId})
        > {
  $$LedgerEntriesTableTableManager(_$AppDatabase db, $LedgerEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> bookingDate = const Value.absent(),
                Value<DateTime?> budgetMonth = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<bool> isIncome = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> merchant = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String> recurrenceId = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<bool> accountApplied = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion(
                id: id,
                userId: userId,
                bookingDate: bookingDate,
                budgetMonth: budgetMonth,
                amount: amount,
                isIncome: isIncome,
                category: category,
                merchant: merchant,
                description: description,
                paymentMethod: paymentMethod,
                recurrenceId: recurrenceId,
                sourceType: sourceType,
                sourceId: sourceId,
                vehicleId: vehicleId,
                accountId: accountId,
                accountApplied: accountApplied,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required DateTime bookingDate,
                Value<DateTime?> budgetMonth = const Value.absent(),
                required double amount,
                Value<bool> isIncome = const Value.absent(),
                required String category,
                Value<String> merchant = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String> recurrenceId = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<bool> accountApplied = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion.insert(
                id: id,
                userId: userId,
                bookingDate: bookingDate,
                budgetMonth: budgetMonth,
                amount: amount,
                isIncome: isIncome,
                category: category,
                merchant: merchant,
                description: description,
                paymentMethod: paymentMethod,
                recurrenceId: recurrenceId,
                sourceType: sourceType,
                sourceId: sourceId,
                vehicleId: vehicleId,
                accountId: accountId,
                accountApplied: accountApplied,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LedgerEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$LedgerEntriesTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$LedgerEntriesTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LedgerEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgerEntriesTable,
      LedgerEntry,
      $$LedgerEntriesTableFilterComposer,
      $$LedgerEntriesTableOrderingComposer,
      $$LedgerEntriesTableAnnotationComposer,
      $$LedgerEntriesTableCreateCompanionBuilder,
      $$LedgerEntriesTableUpdateCompanionBuilder,
      (LedgerEntry, $$LedgerEntriesTableReferences),
      LedgerEntry,
      PrefetchHooks Function({bool userId})
    >;
typedef $$MasterDataTableCreateCompanionBuilder =
    MasterDataCompanion Function({
      required String id,
      required String userId,
      required String kind,
      required String value,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$MasterDataTableUpdateCompanionBuilder =
    MasterDataCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> kind,
      Value<String> value,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$MasterDataTableReferences
    extends BaseReferences<_$AppDatabase, $MasterDataTable, MasterDataData> {
  $$MasterDataTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('master_data__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MasterDataTableFilterComposer
    extends Composer<_$AppDatabase, $MasterDataTable> {
  $$MasterDataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MasterDataTableOrderingComposer
    extends Composer<_$AppDatabase, $MasterDataTable> {
  $$MasterDataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MasterDataTableAnnotationComposer
    extends Composer<_$AppDatabase, $MasterDataTable> {
  $$MasterDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MasterDataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MasterDataTable,
          MasterDataData,
          $$MasterDataTableFilterComposer,
          $$MasterDataTableOrderingComposer,
          $$MasterDataTableAnnotationComposer,
          $$MasterDataTableCreateCompanionBuilder,
          $$MasterDataTableUpdateCompanionBuilder,
          (MasterDataData, $$MasterDataTableReferences),
          MasterDataData,
          PrefetchHooks Function({bool userId})
        > {
  $$MasterDataTableTableManager(_$AppDatabase db, $MasterDataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MasterDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MasterDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MasterDataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MasterDataCompanion(
                id: id,
                userId: userId,
                kind: kind,
                value: value,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String kind,
                required String value,
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MasterDataCompanion.insert(
                id: id,
                userId: userId,
                kind: kind,
                value: value,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MasterDataTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$MasterDataTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$MasterDataTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MasterDataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MasterDataTable,
      MasterDataData,
      $$MasterDataTableFilterComposer,
      $$MasterDataTableOrderingComposer,
      $$MasterDataTableAnnotationComposer,
      $$MasterDataTableCreateCompanionBuilder,
      $$MasterDataTableUpdateCompanionBuilder,
      (MasterDataData, $$MasterDataTableReferences),
      MasterDataData,
      PrefetchHooks Function({bool userId})
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      required String id,
      required String userId,
      required String title,
      required DateTime scheduledAt,
      Value<String> ledgerEntryId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> title,
      Value<DateTime> scheduledAt,
      Value<String> ledgerEntryId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, AppReminder> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('reminders__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ledgerEntryId => $composableBuilder(
    column: $table.ledgerEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ledgerEntryId => $composableBuilder(
    column: $table.ledgerEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ledgerEntryId => $composableBuilder(
    column: $table.ledgerEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          AppReminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (AppReminder, $$RemindersTableReferences),
          AppReminder,
          PrefetchHooks Function({bool userId})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<String> ledgerEntryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                userId: userId,
                title: title,
                scheduledAt: scheduledAt,
                ledgerEntryId: ledgerEntryId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String title,
                required DateTime scheduledAt,
                Value<String> ledgerEntryId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                scheduledAt: scheduledAt,
                ledgerEntryId: ledgerEntryId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$RemindersTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$RemindersTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      AppReminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (AppReminder, $$RemindersTableReferences),
      AppReminder,
      PrefetchHooks Function({bool userId})
    >;
typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      required String id,
      required String userId,
      required String vehicleType,
      required String make,
      required String model,
      Value<String> licensePlate,
      required int year,
      Value<String> fuelType,
      Value<double> tankCapacity,
      Value<double> purchasePrice,
      Value<double> currentValue,
      Value<DateTime?> purchaseDate,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> vehicleType,
      Value<String> make,
      Value<String> model,
      Value<String> licensePlate,
      Value<int> year,
      Value<String> fuelType,
      Value<double> tankCapacity,
      Value<double> purchasePrice,
      Value<double> currentValue,
      Value<DateTime?> purchaseDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('vehicles__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$VehicleCostsTable, List<VehicleCost>>
  _vehicleCostsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vehicleCosts,
    aliasName: 'vehicles__id__vehicle_costs__vehicle_id',
  );

  $$VehicleCostsTableProcessedTableManager get vehicleCostsRefs {
    final manager = $$VehicleCostsTableTableManager(
      $_db,
      $_db.vehicleCosts,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vehicleCostsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleType => $composableBuilder(
    column: $table.vehicleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tankCapacity => $composableBuilder(
    column: $table.tankCapacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> vehicleCostsRefs(
    Expression<bool> Function($$VehicleCostsTableFilterComposer f) f,
  ) {
    final $$VehicleCostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicleCosts,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleCostsTableFilterComposer(
            $db: $db,
            $table: $db.vehicleCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleType => $composableBuilder(
    column: $table.vehicleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tankCapacity => $composableBuilder(
    column: $table.tankCapacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vehicleType => $composableBuilder(
    column: $table.vehicleType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get make =>
      $composableBuilder(column: $table.make, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

  GeneratedColumn<double> get tankCapacity => $composableBuilder(
    column: $table.tankCapacity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> vehicleCostsRefs<T extends Object>(
    Expression<T> Function($$VehicleCostsTableAnnotationComposer a) f,
  ) {
    final $$VehicleCostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicleCosts,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleCostsTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicleCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          Vehicle,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (Vehicle, $$VehiclesTableReferences),
          Vehicle,
          PrefetchHooks Function({bool userId, bool vehicleCostsRefs})
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> vehicleType = const Value.absent(),
                Value<String> make = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String> licensePlate = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String> fuelType = const Value.absent(),
                Value<double> tankCapacity = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<double> currentValue = const Value.absent(),
                Value<DateTime?> purchaseDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                userId: userId,
                vehicleType: vehicleType,
                make: make,
                model: model,
                licensePlate: licensePlate,
                year: year,
                fuelType: fuelType,
                tankCapacity: tankCapacity,
                purchasePrice: purchasePrice,
                currentValue: currentValue,
                purchaseDate: purchaseDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String vehicleType,
                required String make,
                required String model,
                Value<String> licensePlate = const Value.absent(),
                required int year,
                Value<String> fuelType = const Value.absent(),
                Value<double> tankCapacity = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<double> currentValue = const Value.absent(),
                Value<DateTime?> purchaseDate = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                userId: userId,
                vehicleType: vehicleType,
                make: make,
                model: model,
                licensePlate: licensePlate,
                year: year,
                fuelType: fuelType,
                tankCapacity: tankCapacity,
                purchasePrice: purchasePrice,
                currentValue: currentValue,
                purchaseDate: purchaseDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false, vehicleCostsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (vehicleCostsRefs) db.vehicleCosts],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$VehiclesTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$VehiclesTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (vehicleCostsRefs)
                    await $_getPrefetchedData<
                      Vehicle,
                      $VehiclesTable,
                      VehicleCost
                    >(
                      currentTable: table,
                      referencedTable: $$VehiclesTableReferences
                          ._vehicleCostsRefsTable(db),
                      managerFromTypedResult: (p0) => $$VehiclesTableReferences(
                        db,
                        table,
                        p0,
                      ).vehicleCostsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.vehicleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      Vehicle,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (Vehicle, $$VehiclesTableReferences),
      Vehicle,
      PrefetchHooks Function({bool userId, bool vehicleCostsRefs})
    >;
typedef $$VehicleCostsTableCreateCompanionBuilder =
    VehicleCostsCompanion Function({
      required String id,
      required String userId,
      required String vehicleId,
      required DateTime bookingDate,
      required String category,
      required double amount,
      Value<double?> odometer,
      Value<String> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$VehicleCostsTableUpdateCompanionBuilder =
    VehicleCostsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> vehicleId,
      Value<DateTime> bookingDate,
      Value<String> category,
      Value<double> amount,
      Value<double?> odometer,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$VehicleCostsTableReferences
    extends BaseReferences<_$AppDatabase, $VehicleCostsTable, VehicleCost> {
  $$VehicleCostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('vehicle_costs__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('vehicle_costs__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<String>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VehicleCostsTableFilterComposer
    extends Composer<_$AppDatabase, $VehicleCostsTable> {
  $$VehicleCostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get bookingDate => $composableBuilder(
    column: $table.bookingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get odometer => $composableBuilder(
    column: $table.odometer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VehicleCostsTableOrderingComposer
    extends Composer<_$AppDatabase, $VehicleCostsTable> {
  $$VehicleCostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get bookingDate => $composableBuilder(
    column: $table.bookingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get odometer => $composableBuilder(
    column: $table.odometer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VehicleCostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehicleCostsTable> {
  $$VehicleCostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get bookingDate => $composableBuilder(
    column: $table.bookingDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get odometer =>
      $composableBuilder(column: $table.odometer, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VehicleCostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehicleCostsTable,
          VehicleCost,
          $$VehicleCostsTableFilterComposer,
          $$VehicleCostsTableOrderingComposer,
          $$VehicleCostsTableAnnotationComposer,
          $$VehicleCostsTableCreateCompanionBuilder,
          $$VehicleCostsTableUpdateCompanionBuilder,
          (VehicleCost, $$VehicleCostsTableReferences),
          VehicleCost,
          PrefetchHooks Function({bool userId, bool vehicleId})
        > {
  $$VehicleCostsTableTableManager(_$AppDatabase db, $VehicleCostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehicleCostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehicleCostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehicleCostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<DateTime> bookingDate = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double?> odometer = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehicleCostsCompanion(
                id: id,
                userId: userId,
                vehicleId: vehicleId,
                bookingDate: bookingDate,
                category: category,
                amount: amount,
                odometer: odometer,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String vehicleId,
                required DateTime bookingDate,
                required String category,
                required double amount,
                Value<double?> odometer = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehicleCostsCompanion.insert(
                id: id,
                userId: userId,
                vehicleId: vehicleId,
                bookingDate: bookingDate,
                category: category,
                amount: amount,
                odometer: odometer,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehicleCostsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false, vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$VehicleCostsTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$VehicleCostsTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable: $$VehicleCostsTableReferences
                                    ._vehicleIdTable(db),
                                referencedColumn: $$VehicleCostsTableReferences
                                    ._vehicleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VehicleCostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehicleCostsTable,
      VehicleCost,
      $$VehicleCostsTableFilterComposer,
      $$VehicleCostsTableOrderingComposer,
      $$VehicleCostsTableAnnotationComposer,
      $$VehicleCostsTableCreateCompanionBuilder,
      $$VehicleCostsTableUpdateCompanionBuilder,
      (VehicleCost, $$VehicleCostsTableReferences),
      VehicleCost,
      PrefetchHooks Function({bool userId, bool vehicleId})
    >;
typedef $$UserPreferencesTableCreateCompanionBuilder =
    UserPreferencesCompanion Function({
      required String userId,
      Value<String> themeMode,
      Value<String> locale,
      Value<String> currency,
      Value<String> dateFormat,
      Value<bool> serverMode,
      Value<String> serverUrl,
      Value<int> serverPort,
      Value<String> serverUsername,
      Value<String> selectedHouseholdAccountId,
      Value<String> selectedPortfolioAccountId,
      Value<double> taxAllowance,
      Value<double> defaultInvestmentFee,
      Value<bool> includePhysicalAssetsInTaxAllowance,
      Value<String> dataFilePath,
      Value<double> freedomAge,
      Value<double> freedomStartCapital,
      Value<bool> freedomUsePortfolio,
      Value<DateTime?> lastSyncAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserPreferencesTableUpdateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<String> userId,
      Value<String> themeMode,
      Value<String> locale,
      Value<String> currency,
      Value<String> dateFormat,
      Value<bool> serverMode,
      Value<String> serverUrl,
      Value<int> serverPort,
      Value<String> serverUsername,
      Value<String> selectedHouseholdAccountId,
      Value<String> selectedPortfolioAccountId,
      Value<double> taxAllowance,
      Value<double> defaultInvestmentFee,
      Value<bool> includePhysicalAssetsInTaxAllowance,
      Value<String> dataFilePath,
      Value<double> freedomAge,
      Value<double> freedomStartCapital,
      Value<bool> freedomUsePortfolio,
      Value<DateTime?> lastSyncAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$UserPreferencesTableReferences
    extends
        BaseReferences<_$AppDatabase, $UserPreferencesTable, UserPreference> {
  $$UserPreferencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('user_preferences__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateFormat => $composableBuilder(
    column: $table.dateFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get serverMode => $composableBuilder(
    column: $table.serverMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverUrl => $composableBuilder(
    column: $table.serverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverPort => $composableBuilder(
    column: $table.serverPort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverUsername => $composableBuilder(
    column: $table.serverUsername,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedHouseholdAccountId => $composableBuilder(
    column: $table.selectedHouseholdAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedPortfolioAccountId => $composableBuilder(
    column: $table.selectedPortfolioAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxAllowance => $composableBuilder(
    column: $table.taxAllowance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultInvestmentFee => $composableBuilder(
    column: $table.defaultInvestmentFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includePhysicalAssetsInTaxAllowance =>
      $composableBuilder(
        column: $table.includePhysicalAssetsInTaxAllowance,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get dataFilePath => $composableBuilder(
    column: $table.dataFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get freedomAge => $composableBuilder(
    column: $table.freedomAge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get freedomStartCapital => $composableBuilder(
    column: $table.freedomStartCapital,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get freedomUsePortfolio => $composableBuilder(
    column: $table.freedomUsePortfolio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateFormat => $composableBuilder(
    column: $table.dateFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get serverMode => $composableBuilder(
    column: $table.serverMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverUrl => $composableBuilder(
    column: $table.serverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverPort => $composableBuilder(
    column: $table.serverPort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverUsername => $composableBuilder(
    column: $table.serverUsername,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedHouseholdAccountId => $composableBuilder(
    column: $table.selectedHouseholdAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedPortfolioAccountId => $composableBuilder(
    column: $table.selectedPortfolioAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxAllowance => $composableBuilder(
    column: $table.taxAllowance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultInvestmentFee => $composableBuilder(
    column: $table.defaultInvestmentFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includePhysicalAssetsInTaxAllowance =>
      $composableBuilder(
        column: $table.includePhysicalAssetsInTaxAllowance,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get dataFilePath => $composableBuilder(
    column: $table.dataFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get freedomAge => $composableBuilder(
    column: $table.freedomAge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get freedomStartCapital => $composableBuilder(
    column: $table.freedomStartCapital,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get freedomUsePortfolio => $composableBuilder(
    column: $table.freedomUsePortfolio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get dateFormat => $composableBuilder(
    column: $table.dateFormat,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get serverMode => $composableBuilder(
    column: $table.serverMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverUrl =>
      $composableBuilder(column: $table.serverUrl, builder: (column) => column);

  GeneratedColumn<int> get serverPort => $composableBuilder(
    column: $table.serverPort,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverUsername => $composableBuilder(
    column: $table.serverUsername,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedHouseholdAccountId => $composableBuilder(
    column: $table.selectedHouseholdAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedPortfolioAccountId => $composableBuilder(
    column: $table.selectedPortfolioAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxAllowance => $composableBuilder(
    column: $table.taxAllowance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultInvestmentFee => $composableBuilder(
    column: $table.defaultInvestmentFee,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includePhysicalAssetsInTaxAllowance =>
      $composableBuilder(
        column: $table.includePhysicalAssetsInTaxAllowance,
        builder: (column) => column,
      );

  GeneratedColumn<String> get dataFilePath => $composableBuilder(
    column: $table.dataFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<double> get freedomAge => $composableBuilder(
    column: $table.freedomAge,
    builder: (column) => column,
  );

  GeneratedColumn<double> get freedomStartCapital => $composableBuilder(
    column: $table.freedomStartCapital,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get freedomUsePortfolio => $composableBuilder(
    column: $table.freedomUsePortfolio,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPreferencesTable,
          UserPreference,
          $$UserPreferencesTableFilterComposer,
          $$UserPreferencesTableOrderingComposer,
          $$UserPreferencesTableAnnotationComposer,
          $$UserPreferencesTableCreateCompanionBuilder,
          $$UserPreferencesTableUpdateCompanionBuilder,
          (UserPreference, $$UserPreferencesTableReferences),
          UserPreference,
          PrefetchHooks Function({bool userId})
        > {
  $$UserPreferencesTableTableManager(
    _$AppDatabase db,
    $UserPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> dateFormat = const Value.absent(),
                Value<bool> serverMode = const Value.absent(),
                Value<String> serverUrl = const Value.absent(),
                Value<int> serverPort = const Value.absent(),
                Value<String> serverUsername = const Value.absent(),
                Value<String> selectedHouseholdAccountId = const Value.absent(),
                Value<String> selectedPortfolioAccountId = const Value.absent(),
                Value<double> taxAllowance = const Value.absent(),
                Value<double> defaultInvestmentFee = const Value.absent(),
                Value<bool> includePhysicalAssetsInTaxAllowance =
                    const Value.absent(),
                Value<String> dataFilePath = const Value.absent(),
                Value<double> freedomAge = const Value.absent(),
                Value<double> freedomStartCapital = const Value.absent(),
                Value<bool> freedomUsePortfolio = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPreferencesCompanion(
                userId: userId,
                themeMode: themeMode,
                locale: locale,
                currency: currency,
                dateFormat: dateFormat,
                serverMode: serverMode,
                serverUrl: serverUrl,
                serverPort: serverPort,
                serverUsername: serverUsername,
                selectedHouseholdAccountId: selectedHouseholdAccountId,
                selectedPortfolioAccountId: selectedPortfolioAccountId,
                taxAllowance: taxAllowance,
                defaultInvestmentFee: defaultInvestmentFee,
                includePhysicalAssetsInTaxAllowance:
                    includePhysicalAssetsInTaxAllowance,
                dataFilePath: dataFilePath,
                freedomAge: freedomAge,
                freedomStartCapital: freedomStartCapital,
                freedomUsePortfolio: freedomUsePortfolio,
                lastSyncAt: lastSyncAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<String> themeMode = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> dateFormat = const Value.absent(),
                Value<bool> serverMode = const Value.absent(),
                Value<String> serverUrl = const Value.absent(),
                Value<int> serverPort = const Value.absent(),
                Value<String> serverUsername = const Value.absent(),
                Value<String> selectedHouseholdAccountId = const Value.absent(),
                Value<String> selectedPortfolioAccountId = const Value.absent(),
                Value<double> taxAllowance = const Value.absent(),
                Value<double> defaultInvestmentFee = const Value.absent(),
                Value<bool> includePhysicalAssetsInTaxAllowance =
                    const Value.absent(),
                Value<String> dataFilePath = const Value.absent(),
                Value<double> freedomAge = const Value.absent(),
                Value<double> freedomStartCapital = const Value.absent(),
                Value<bool> freedomUsePortfolio = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserPreferencesCompanion.insert(
                userId: userId,
                themeMode: themeMode,
                locale: locale,
                currency: currency,
                dateFormat: dateFormat,
                serverMode: serverMode,
                serverUrl: serverUrl,
                serverPort: serverPort,
                serverUsername: serverUsername,
                selectedHouseholdAccountId: selectedHouseholdAccountId,
                selectedPortfolioAccountId: selectedPortfolioAccountId,
                taxAllowance: taxAllowance,
                defaultInvestmentFee: defaultInvestmentFee,
                includePhysicalAssetsInTaxAllowance:
                    includePhysicalAssetsInTaxAllowance,
                dataFilePath: dataFilePath,
                freedomAge: freedomAge,
                freedomStartCapital: freedomStartCapital,
                freedomUsePortfolio: freedomUsePortfolio,
                lastSyncAt: lastSyncAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserPreferencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$UserPreferencesTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$UserPreferencesTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPreferencesTable,
      UserPreference,
      $$UserPreferencesTableFilterComposer,
      $$UserPreferencesTableOrderingComposer,
      $$UserPreferencesTableAnnotationComposer,
      $$UserPreferencesTableCreateCompanionBuilder,
      $$UserPreferencesTableUpdateCompanionBuilder,
      (UserPreference, $$UserPreferencesTableReferences),
      UserPreference,
      PrefetchHooks Function({bool userId})
    >;
typedef $$NetWorthSnapshotsTableCreateCompanionBuilder =
    NetWorthSnapshotsCompanion Function({
      required String id,
      required String userId,
      required DateTime capturedAt,
      required double accountBalance,
      required double portfolioValue,
      required double totalNetWorth,
      Value<int> rowid,
    });
typedef $$NetWorthSnapshotsTableUpdateCompanionBuilder =
    NetWorthSnapshotsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<DateTime> capturedAt,
      Value<double> accountBalance,
      Value<double> portfolioValue,
      Value<double> totalNetWorth,
      Value<int> rowid,
    });

final class $$NetWorthSnapshotsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NetWorthSnapshotsTable,
          NetWorthSnapshot
        > {
  $$NetWorthSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('net_worth_snapshots__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NetWorthSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $NetWorthSnapshotsTable> {
  $$NetWorthSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accountBalance => $composableBuilder(
    column: $table.accountBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get portfolioValue => $composableBuilder(
    column: $table.portfolioValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalNetWorth => $composableBuilder(
    column: $table.totalNetWorth,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NetWorthSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $NetWorthSnapshotsTable> {
  $$NetWorthSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accountBalance => $composableBuilder(
    column: $table.accountBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get portfolioValue => $composableBuilder(
    column: $table.portfolioValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalNetWorth => $composableBuilder(
    column: $table.totalNetWorth,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NetWorthSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NetWorthSnapshotsTable> {
  $$NetWorthSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accountBalance => $composableBuilder(
    column: $table.accountBalance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get portfolioValue => $composableBuilder(
    column: $table.portfolioValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalNetWorth => $composableBuilder(
    column: $table.totalNetWorth,
    builder: (column) => column,
  );

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NetWorthSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NetWorthSnapshotsTable,
          NetWorthSnapshot,
          $$NetWorthSnapshotsTableFilterComposer,
          $$NetWorthSnapshotsTableOrderingComposer,
          $$NetWorthSnapshotsTableAnnotationComposer,
          $$NetWorthSnapshotsTableCreateCompanionBuilder,
          $$NetWorthSnapshotsTableUpdateCompanionBuilder,
          (NetWorthSnapshot, $$NetWorthSnapshotsTableReferences),
          NetWorthSnapshot,
          PrefetchHooks Function({bool userId})
        > {
  $$NetWorthSnapshotsTableTableManager(
    _$AppDatabase db,
    $NetWorthSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NetWorthSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NetWorthSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NetWorthSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<double> accountBalance = const Value.absent(),
                Value<double> portfolioValue = const Value.absent(),
                Value<double> totalNetWorth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NetWorthSnapshotsCompanion(
                id: id,
                userId: userId,
                capturedAt: capturedAt,
                accountBalance: accountBalance,
                portfolioValue: portfolioValue,
                totalNetWorth: totalNetWorth,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required DateTime capturedAt,
                required double accountBalance,
                required double portfolioValue,
                required double totalNetWorth,
                Value<int> rowid = const Value.absent(),
              }) => NetWorthSnapshotsCompanion.insert(
                id: id,
                userId: userId,
                capturedAt: capturedAt,
                accountBalance: accountBalance,
                portfolioValue: portfolioValue,
                totalNetWorth: totalNetWorth,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NetWorthSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$NetWorthSnapshotsTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$NetWorthSnapshotsTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NetWorthSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NetWorthSnapshotsTable,
      NetWorthSnapshot,
      $$NetWorthSnapshotsTableFilterComposer,
      $$NetWorthSnapshotsTableOrderingComposer,
      $$NetWorthSnapshotsTableAnnotationComposer,
      $$NetWorthSnapshotsTableCreateCompanionBuilder,
      $$NetWorthSnapshotsTableUpdateCompanionBuilder,
      (NetWorthSnapshot, $$NetWorthSnapshotsTableReferences),
      NetWorthSnapshot,
      PrefetchHooks Function({bool userId})
    >;
typedef $$StockMastersTableCreateCompanionBuilder =
    StockMastersCompanion Function({
      required String id,
      required String name,
      required String symbol,
      Value<String> isin,
      Value<String> wkn,
      Value<String> currency,
      Value<String> dividendCurrency,
      Value<String> country,
      Value<String> exchange,
      Value<String> broker,
      Value<String> sector,
      Value<String> dividendFrequency,
      Value<int> dividendStartMonth,
      Value<String> companyData,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$StockMastersTableUpdateCompanionBuilder =
    StockMastersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> symbol,
      Value<String> isin,
      Value<String> wkn,
      Value<String> currency,
      Value<String> dividendCurrency,
      Value<String> country,
      Value<String> exchange,
      Value<String> broker,
      Value<String> sector,
      Value<String> dividendFrequency,
      Value<int> dividendStartMonth,
      Value<String> companyData,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$StockMastersTableReferences
    extends BaseReferences<_$AppDatabase, $StockMastersTable, StockMaster> {
  $$StockMastersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StockPricesTable, List<StockPrice>>
  _stockPricesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockPrices,
    aliasName: 'stock_masters__id__stock_prices__stock_id',
  );

  $$StockPricesTableProcessedTableManager get stockPricesRefs {
    final manager = $$StockPricesTableTableManager(
      $_db,
      $_db.stockPrices,
    ).filter((f) => f.stockId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockPricesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockDividendsTable, List<StockDividend>>
  _stockDividendsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockDividends,
    aliasName: 'stock_masters__id__stock_dividends__stock_id',
  );

  $$StockDividendsTableProcessedTableManager get stockDividendsRefs {
    final manager = $$StockDividendsTableTableManager(
      $_db,
      $_db.stockDividends,
    ).filter((f) => f.stockId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockDividendsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StockMastersTableFilterComposer
    extends Composer<_$AppDatabase, $StockMastersTable> {
  $$StockMastersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wkn => $composableBuilder(
    column: $table.wkn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dividendCurrency => $composableBuilder(
    column: $table.dividendCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exchange => $composableBuilder(
    column: $table.exchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get broker => $composableBuilder(
    column: $table.broker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dividendFrequency => $composableBuilder(
    column: $table.dividendFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dividendStartMonth => $composableBuilder(
    column: $table.dividendStartMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyData => $composableBuilder(
    column: $table.companyData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> stockPricesRefs(
    Expression<bool> Function($$StockPricesTableFilterComposer f) f,
  ) {
    final $$StockPricesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockPrices,
      getReferencedColumn: (t) => t.stockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockPricesTableFilterComposer(
            $db: $db,
            $table: $db.stockPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockDividendsRefs(
    Expression<bool> Function($$StockDividendsTableFilterComposer f) f,
  ) {
    final $$StockDividendsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockDividends,
      getReferencedColumn: (t) => t.stockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockDividendsTableFilterComposer(
            $db: $db,
            $table: $db.stockDividends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StockMastersTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMastersTable> {
  $$StockMastersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isin => $composableBuilder(
    column: $table.isin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wkn => $composableBuilder(
    column: $table.wkn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dividendCurrency => $composableBuilder(
    column: $table.dividendCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exchange => $composableBuilder(
    column: $table.exchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get broker => $composableBuilder(
    column: $table.broker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dividendFrequency => $composableBuilder(
    column: $table.dividendFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dividendStartMonth => $composableBuilder(
    column: $table.dividendStartMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyData => $composableBuilder(
    column: $table.companyData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockMastersTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMastersTable> {
  $$StockMastersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get isin =>
      $composableBuilder(column: $table.isin, builder: (column) => column);

  GeneratedColumn<String> get wkn =>
      $composableBuilder(column: $table.wkn, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get dividendCurrency => $composableBuilder(
    column: $table.dividendCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get exchange =>
      $composableBuilder(column: $table.exchange, builder: (column) => column);

  GeneratedColumn<String> get broker =>
      $composableBuilder(column: $table.broker, builder: (column) => column);

  GeneratedColumn<String> get sector =>
      $composableBuilder(column: $table.sector, builder: (column) => column);

  GeneratedColumn<String> get dividendFrequency => $composableBuilder(
    column: $table.dividendFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dividendStartMonth => $composableBuilder(
    column: $table.dividendStartMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get companyData => $composableBuilder(
    column: $table.companyData,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> stockPricesRefs<T extends Object>(
    Expression<T> Function($$StockPricesTableAnnotationComposer a) f,
  ) {
    final $$StockPricesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockPrices,
      getReferencedColumn: (t) => t.stockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockPricesTableAnnotationComposer(
            $db: $db,
            $table: $db.stockPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockDividendsRefs<T extends Object>(
    Expression<T> Function($$StockDividendsTableAnnotationComposer a) f,
  ) {
    final $$StockDividendsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockDividends,
      getReferencedColumn: (t) => t.stockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockDividendsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockDividends,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StockMastersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockMastersTable,
          StockMaster,
          $$StockMastersTableFilterComposer,
          $$StockMastersTableOrderingComposer,
          $$StockMastersTableAnnotationComposer,
          $$StockMastersTableCreateCompanionBuilder,
          $$StockMastersTableUpdateCompanionBuilder,
          (StockMaster, $$StockMastersTableReferences),
          StockMaster,
          PrefetchHooks Function({
            bool stockPricesRefs,
            bool stockDividendsRefs,
          })
        > {
  $$StockMastersTableTableManager(_$AppDatabase db, $StockMastersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMastersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMastersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMastersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> isin = const Value.absent(),
                Value<String> wkn = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> dividendCurrency = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> exchange = const Value.absent(),
                Value<String> broker = const Value.absent(),
                Value<String> sector = const Value.absent(),
                Value<String> dividendFrequency = const Value.absent(),
                Value<int> dividendStartMonth = const Value.absent(),
                Value<String> companyData = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMastersCompanion(
                id: id,
                name: name,
                symbol: symbol,
                isin: isin,
                wkn: wkn,
                currency: currency,
                dividendCurrency: dividendCurrency,
                country: country,
                exchange: exchange,
                broker: broker,
                sector: sector,
                dividendFrequency: dividendFrequency,
                dividendStartMonth: dividendStartMonth,
                companyData: companyData,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String symbol,
                Value<String> isin = const Value.absent(),
                Value<String> wkn = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> dividendCurrency = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> exchange = const Value.absent(),
                Value<String> broker = const Value.absent(),
                Value<String> sector = const Value.absent(),
                Value<String> dividendFrequency = const Value.absent(),
                Value<int> dividendStartMonth = const Value.absent(),
                Value<String> companyData = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMastersCompanion.insert(
                id: id,
                name: name,
                symbol: symbol,
                isin: isin,
                wkn: wkn,
                currency: currency,
                dividendCurrency: dividendCurrency,
                country: country,
                exchange: exchange,
                broker: broker,
                sector: sector,
                dividendFrequency: dividendFrequency,
                dividendStartMonth: dividendStartMonth,
                companyData: companyData,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockMastersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({stockPricesRefs = false, stockDividendsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stockPricesRefs) db.stockPrices,
                    if (stockDividendsRefs) db.stockDividends,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stockPricesRefs)
                        await $_getPrefetchedData<
                          StockMaster,
                          $StockMastersTable,
                          StockPrice
                        >(
                          currentTable: table,
                          referencedTable: $$StockMastersTableReferences
                              ._stockPricesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StockMastersTableReferences(
                                db,
                                table,
                                p0,
                              ).stockPricesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stockId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockDividendsRefs)
                        await $_getPrefetchedData<
                          StockMaster,
                          $StockMastersTable,
                          StockDividend
                        >(
                          currentTable: table,
                          referencedTable: $$StockMastersTableReferences
                              ._stockDividendsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StockMastersTableReferences(
                                db,
                                table,
                                p0,
                              ).stockDividendsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stockId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StockMastersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockMastersTable,
      StockMaster,
      $$StockMastersTableFilterComposer,
      $$StockMastersTableOrderingComposer,
      $$StockMastersTableAnnotationComposer,
      $$StockMastersTableCreateCompanionBuilder,
      $$StockMastersTableUpdateCompanionBuilder,
      (StockMaster, $$StockMastersTableReferences),
      StockMaster,
      PrefetchHooks Function({bool stockPricesRefs, bool stockDividendsRefs})
    >;
typedef $$StockPricesTableCreateCompanionBuilder =
    StockPricesCompanion Function({
      required String stockId,
      required double price,
      Value<String> currency,
      required DateTime quotedAt,
      Value<int> rowid,
    });
typedef $$StockPricesTableUpdateCompanionBuilder =
    StockPricesCompanion Function({
      Value<String> stockId,
      Value<double> price,
      Value<String> currency,
      Value<DateTime> quotedAt,
      Value<int> rowid,
    });

final class $$StockPricesTableReferences
    extends BaseReferences<_$AppDatabase, $StockPricesTable, StockPrice> {
  $$StockPricesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StockMastersTable _stockIdTable(_$AppDatabase db) =>
      db.stockMasters.createAlias('stock_prices__stock_id__stock_masters__id');

  $$StockMastersTableProcessedTableManager get stockId {
    final $_column = $_itemColumn<String>('stock_id')!;

    final manager = $$StockMastersTableTableManager(
      $_db,
      $_db.stockMasters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stockIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockPricesTableFilterComposer
    extends Composer<_$AppDatabase, $StockPricesTable> {
  $$StockPricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get quotedAt => $composableBuilder(
    column: $table.quotedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StockMastersTableFilterComposer get stockId {
    final $$StockMastersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockId,
      referencedTable: $db.stockMasters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMastersTableFilterComposer(
            $db: $db,
            $table: $db.stockMasters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockPricesTableOrderingComposer
    extends Composer<_$AppDatabase, $StockPricesTable> {
  $$StockPricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get quotedAt => $composableBuilder(
    column: $table.quotedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StockMastersTableOrderingComposer get stockId {
    final $$StockMastersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockId,
      referencedTable: $db.stockMasters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMastersTableOrderingComposer(
            $db: $db,
            $table: $db.stockMasters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockPricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockPricesTable> {
  $$StockPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get quotedAt =>
      $composableBuilder(column: $table.quotedAt, builder: (column) => column);

  $$StockMastersTableAnnotationComposer get stockId {
    final $$StockMastersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockId,
      referencedTable: $db.stockMasters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMastersTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMasters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockPricesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockPricesTable,
          StockPrice,
          $$StockPricesTableFilterComposer,
          $$StockPricesTableOrderingComposer,
          $$StockPricesTableAnnotationComposer,
          $$StockPricesTableCreateCompanionBuilder,
          $$StockPricesTableUpdateCompanionBuilder,
          (StockPrice, $$StockPricesTableReferences),
          StockPrice,
          PrefetchHooks Function({bool stockId})
        > {
  $$StockPricesTableTableManager(_$AppDatabase db, $StockPricesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockPricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> stockId = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> quotedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockPricesCompanion(
                stockId: stockId,
                price: price,
                currency: currency,
                quotedAt: quotedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String stockId,
                required double price,
                Value<String> currency = const Value.absent(),
                required DateTime quotedAt,
                Value<int> rowid = const Value.absent(),
              }) => StockPricesCompanion.insert(
                stockId: stockId,
                price: price,
                currency: currency,
                quotedAt: quotedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockPricesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stockId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (stockId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.stockId,
                                referencedTable: $$StockPricesTableReferences
                                    ._stockIdTable(db),
                                referencedColumn: $$StockPricesTableReferences
                                    ._stockIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StockPricesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockPricesTable,
      StockPrice,
      $$StockPricesTableFilterComposer,
      $$StockPricesTableOrderingComposer,
      $$StockPricesTableAnnotationComposer,
      $$StockPricesTableCreateCompanionBuilder,
      $$StockPricesTableUpdateCompanionBuilder,
      (StockPrice, $$StockPricesTableReferences),
      StockPrice,
      PrefetchHooks Function({bool stockId})
    >;
typedef $$StockDividendsTableCreateCompanionBuilder =
    StockDividendsCompanion Function({
      required String id,
      required String stockId,
      required DateTime exDate,
      Value<DateTime?> paymentDate,
      required double amount,
      Value<String> currency,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$StockDividendsTableUpdateCompanionBuilder =
    StockDividendsCompanion Function({
      Value<String> id,
      Value<String> stockId,
      Value<DateTime> exDate,
      Value<DateTime?> paymentDate,
      Value<double> amount,
      Value<String> currency,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

final class $$StockDividendsTableReferences
    extends BaseReferences<_$AppDatabase, $StockDividendsTable, StockDividend> {
  $$StockDividendsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StockMastersTable _stockIdTable(_$AppDatabase db) => db.stockMasters
      .createAlias('stock_dividends__stock_id__stock_masters__id');

  $$StockMastersTableProcessedTableManager get stockId {
    final $_column = $_itemColumn<String>('stock_id')!;

    final manager = $$StockMastersTableTableManager(
      $_db,
      $_db.stockMasters,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stockIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockDividendsTableFilterComposer
    extends Composer<_$AppDatabase, $StockDividendsTable> {
  $$StockDividendsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get exDate => $composableBuilder(
    column: $table.exDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StockMastersTableFilterComposer get stockId {
    final $$StockMastersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockId,
      referencedTable: $db.stockMasters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMastersTableFilterComposer(
            $db: $db,
            $table: $db.stockMasters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockDividendsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockDividendsTable> {
  $$StockDividendsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get exDate => $composableBuilder(
    column: $table.exDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StockMastersTableOrderingComposer get stockId {
    final $$StockMastersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockId,
      referencedTable: $db.stockMasters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMastersTableOrderingComposer(
            $db: $db,
            $table: $db.stockMasters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockDividendsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockDividendsTable> {
  $$StockDividendsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get exDate =>
      $composableBuilder(column: $table.exDate, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  $$StockMastersTableAnnotationComposer get stockId {
    final $$StockMastersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockId,
      referencedTable: $db.stockMasters,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMastersTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMasters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockDividendsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockDividendsTable,
          StockDividend,
          $$StockDividendsTableFilterComposer,
          $$StockDividendsTableOrderingComposer,
          $$StockDividendsTableAnnotationComposer,
          $$StockDividendsTableCreateCompanionBuilder,
          $$StockDividendsTableUpdateCompanionBuilder,
          (StockDividend, $$StockDividendsTableReferences),
          StockDividend,
          PrefetchHooks Function({bool stockId})
        > {
  $$StockDividendsTableTableManager(
    _$AppDatabase db,
    $StockDividendsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockDividendsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockDividendsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockDividendsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> stockId = const Value.absent(),
                Value<DateTime> exDate = const Value.absent(),
                Value<DateTime?> paymentDate = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockDividendsCompanion(
                id: id,
                stockId: stockId,
                exDate: exDate,
                paymentDate: paymentDate,
                amount: amount,
                currency: currency,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String stockId,
                required DateTime exDate,
                Value<DateTime?> paymentDate = const Value.absent(),
                required double amount,
                Value<String> currency = const Value.absent(),
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => StockDividendsCompanion.insert(
                id: id,
                stockId: stockId,
                exDate: exDate,
                paymentDate: paymentDate,
                amount: amount,
                currency: currency,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockDividendsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stockId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (stockId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.stockId,
                                referencedTable: $$StockDividendsTableReferences
                                    ._stockIdTable(db),
                                referencedColumn:
                                    $$StockDividendsTableReferences
                                        ._stockIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StockDividendsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockDividendsTable,
      StockDividend,
      $$StockDividendsTableFilterComposer,
      $$StockDividendsTableOrderingComposer,
      $$StockDividendsTableAnnotationComposer,
      $$StockDividendsTableCreateCompanionBuilder,
      $$StockDividendsTableUpdateCompanionBuilder,
      (StockDividend, $$StockDividendsTableReferences),
      StockDividend,
      PrefetchHooks Function({bool stockId})
    >;
typedef $$MarketDataRefreshesTableCreateCompanionBuilder =
    MarketDataRefreshesCompanion Function({
      required String dataType,
      required String scopeKey,
      required DateTime refreshedAt,
      Value<int> rowid,
    });
typedef $$MarketDataRefreshesTableUpdateCompanionBuilder =
    MarketDataRefreshesCompanion Function({
      Value<String> dataType,
      Value<String> scopeKey,
      Value<DateTime> refreshedAt,
      Value<int> rowid,
    });

class $$MarketDataRefreshesTableFilterComposer
    extends Composer<_$AppDatabase, $MarketDataRefreshesTable> {
  $$MarketDataRefreshesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeKey => $composableBuilder(
    column: $table.scopeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get refreshedAt => $composableBuilder(
    column: $table.refreshedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MarketDataRefreshesTableOrderingComposer
    extends Composer<_$AppDatabase, $MarketDataRefreshesTable> {
  $$MarketDataRefreshesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeKey => $composableBuilder(
    column: $table.scopeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get refreshedAt => $composableBuilder(
    column: $table.refreshedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MarketDataRefreshesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarketDataRefreshesTable> {
  $$MarketDataRefreshesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dataType =>
      $composableBuilder(column: $table.dataType, builder: (column) => column);

  GeneratedColumn<String> get scopeKey =>
      $composableBuilder(column: $table.scopeKey, builder: (column) => column);

  GeneratedColumn<DateTime> get refreshedAt => $composableBuilder(
    column: $table.refreshedAt,
    builder: (column) => column,
  );
}

class $$MarketDataRefreshesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MarketDataRefreshesTable,
          MarketDataRefreshe,
          $$MarketDataRefreshesTableFilterComposer,
          $$MarketDataRefreshesTableOrderingComposer,
          $$MarketDataRefreshesTableAnnotationComposer,
          $$MarketDataRefreshesTableCreateCompanionBuilder,
          $$MarketDataRefreshesTableUpdateCompanionBuilder,
          (
            MarketDataRefreshe,
            BaseReferences<
              _$AppDatabase,
              $MarketDataRefreshesTable,
              MarketDataRefreshe
            >,
          ),
          MarketDataRefreshe,
          PrefetchHooks Function()
        > {
  $$MarketDataRefreshesTableTableManager(
    _$AppDatabase db,
    $MarketDataRefreshesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarketDataRefreshesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MarketDataRefreshesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MarketDataRefreshesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> dataType = const Value.absent(),
                Value<String> scopeKey = const Value.absent(),
                Value<DateTime> refreshedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarketDataRefreshesCompanion(
                dataType: dataType,
                scopeKey: scopeKey,
                refreshedAt: refreshedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dataType,
                required String scopeKey,
                required DateTime refreshedAt,
                Value<int> rowid = const Value.absent(),
              }) => MarketDataRefreshesCompanion.insert(
                dataType: dataType,
                scopeKey: scopeKey,
                refreshedAt: refreshedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MarketDataRefreshesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MarketDataRefreshesTable,
      MarketDataRefreshe,
      $$MarketDataRefreshesTableFilterComposer,
      $$MarketDataRefreshesTableOrderingComposer,
      $$MarketDataRefreshesTableAnnotationComposer,
      $$MarketDataRefreshesTableCreateCompanionBuilder,
      $$MarketDataRefreshesTableUpdateCompanionBuilder,
      (
        MarketDataRefreshe,
        BaseReferences<
          _$AppDatabase,
          $MarketDataRefreshesTable,
          MarketDataRefreshe
        >,
      ),
      MarketDataRefreshe,
      PrefetchHooks Function()
    >;
typedef $$ApiRequestDaysTableCreateCompanionBuilder =
    ApiRequestDaysCompanion Function({
      required String day,
      Value<int> requestCount,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ApiRequestDaysTableUpdateCompanionBuilder =
    ApiRequestDaysCompanion Function({
      Value<String> day,
      Value<int> requestCount,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ApiRequestDaysTableFilterComposer
    extends Composer<_$AppDatabase, $ApiRequestDaysTable> {
  $$ApiRequestDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestCount => $composableBuilder(
    column: $table.requestCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ApiRequestDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $ApiRequestDaysTable> {
  $$ApiRequestDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestCount => $composableBuilder(
    column: $table.requestCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ApiRequestDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApiRequestDaysTable> {
  $$ApiRequestDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get requestCount => $composableBuilder(
    column: $table.requestCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ApiRequestDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApiRequestDaysTable,
          ApiRequestDay,
          $$ApiRequestDaysTableFilterComposer,
          $$ApiRequestDaysTableOrderingComposer,
          $$ApiRequestDaysTableAnnotationComposer,
          $$ApiRequestDaysTableCreateCompanionBuilder,
          $$ApiRequestDaysTableUpdateCompanionBuilder,
          (
            ApiRequestDay,
            BaseReferences<_$AppDatabase, $ApiRequestDaysTable, ApiRequestDay>,
          ),
          ApiRequestDay,
          PrefetchHooks Function()
        > {
  $$ApiRequestDaysTableTableManager(
    _$AppDatabase db,
    $ApiRequestDaysTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApiRequestDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApiRequestDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApiRequestDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<int> requestCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiRequestDaysCompanion(
                day: day,
                requestCount: requestCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                Value<int> requestCount = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ApiRequestDaysCompanion.insert(
                day: day,
                requestCount: requestCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ApiRequestDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApiRequestDaysTable,
      ApiRequestDay,
      $$ApiRequestDaysTableFilterComposer,
      $$ApiRequestDaysTableOrderingComposer,
      $$ApiRequestDaysTableAnnotationComposer,
      $$ApiRequestDaysTableCreateCompanionBuilder,
      $$ApiRequestDaysTableUpdateCompanionBuilder,
      (
        ApiRequestDay,
        BaseReferences<_$AppDatabase, $ApiRequestDaysTable, ApiRequestDay>,
      ),
      ApiRequestDay,
      PrefetchHooks Function()
    >;
typedef $$CountryTaxRatesTableCreateCompanionBuilder =
    CountryTaxRatesCompanion Function({
      required String country,
      Value<double> withholdingTaxRate,
      Value<String> currency,
      Value<double> exchangeRate,
      Value<bool> allowManualExchangeRate,
      Value<DateTime?> exchangeRateUpdatedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CountryTaxRatesTableUpdateCompanionBuilder =
    CountryTaxRatesCompanion Function({
      Value<String> country,
      Value<double> withholdingTaxRate,
      Value<String> currency,
      Value<double> exchangeRate,
      Value<bool> allowManualExchangeRate,
      Value<DateTime?> exchangeRateUpdatedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CountryTaxRatesTableFilterComposer
    extends Composer<_$AppDatabase, $CountryTaxRatesTable> {
  $$CountryTaxRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get withholdingTaxRate => $composableBuilder(
    column: $table.withholdingTaxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get exchangeRate => $composableBuilder(
    column: $table.exchangeRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowManualExchangeRate => $composableBuilder(
    column: $table.allowManualExchangeRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get exchangeRateUpdatedAt => $composableBuilder(
    column: $table.exchangeRateUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CountryTaxRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CountryTaxRatesTable> {
  $$CountryTaxRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get withholdingTaxRate => $composableBuilder(
    column: $table.withholdingTaxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get exchangeRate => $composableBuilder(
    column: $table.exchangeRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowManualExchangeRate => $composableBuilder(
    column: $table.allowManualExchangeRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get exchangeRateUpdatedAt => $composableBuilder(
    column: $table.exchangeRateUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CountryTaxRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountryTaxRatesTable> {
  $$CountryTaxRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<double> get withholdingTaxRate => $composableBuilder(
    column: $table.withholdingTaxRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<double> get exchangeRate => $composableBuilder(
    column: $table.exchangeRate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowManualExchangeRate => $composableBuilder(
    column: $table.allowManualExchangeRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get exchangeRateUpdatedAt => $composableBuilder(
    column: $table.exchangeRateUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CountryTaxRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CountryTaxRatesTable,
          CountryTaxRate,
          $$CountryTaxRatesTableFilterComposer,
          $$CountryTaxRatesTableOrderingComposer,
          $$CountryTaxRatesTableAnnotationComposer,
          $$CountryTaxRatesTableCreateCompanionBuilder,
          $$CountryTaxRatesTableUpdateCompanionBuilder,
          (
            CountryTaxRate,
            BaseReferences<
              _$AppDatabase,
              $CountryTaxRatesTable,
              CountryTaxRate
            >,
          ),
          CountryTaxRate,
          PrefetchHooks Function()
        > {
  $$CountryTaxRatesTableTableManager(
    _$AppDatabase db,
    $CountryTaxRatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountryTaxRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountryTaxRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountryTaxRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> country = const Value.absent(),
                Value<double> withholdingTaxRate = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<double> exchangeRate = const Value.absent(),
                Value<bool> allowManualExchangeRate = const Value.absent(),
                Value<DateTime?> exchangeRateUpdatedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CountryTaxRatesCompanion(
                country: country,
                withholdingTaxRate: withholdingTaxRate,
                currency: currency,
                exchangeRate: exchangeRate,
                allowManualExchangeRate: allowManualExchangeRate,
                exchangeRateUpdatedAt: exchangeRateUpdatedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String country,
                Value<double> withholdingTaxRate = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<double> exchangeRate = const Value.absent(),
                Value<bool> allowManualExchangeRate = const Value.absent(),
                Value<DateTime?> exchangeRateUpdatedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CountryTaxRatesCompanion.insert(
                country: country,
                withholdingTaxRate: withholdingTaxRate,
                currency: currency,
                exchangeRate: exchangeRate,
                allowManualExchangeRate: allowManualExchangeRate,
                exchangeRateUpdatedAt: exchangeRateUpdatedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CountryTaxRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CountryTaxRatesTable,
      CountryTaxRate,
      $$CountryTaxRatesTableFilterComposer,
      $$CountryTaxRatesTableOrderingComposer,
      $$CountryTaxRatesTableAnnotationComposer,
      $$CountryTaxRatesTableCreateCompanionBuilder,
      $$CountryTaxRatesTableUpdateCompanionBuilder,
      (
        CountryTaxRate,
        BaseReferences<_$AppDatabase, $CountryTaxRatesTable, CountryTaxRate>,
      ),
      CountryTaxRate,
      PrefetchHooks Function()
    >;
typedef $$AssetClassesTableCreateCompanionBuilder =
    AssetClassesCompanion Function({
      required String name,
      Value<int> displayOrder,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AssetClassesTableUpdateCompanionBuilder =
    AssetClassesCompanion Function({
      Value<String> name,
      Value<int> displayOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AssetClassesTableFilterComposer
    extends Composer<_$AppDatabase, $AssetClassesTable> {
  $$AssetClassesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssetClassesTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetClassesTable> {
  $$AssetClassesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetClassesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetClassesTable> {
  $$AssetClassesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AssetClassesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetClassesTable,
          AssetClassesData,
          $$AssetClassesTableFilterComposer,
          $$AssetClassesTableOrderingComposer,
          $$AssetClassesTableAnnotationComposer,
          $$AssetClassesTableCreateCompanionBuilder,
          $$AssetClassesTableUpdateCompanionBuilder,
          (
            AssetClassesData,
            BaseReferences<_$AppDatabase, $AssetClassesTable, AssetClassesData>,
          ),
          AssetClassesData,
          PrefetchHooks Function()
        > {
  $$AssetClassesTableTableManager(_$AppDatabase db, $AssetClassesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetClassesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetClassesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetClassesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetClassesCompanion(
                name: name,
                displayOrder: displayOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                Value<int> displayOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AssetClassesCompanion.insert(
                name: name,
                displayOrder: displayOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssetClassesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetClassesTable,
      AssetClassesData,
      $$AssetClassesTableFilterComposer,
      $$AssetClassesTableOrderingComposer,
      $$AssetClassesTableAnnotationComposer,
      $$AssetClassesTableCreateCompanionBuilder,
      $$AssetClassesTableUpdateCompanionBuilder,
      (
        AssetClassesData,
        BaseReferences<_$AppDatabase, $AssetClassesTable, AssetClassesData>,
      ),
      AssetClassesData,
      PrefetchHooks Function()
    >;
typedef $$AppConfigurationsTableCreateCompanionBuilder =
    AppConfigurationsCompanion Function({
      required String id,
      Value<double> maximumTaxAllowance,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppConfigurationsTableUpdateCompanionBuilder =
    AppConfigurationsCompanion Function({
      Value<String> id,
      Value<double> maximumTaxAllowance,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppConfigurationsTableFilterComposer
    extends Composer<_$AppDatabase, $AppConfigurationsTable> {
  $$AppConfigurationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maximumTaxAllowance => $composableBuilder(
    column: $table.maximumTaxAllowance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppConfigurationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppConfigurationsTable> {
  $$AppConfigurationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maximumTaxAllowance => $composableBuilder(
    column: $table.maximumTaxAllowance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppConfigurationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppConfigurationsTable> {
  $$AppConfigurationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get maximumTaxAllowance => $composableBuilder(
    column: $table.maximumTaxAllowance,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppConfigurationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppConfigurationsTable,
          AppConfiguration,
          $$AppConfigurationsTableFilterComposer,
          $$AppConfigurationsTableOrderingComposer,
          $$AppConfigurationsTableAnnotationComposer,
          $$AppConfigurationsTableCreateCompanionBuilder,
          $$AppConfigurationsTableUpdateCompanionBuilder,
          (
            AppConfiguration,
            BaseReferences<
              _$AppDatabase,
              $AppConfigurationsTable,
              AppConfiguration
            >,
          ),
          AppConfiguration,
          PrefetchHooks Function()
        > {
  $$AppConfigurationsTableTableManager(
    _$AppDatabase db,
    $AppConfigurationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppConfigurationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppConfigurationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppConfigurationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> maximumTaxAllowance = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppConfigurationsCompanion(
                id: id,
                maximumTaxAllowance: maximumTaxAllowance,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<double> maximumTaxAllowance = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppConfigurationsCompanion.insert(
                id: id,
                maximumTaxAllowance: maximumTaxAllowance,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppConfigurationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppConfigurationsTable,
      AppConfiguration,
      $$AppConfigurationsTableFilterComposer,
      $$AppConfigurationsTableOrderingComposer,
      $$AppConfigurationsTableAnnotationComposer,
      $$AppConfigurationsTableCreateCompanionBuilder,
      $$AppConfigurationsTableUpdateCompanionBuilder,
      (
        AppConfiguration,
        BaseReferences<
          _$AppDatabase,
          $AppConfigurationsTable,
          AppConfiguration
        >,
      ),
      AppConfiguration,
      PrefetchHooks Function()
    >;
typedef $$PhysicalAssetsTableCreateCompanionBuilder =
    PhysicalAssetsCompanion Function({
      required String id,
      required String userId,
      Value<String> accountId,
      required String name,
      Value<String> category,
      Value<String> metalType,
      Value<double> quantity,
      Value<double> weightGrams,
      Value<DateTime?> purchaseDate,
      Value<double> purchasePrice,
      Value<double> currentValue,
      Value<double> currentPricePerGram,
      Value<String> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$PhysicalAssetsTableUpdateCompanionBuilder =
    PhysicalAssetsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> accountId,
      Value<String> name,
      Value<String> category,
      Value<String> metalType,
      Value<double> quantity,
      Value<double> weightGrams,
      Value<DateTime?> purchaseDate,
      Value<double> purchasePrice,
      Value<double> currentValue,
      Value<double> currentPricePerGram,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$PhysicalAssetsTableReferences
    extends BaseReferences<_$AppDatabase, $PhysicalAssetsTable, PhysicalAsset> {
  $$PhysicalAssetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('physical_assets__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PhysicalAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $PhysicalAssetsTable> {
  $$PhysicalAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metalType => $composableBuilder(
    column: $table.metalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentPricePerGram => $composableBuilder(
    column: $table.currentPricePerGram,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhysicalAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $PhysicalAssetsTable> {
  $$PhysicalAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metalType => $composableBuilder(
    column: $table.metalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentPricePerGram => $composableBuilder(
    column: $table.currentPricePerGram,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhysicalAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhysicalAssetsTable> {
  $$PhysicalAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get metalType =>
      $composableBuilder(column: $table.metalType, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentPricePerGram => $composableBuilder(
    column: $table.currentPricePerGram,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhysicalAssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhysicalAssetsTable,
          PhysicalAsset,
          $$PhysicalAssetsTableFilterComposer,
          $$PhysicalAssetsTableOrderingComposer,
          $$PhysicalAssetsTableAnnotationComposer,
          $$PhysicalAssetsTableCreateCompanionBuilder,
          $$PhysicalAssetsTableUpdateCompanionBuilder,
          (PhysicalAsset, $$PhysicalAssetsTableReferences),
          PhysicalAsset,
          PrefetchHooks Function({bool userId})
        > {
  $$PhysicalAssetsTableTableManager(
    _$AppDatabase db,
    $PhysicalAssetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhysicalAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhysicalAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhysicalAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> metalType = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> weightGrams = const Value.absent(),
                Value<DateTime?> purchaseDate = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<double> currentValue = const Value.absent(),
                Value<double> currentPricePerGram = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhysicalAssetsCompanion(
                id: id,
                userId: userId,
                accountId: accountId,
                name: name,
                category: category,
                metalType: metalType,
                quantity: quantity,
                weightGrams: weightGrams,
                purchaseDate: purchaseDate,
                purchasePrice: purchasePrice,
                currentValue: currentValue,
                currentPricePerGram: currentPricePerGram,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String> accountId = const Value.absent(),
                required String name,
                Value<String> category = const Value.absent(),
                Value<String> metalType = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> weightGrams = const Value.absent(),
                Value<DateTime?> purchaseDate = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<double> currentValue = const Value.absent(),
                Value<double> currentPricePerGram = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhysicalAssetsCompanion.insert(
                id: id,
                userId: userId,
                accountId: accountId,
                name: name,
                category: category,
                metalType: metalType,
                quantity: quantity,
                weightGrams: weightGrams,
                purchaseDate: purchaseDate,
                purchasePrice: purchasePrice,
                currentValue: currentValue,
                currentPricePerGram: currentPricePerGram,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PhysicalAssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$PhysicalAssetsTableReferences
                                    ._userIdTable(db),
                                referencedColumn:
                                    $$PhysicalAssetsTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PhysicalAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhysicalAssetsTable,
      PhysicalAsset,
      $$PhysicalAssetsTableFilterComposer,
      $$PhysicalAssetsTableOrderingComposer,
      $$PhysicalAssetsTableAnnotationComposer,
      $$PhysicalAssetsTableCreateCompanionBuilder,
      $$PhysicalAssetsTableUpdateCompanionBuilder,
      (PhysicalAsset, $$PhysicalAssetsTableReferences),
      PhysicalAsset,
      PrefetchHooks Function({bool userId})
    >;
typedef $$PortfolioSalesTableCreateCompanionBuilder =
    PortfolioSalesCompanion Function({
      required String id,
      required String userId,
      required String accountId,
      Value<String?> destinationAccountId,
      Value<bool> accountCredited,
      Value<String> sourceCurrency,
      Value<double> exchangeRate,
      Value<String?> investmentId,
      Value<String?> physicalAssetId,
      required String assetName,
      required String assetKind,
      required double quantity,
      required String unit,
      required double pricePerUnit,
      Value<double> fees,
      required double proceeds,
      Value<double> costBasis,
      Value<double> realizedGain,
      Value<double> allowanceUsed,
      Value<double> taxPaid,
      required DateTime soldAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PortfolioSalesTableUpdateCompanionBuilder =
    PortfolioSalesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> accountId,
      Value<String?> destinationAccountId,
      Value<bool> accountCredited,
      Value<String> sourceCurrency,
      Value<double> exchangeRate,
      Value<String?> investmentId,
      Value<String?> physicalAssetId,
      Value<String> assetName,
      Value<String> assetKind,
      Value<double> quantity,
      Value<String> unit,
      Value<double> pricePerUnit,
      Value<double> fees,
      Value<double> proceeds,
      Value<double> costBasis,
      Value<double> realizedGain,
      Value<double> allowanceUsed,
      Value<double> taxPaid,
      Value<DateTime> soldAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PortfolioSalesTableReferences
    extends BaseReferences<_$AppDatabase, $PortfolioSalesTable, PortfolioSale> {
  $$PortfolioSalesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('portfolio_sales__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('portfolio_sales__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PortfolioSalesTableFilterComposer
    extends Composer<_$AppDatabase, $PortfolioSalesTable> {
  $$PortfolioSalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get accountCredited => $composableBuilder(
    column: $table.accountCredited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceCurrency => $composableBuilder(
    column: $table.sourceCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get exchangeRate => $composableBuilder(
    column: $table.exchangeRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get investmentId => $composableBuilder(
    column: $table.investmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get physicalAssetId => $composableBuilder(
    column: $table.physicalAssetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetName => $composableBuilder(
    column: $table.assetName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetKind => $composableBuilder(
    column: $table.assetKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePerUnit => $composableBuilder(
    column: $table.pricePerUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proceeds => $composableBuilder(
    column: $table.proceeds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costBasis => $composableBuilder(
    column: $table.costBasis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get realizedGain => $composableBuilder(
    column: $table.realizedGain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get allowanceUsed => $composableBuilder(
    column: $table.allowanceUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxPaid => $composableBuilder(
    column: $table.taxPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get soldAt => $composableBuilder(
    column: $table.soldAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PortfolioSalesTableOrderingComposer
    extends Composer<_$AppDatabase, $PortfolioSalesTable> {
  $$PortfolioSalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get accountCredited => $composableBuilder(
    column: $table.accountCredited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceCurrency => $composableBuilder(
    column: $table.sourceCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get exchangeRate => $composableBuilder(
    column: $table.exchangeRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get investmentId => $composableBuilder(
    column: $table.investmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get physicalAssetId => $composableBuilder(
    column: $table.physicalAssetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetName => $composableBuilder(
    column: $table.assetName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetKind => $composableBuilder(
    column: $table.assetKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePerUnit => $composableBuilder(
    column: $table.pricePerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proceeds => $composableBuilder(
    column: $table.proceeds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costBasis => $composableBuilder(
    column: $table.costBasis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get realizedGain => $composableBuilder(
    column: $table.realizedGain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get allowanceUsed => $composableBuilder(
    column: $table.allowanceUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxPaid => $composableBuilder(
    column: $table.taxPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get soldAt => $composableBuilder(
    column: $table.soldAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PortfolioSalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PortfolioSalesTable> {
  $$PortfolioSalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get destinationAccountId => $composableBuilder(
    column: $table.destinationAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get accountCredited => $composableBuilder(
    column: $table.accountCredited,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceCurrency => $composableBuilder(
    column: $table.sourceCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<double> get exchangeRate => $composableBuilder(
    column: $table.exchangeRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get investmentId => $composableBuilder(
    column: $table.investmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get physicalAssetId => $composableBuilder(
    column: $table.physicalAssetId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assetName =>
      $composableBuilder(column: $table.assetName, builder: (column) => column);

  GeneratedColumn<String> get assetKind =>
      $composableBuilder(column: $table.assetKind, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get pricePerUnit => $composableBuilder(
    column: $table.pricePerUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fees =>
      $composableBuilder(column: $table.fees, builder: (column) => column);

  GeneratedColumn<double> get proceeds =>
      $composableBuilder(column: $table.proceeds, builder: (column) => column);

  GeneratedColumn<double> get costBasis =>
      $composableBuilder(column: $table.costBasis, builder: (column) => column);

  GeneratedColumn<double> get realizedGain => $composableBuilder(
    column: $table.realizedGain,
    builder: (column) => column,
  );

  GeneratedColumn<double> get allowanceUsed => $composableBuilder(
    column: $table.allowanceUsed,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxPaid =>
      $composableBuilder(column: $table.taxPaid, builder: (column) => column);

  GeneratedColumn<DateTime> get soldAt =>
      $composableBuilder(column: $table.soldAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PortfolioSalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PortfolioSalesTable,
          PortfolioSale,
          $$PortfolioSalesTableFilterComposer,
          $$PortfolioSalesTableOrderingComposer,
          $$PortfolioSalesTableAnnotationComposer,
          $$PortfolioSalesTableCreateCompanionBuilder,
          $$PortfolioSalesTableUpdateCompanionBuilder,
          (PortfolioSale, $$PortfolioSalesTableReferences),
          PortfolioSale,
          PrefetchHooks Function({bool userId, bool accountId})
        > {
  $$PortfolioSalesTableTableManager(
    _$AppDatabase db,
    $PortfolioSalesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PortfolioSalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PortfolioSalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PortfolioSalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> destinationAccountId = const Value.absent(),
                Value<bool> accountCredited = const Value.absent(),
                Value<String> sourceCurrency = const Value.absent(),
                Value<double> exchangeRate = const Value.absent(),
                Value<String?> investmentId = const Value.absent(),
                Value<String?> physicalAssetId = const Value.absent(),
                Value<String> assetName = const Value.absent(),
                Value<String> assetKind = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> pricePerUnit = const Value.absent(),
                Value<double> fees = const Value.absent(),
                Value<double> proceeds = const Value.absent(),
                Value<double> costBasis = const Value.absent(),
                Value<double> realizedGain = const Value.absent(),
                Value<double> allowanceUsed = const Value.absent(),
                Value<double> taxPaid = const Value.absent(),
                Value<DateTime> soldAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PortfolioSalesCompanion(
                id: id,
                userId: userId,
                accountId: accountId,
                destinationAccountId: destinationAccountId,
                accountCredited: accountCredited,
                sourceCurrency: sourceCurrency,
                exchangeRate: exchangeRate,
                investmentId: investmentId,
                physicalAssetId: physicalAssetId,
                assetName: assetName,
                assetKind: assetKind,
                quantity: quantity,
                unit: unit,
                pricePerUnit: pricePerUnit,
                fees: fees,
                proceeds: proceeds,
                costBasis: costBasis,
                realizedGain: realizedGain,
                allowanceUsed: allowanceUsed,
                taxPaid: taxPaid,
                soldAt: soldAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String accountId,
                Value<String?> destinationAccountId = const Value.absent(),
                Value<bool> accountCredited = const Value.absent(),
                Value<String> sourceCurrency = const Value.absent(),
                Value<double> exchangeRate = const Value.absent(),
                Value<String?> investmentId = const Value.absent(),
                Value<String?> physicalAssetId = const Value.absent(),
                required String assetName,
                required String assetKind,
                required double quantity,
                required String unit,
                required double pricePerUnit,
                Value<double> fees = const Value.absent(),
                required double proceeds,
                Value<double> costBasis = const Value.absent(),
                Value<double> realizedGain = const Value.absent(),
                Value<double> allowanceUsed = const Value.absent(),
                Value<double> taxPaid = const Value.absent(),
                required DateTime soldAt,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PortfolioSalesCompanion.insert(
                id: id,
                userId: userId,
                accountId: accountId,
                destinationAccountId: destinationAccountId,
                accountCredited: accountCredited,
                sourceCurrency: sourceCurrency,
                exchangeRate: exchangeRate,
                investmentId: investmentId,
                physicalAssetId: physicalAssetId,
                assetName: assetName,
                assetKind: assetKind,
                quantity: quantity,
                unit: unit,
                pricePerUnit: pricePerUnit,
                fees: fees,
                proceeds: proceeds,
                costBasis: costBasis,
                realizedGain: realizedGain,
                allowanceUsed: allowanceUsed,
                taxPaid: taxPaid,
                soldAt: soldAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PortfolioSalesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false, accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$PortfolioSalesTableReferences
                                    ._userIdTable(db),
                                referencedColumn:
                                    $$PortfolioSalesTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable: $$PortfolioSalesTableReferences
                                    ._accountIdTable(db),
                                referencedColumn:
                                    $$PortfolioSalesTableReferences
                                        ._accountIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PortfolioSalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PortfolioSalesTable,
      PortfolioSale,
      $$PortfolioSalesTableFilterComposer,
      $$PortfolioSalesTableOrderingComposer,
      $$PortfolioSalesTableAnnotationComposer,
      $$PortfolioSalesTableCreateCompanionBuilder,
      $$PortfolioSalesTableUpdateCompanionBuilder,
      (PortfolioSale, $$PortfolioSalesTableReferences),
      PortfolioSale,
      PrefetchHooks Function({bool userId, bool accountId})
    >;
typedef $$PortfolioAuditLogsTableCreateCompanionBuilder =
    PortfolioAuditLogsCompanion Function({
      required String id,
      required String userId,
      required String action,
      required String entityType,
      required String entityId,
      required String displayName,
      Value<String> details,
      required DateTime occurredAt,
      Value<int> rowid,
    });
typedef $$PortfolioAuditLogsTableUpdateCompanionBuilder =
    PortfolioAuditLogsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> action,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> displayName,
      Value<String> details,
      Value<DateTime> occurredAt,
      Value<int> rowid,
    });

final class $$PortfolioAuditLogsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PortfolioAuditLogsTable,
          PortfolioAuditLog
        > {
  $$PortfolioAuditLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('portfolio_audit_logs__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PortfolioAuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $PortfolioAuditLogsTable> {
  $$PortfolioAuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PortfolioAuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $PortfolioAuditLogsTable> {
  $$PortfolioAuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PortfolioAuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PortfolioAuditLogsTable> {
  $$PortfolioAuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PortfolioAuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PortfolioAuditLogsTable,
          PortfolioAuditLog,
          $$PortfolioAuditLogsTableFilterComposer,
          $$PortfolioAuditLogsTableOrderingComposer,
          $$PortfolioAuditLogsTableAnnotationComposer,
          $$PortfolioAuditLogsTableCreateCompanionBuilder,
          $$PortfolioAuditLogsTableUpdateCompanionBuilder,
          (PortfolioAuditLog, $$PortfolioAuditLogsTableReferences),
          PortfolioAuditLog,
          PrefetchHooks Function({bool userId})
        > {
  $$PortfolioAuditLogsTableTableManager(
    _$AppDatabase db,
    $PortfolioAuditLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PortfolioAuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PortfolioAuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PortfolioAuditLogsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> details = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PortfolioAuditLogsCompanion(
                id: id,
                userId: userId,
                action: action,
                entityType: entityType,
                entityId: entityId,
                displayName: displayName,
                details: details,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String action,
                required String entityType,
                required String entityId,
                required String displayName,
                Value<String> details = const Value.absent(),
                required DateTime occurredAt,
                Value<int> rowid = const Value.absent(),
              }) => PortfolioAuditLogsCompanion.insert(
                id: id,
                userId: userId,
                action: action,
                entityType: entityType,
                entityId: entityId,
                displayName: displayName,
                details: details,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PortfolioAuditLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$PortfolioAuditLogsTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$PortfolioAuditLogsTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PortfolioAuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PortfolioAuditLogsTable,
      PortfolioAuditLog,
      $$PortfolioAuditLogsTableFilterComposer,
      $$PortfolioAuditLogsTableOrderingComposer,
      $$PortfolioAuditLogsTableAnnotationComposer,
      $$PortfolioAuditLogsTableCreateCompanionBuilder,
      $$PortfolioAuditLogsTableUpdateCompanionBuilder,
      (PortfolioAuditLog, $$PortfolioAuditLogsTableReferences),
      PortfolioAuditLog,
      PrefetchHooks Function({bool userId})
    >;
typedef $$AppErrorLogsTableCreateCompanionBuilder =
    AppErrorLogsCompanion Function({
      required String id,
      Value<String?> userId,
      required String source,
      required String message,
      Value<String> details,
      Value<String> stackTrace,
      required DateTime occurredAt,
      Value<int> rowid,
    });
typedef $$AppErrorLogsTableUpdateCompanionBuilder =
    AppErrorLogsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String> source,
      Value<String> message,
      Value<String> details,
      Value<String> stackTrace,
      Value<DateTime> occurredAt,
      Value<int> rowid,
    });

class $$AppErrorLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AppErrorLogsTable> {
  $$AppErrorLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppErrorLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppErrorLogsTable> {
  $$AppErrorLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppErrorLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppErrorLogsTable> {
  $$AppErrorLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );
}

class $$AppErrorLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppErrorLogsTable,
          AppErrorLog,
          $$AppErrorLogsTableFilterComposer,
          $$AppErrorLogsTableOrderingComposer,
          $$AppErrorLogsTableAnnotationComposer,
          $$AppErrorLogsTableCreateCompanionBuilder,
          $$AppErrorLogsTableUpdateCompanionBuilder,
          (
            AppErrorLog,
            BaseReferences<_$AppDatabase, $AppErrorLogsTable, AppErrorLog>,
          ),
          AppErrorLog,
          PrefetchHooks Function()
        > {
  $$AppErrorLogsTableTableManager(_$AppDatabase db, $AppErrorLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppErrorLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppErrorLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppErrorLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String> details = const Value.absent(),
                Value<String> stackTrace = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppErrorLogsCompanion(
                id: id,
                userId: userId,
                source: source,
                message: message,
                details: details,
                stackTrace: stackTrace,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                required String source,
                required String message,
                Value<String> details = const Value.absent(),
                Value<String> stackTrace = const Value.absent(),
                required DateTime occurredAt,
                Value<int> rowid = const Value.absent(),
              }) => AppErrorLogsCompanion.insert(
                id: id,
                userId: userId,
                source: source,
                message: message,
                details: details,
                stackTrace: stackTrace,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppErrorLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppErrorLogsTable,
      AppErrorLog,
      $$AppErrorLogsTableFilterComposer,
      $$AppErrorLogsTableOrderingComposer,
      $$AppErrorLogsTableAnnotationComposer,
      $$AppErrorLogsTableCreateCompanionBuilder,
      $$AppErrorLogsTableUpdateCompanionBuilder,
      (
        AppErrorLog,
        BaseReferences<_$AppDatabase, $AppErrorLogsTable, AppErrorLog>,
      ),
      AppErrorLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$AccountBalanceHistoriesTableTableManager get accountBalanceHistories =>
      $$AccountBalanceHistoriesTableTableManager(
        _db,
        _db.accountBalanceHistories,
      );
  $$InvestmentsTableTableManager get investments =>
      $$InvestmentsTableTableManager(_db, _db.investments);
  $$InvestmentPurchasesTableTableManager get investmentPurchases =>
      $$InvestmentPurchasesTableTableManager(_db, _db.investmentPurchases);
  $$DividendSchedulesTableTableManager get dividendSchedules =>
      $$DividendSchedulesTableTableManager(_db, _db.dividendSchedules);
  $$LedgerEntriesTableTableManager get ledgerEntries =>
      $$LedgerEntriesTableTableManager(_db, _db.ledgerEntries);
  $$MasterDataTableTableManager get masterData =>
      $$MasterDataTableTableManager(_db, _db.masterData);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$VehicleCostsTableTableManager get vehicleCosts =>
      $$VehicleCostsTableTableManager(_db, _db.vehicleCosts);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
  $$NetWorthSnapshotsTableTableManager get netWorthSnapshots =>
      $$NetWorthSnapshotsTableTableManager(_db, _db.netWorthSnapshots);
  $$StockMastersTableTableManager get stockMasters =>
      $$StockMastersTableTableManager(_db, _db.stockMasters);
  $$StockPricesTableTableManager get stockPrices =>
      $$StockPricesTableTableManager(_db, _db.stockPrices);
  $$StockDividendsTableTableManager get stockDividends =>
      $$StockDividendsTableTableManager(_db, _db.stockDividends);
  $$MarketDataRefreshesTableTableManager get marketDataRefreshes =>
      $$MarketDataRefreshesTableTableManager(_db, _db.marketDataRefreshes);
  $$ApiRequestDaysTableTableManager get apiRequestDays =>
      $$ApiRequestDaysTableTableManager(_db, _db.apiRequestDays);
  $$CountryTaxRatesTableTableManager get countryTaxRates =>
      $$CountryTaxRatesTableTableManager(_db, _db.countryTaxRates);
  $$AssetClassesTableTableManager get assetClasses =>
      $$AssetClassesTableTableManager(_db, _db.assetClasses);
  $$AppConfigurationsTableTableManager get appConfigurations =>
      $$AppConfigurationsTableTableManager(_db, _db.appConfigurations);
  $$PhysicalAssetsTableTableManager get physicalAssets =>
      $$PhysicalAssetsTableTableManager(_db, _db.physicalAssets);
  $$PortfolioSalesTableTableManager get portfolioSales =>
      $$PortfolioSalesTableTableManager(_db, _db.portfolioSales);
  $$PortfolioAuditLogsTableTableManager get portfolioAuditLogs =>
      $$PortfolioAuditLogsTableTableManager(_db, _db.portfolioAuditLogs);
  $$AppErrorLogsTableTableManager get appErrorLogs =>
      $$AppErrorLogsTableTableManager(_db, _db.appErrorLogs);
}
