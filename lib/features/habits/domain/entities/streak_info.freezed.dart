// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StreakInfo _$StreakInfoFromJson(Map<String, dynamic> json) {
  return _StreakInfo.fromJson(json);
}

/// @nodoc
mixin _$StreakInfo {
  int get currentStreak => throw _privateConstructorUsedError;
  int get bestStreak => throw _privateConstructorUsedError;
  double get completionRate => throw _privateConstructorUsedError;
  int get totalCompleted => throw _privateConstructorUsedError;
  int get totalScheduled => throw _privateConstructorUsedError;

  /// Serializes this StreakInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StreakInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreakInfoCopyWith<StreakInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakInfoCopyWith<$Res> {
  factory $StreakInfoCopyWith(
          StreakInfo value, $Res Function(StreakInfo) then) =
      _$StreakInfoCopyWithImpl<$Res, StreakInfo>;
  @useResult
  $Res call(
      {int currentStreak,
      int bestStreak,
      double completionRate,
      int totalCompleted,
      int totalScheduled});
}

/// @nodoc
class _$StreakInfoCopyWithImpl<$Res, $Val extends StreakInfo>
    implements $StreakInfoCopyWith<$Res> {
  _$StreakInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreakInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? bestStreak = null,
    Object? completionRate = null,
    Object? totalCompleted = null,
    Object? totalScheduled = null,
  }) {
    return _then(_value.copyWith(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      bestStreak: null == bestStreak
          ? _value.bestStreak
          : bestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      totalCompleted: null == totalCompleted
          ? _value.totalCompleted
          : totalCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      totalScheduled: null == totalScheduled
          ? _value.totalScheduled
          : totalScheduled // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreakInfoImplCopyWith<$Res>
    implements $StreakInfoCopyWith<$Res> {
  factory _$$StreakInfoImplCopyWith(
          _$StreakInfoImpl value, $Res Function(_$StreakInfoImpl) then) =
      __$$StreakInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentStreak,
      int bestStreak,
      double completionRate,
      int totalCompleted,
      int totalScheduled});
}

/// @nodoc
class __$$StreakInfoImplCopyWithImpl<$Res>
    extends _$StreakInfoCopyWithImpl<$Res, _$StreakInfoImpl>
    implements _$$StreakInfoImplCopyWith<$Res> {
  __$$StreakInfoImplCopyWithImpl(
      _$StreakInfoImpl _value, $Res Function(_$StreakInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of StreakInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? bestStreak = null,
    Object? completionRate = null,
    Object? totalCompleted = null,
    Object? totalScheduled = null,
  }) {
    return _then(_$StreakInfoImpl(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      bestStreak: null == bestStreak
          ? _value.bestStreak
          : bestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      totalCompleted: null == totalCompleted
          ? _value.totalCompleted
          : totalCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      totalScheduled: null == totalScheduled
          ? _value.totalScheduled
          : totalScheduled // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StreakInfoImpl implements _StreakInfo {
  const _$StreakInfoImpl(
      {this.currentStreak = 0,
      this.bestStreak = 0,
      this.completionRate = 0.0,
      this.totalCompleted = 0,
      this.totalScheduled = 0});

  factory _$StreakInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreakInfoImplFromJson(json);

  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int bestStreak;
  @override
  @JsonKey()
  final double completionRate;
  @override
  @JsonKey()
  final int totalCompleted;
  @override
  @JsonKey()
  final int totalScheduled;

  @override
  String toString() {
    return 'StreakInfo(currentStreak: $currentStreak, bestStreak: $bestStreak, completionRate: $completionRate, totalCompleted: $totalCompleted, totalScheduled: $totalScheduled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakInfoImpl &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.bestStreak, bestStreak) ||
                other.bestStreak == bestStreak) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate) &&
            (identical(other.totalCompleted, totalCompleted) ||
                other.totalCompleted == totalCompleted) &&
            (identical(other.totalScheduled, totalScheduled) ||
                other.totalScheduled == totalScheduled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, currentStreak, bestStreak,
      completionRate, totalCompleted, totalScheduled);

  /// Create a copy of StreakInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakInfoImplCopyWith<_$StreakInfoImpl> get copyWith =>
      __$$StreakInfoImplCopyWithImpl<_$StreakInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreakInfoImplToJson(
      this,
    );
  }
}

abstract class _StreakInfo implements StreakInfo {
  const factory _StreakInfo(
      {final int currentStreak,
      final int bestStreak,
      final double completionRate,
      final int totalCompleted,
      final int totalScheduled}) = _$StreakInfoImpl;

  factory _StreakInfo.fromJson(Map<String, dynamic> json) =
      _$StreakInfoImpl.fromJson;

  @override
  int get currentStreak;
  @override
  int get bestStreak;
  @override
  double get completionRate;
  @override
  int get totalCompleted;
  @override
  int get totalScheduled;

  /// Create a copy of StreakInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreakInfoImplCopyWith<_$StreakInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
