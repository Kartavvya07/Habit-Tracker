// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HabitLog _$HabitLogFromJson(Map<String, dynamic> json) {
  return _HabitLog.fromJson(json);
}

/// @nodoc
mixin _$HabitLog {
  String get id => throw _privateConstructorUsedError;
  String get habitId => throw _privateConstructorUsedError;
  DateTime get targetDate => throw _privateConstructorUsedError;
  HabitLogStatus get status => throw _privateConstructorUsedError;
  int get currentValue => throw _privateConstructorUsedError;
  bool get isFrozen => throw _privateConstructorUsedError;

  /// Serializes this HabitLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HabitLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HabitLogCopyWith<HabitLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HabitLogCopyWith<$Res> {
  factory $HabitLogCopyWith(HabitLog value, $Res Function(HabitLog) then) =
      _$HabitLogCopyWithImpl<$Res, HabitLog>;
  @useResult
  $Res call(
      {String id,
      String habitId,
      DateTime targetDate,
      HabitLogStatus status,
      int currentValue,
      bool isFrozen});
}

/// @nodoc
class _$HabitLogCopyWithImpl<$Res, $Val extends HabitLog>
    implements $HabitLogCopyWith<$Res> {
  _$HabitLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HabitLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? habitId = null,
    Object? targetDate = null,
    Object? status = null,
    Object? currentValue = null,
    Object? isFrozen = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      habitId: null == habitId
          ? _value.habitId
          : habitId // ignore: cast_nullable_to_non_nullable
              as String,
      targetDate: null == targetDate
          ? _value.targetDate
          : targetDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as HabitLogStatus,
      currentValue: null == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as int,
      isFrozen: null == isFrozen
          ? _value.isFrozen
          : isFrozen // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HabitLogImplCopyWith<$Res>
    implements $HabitLogCopyWith<$Res> {
  factory _$$HabitLogImplCopyWith(
          _$HabitLogImpl value, $Res Function(_$HabitLogImpl) then) =
      __$$HabitLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String habitId,
      DateTime targetDate,
      HabitLogStatus status,
      int currentValue,
      bool isFrozen});
}

/// @nodoc
class __$$HabitLogImplCopyWithImpl<$Res>
    extends _$HabitLogCopyWithImpl<$Res, _$HabitLogImpl>
    implements _$$HabitLogImplCopyWith<$Res> {
  __$$HabitLogImplCopyWithImpl(
      _$HabitLogImpl _value, $Res Function(_$HabitLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of HabitLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? habitId = null,
    Object? targetDate = null,
    Object? status = null,
    Object? currentValue = null,
    Object? isFrozen = null,
  }) {
    return _then(_$HabitLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      habitId: null == habitId
          ? _value.habitId
          : habitId // ignore: cast_nullable_to_non_nullable
              as String,
      targetDate: null == targetDate
          ? _value.targetDate
          : targetDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as HabitLogStatus,
      currentValue: null == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as int,
      isFrozen: null == isFrozen
          ? _value.isFrozen
          : isFrozen // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HabitLogImpl implements _HabitLog {
  const _$HabitLogImpl(
      {required this.id,
      required this.habitId,
      required this.targetDate,
      this.status = HabitLogStatus.completed,
      this.currentValue = 0,
      this.isFrozen = false});

  factory _$HabitLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$HabitLogImplFromJson(json);

  @override
  final String id;
  @override
  final String habitId;
  @override
  final DateTime targetDate;
  @override
  @JsonKey()
  final HabitLogStatus status;
  @override
  @JsonKey()
  final int currentValue;
  @override
  @JsonKey()
  final bool isFrozen;

  @override
  String toString() {
    return 'HabitLog(id: $id, habitId: $habitId, targetDate: $targetDate, status: $status, currentValue: $currentValue, isFrozen: $isFrozen)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HabitLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.habitId, habitId) || other.habitId == habitId) &&
            (identical(other.targetDate, targetDate) ||
                other.targetDate == targetDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentValue, currentValue) ||
                other.currentValue == currentValue) &&
            (identical(other.isFrozen, isFrozen) ||
                other.isFrozen == isFrozen));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, habitId, targetDate, status, currentValue, isFrozen);

  /// Create a copy of HabitLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HabitLogImplCopyWith<_$HabitLogImpl> get copyWith =>
      __$$HabitLogImplCopyWithImpl<_$HabitLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HabitLogImplToJson(
      this,
    );
  }
}

abstract class _HabitLog implements HabitLog {
  const factory _HabitLog(
      {required final String id,
      required final String habitId,
      required final DateTime targetDate,
      final HabitLogStatus status,
      final int currentValue,
      final bool isFrozen}) = _$HabitLogImpl;

  factory _HabitLog.fromJson(Map<String, dynamic> json) =
      _$HabitLogImpl.fromJson;

  @override
  String get id;
  @override
  String get habitId;
  @override
  DateTime get targetDate;
  @override
  HabitLogStatus get status;
  @override
  int get currentValue;
  @override
  bool get isFrozen;

  /// Create a copy of HabitLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HabitLogImplCopyWith<_$HabitLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
