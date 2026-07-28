// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_completion_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DailyCompletionStats _$DailyCompletionStatsFromJson(Map<String, dynamic> json) {
  return _DailyCompletionStats.fromJson(json);
}

/// @nodoc
mixin _$DailyCompletionStats {
  DateTime get date => throw _privateConstructorUsedError;
  int get totalHabits => throw _privateConstructorUsedError;
  int get completedHabits => throw _privateConstructorUsedError;
  double get completionPercentage => throw _privateConstructorUsedError;
  bool get isFullyCompleted => throw _privateConstructorUsedError;

  /// Serializes this DailyCompletionStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyCompletionStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyCompletionStatsCopyWith<DailyCompletionStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyCompletionStatsCopyWith<$Res> {
  factory $DailyCompletionStatsCopyWith(DailyCompletionStats value,
          $Res Function(DailyCompletionStats) then) =
      _$DailyCompletionStatsCopyWithImpl<$Res, DailyCompletionStats>;
  @useResult
  $Res call(
      {DateTime date,
      int totalHabits,
      int completedHabits,
      double completionPercentage,
      bool isFullyCompleted});
}

/// @nodoc
class _$DailyCompletionStatsCopyWithImpl<$Res,
        $Val extends DailyCompletionStats>
    implements $DailyCompletionStatsCopyWith<$Res> {
  _$DailyCompletionStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyCompletionStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? totalHabits = null,
    Object? completedHabits = null,
    Object? completionPercentage = null,
    Object? isFullyCompleted = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalHabits: null == totalHabits
          ? _value.totalHabits
          : totalHabits // ignore: cast_nullable_to_non_nullable
              as int,
      completedHabits: null == completedHabits
          ? _value.completedHabits
          : completedHabits // ignore: cast_nullable_to_non_nullable
              as int,
      completionPercentage: null == completionPercentage
          ? _value.completionPercentage
          : completionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      isFullyCompleted: null == isFullyCompleted
          ? _value.isFullyCompleted
          : isFullyCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyCompletionStatsImplCopyWith<$Res>
    implements $DailyCompletionStatsCopyWith<$Res> {
  factory _$$DailyCompletionStatsImplCopyWith(_$DailyCompletionStatsImpl value,
          $Res Function(_$DailyCompletionStatsImpl) then) =
      __$$DailyCompletionStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      int totalHabits,
      int completedHabits,
      double completionPercentage,
      bool isFullyCompleted});
}

/// @nodoc
class __$$DailyCompletionStatsImplCopyWithImpl<$Res>
    extends _$DailyCompletionStatsCopyWithImpl<$Res, _$DailyCompletionStatsImpl>
    implements _$$DailyCompletionStatsImplCopyWith<$Res> {
  __$$DailyCompletionStatsImplCopyWithImpl(_$DailyCompletionStatsImpl _value,
      $Res Function(_$DailyCompletionStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyCompletionStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? totalHabits = null,
    Object? completedHabits = null,
    Object? completionPercentage = null,
    Object? isFullyCompleted = null,
  }) {
    return _then(_$DailyCompletionStatsImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalHabits: null == totalHabits
          ? _value.totalHabits
          : totalHabits // ignore: cast_nullable_to_non_nullable
              as int,
      completedHabits: null == completedHabits
          ? _value.completedHabits
          : completedHabits // ignore: cast_nullable_to_non_nullable
              as int,
      completionPercentage: null == completionPercentage
          ? _value.completionPercentage
          : completionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      isFullyCompleted: null == isFullyCompleted
          ? _value.isFullyCompleted
          : isFullyCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyCompletionStatsImpl implements _DailyCompletionStats {
  const _$DailyCompletionStatsImpl(
      {required this.date,
      this.totalHabits = 0,
      this.completedHabits = 0,
      this.completionPercentage = 0.0,
      this.isFullyCompleted = false});

  factory _$DailyCompletionStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyCompletionStatsImplFromJson(json);

  @override
  final DateTime date;
  @override
  @JsonKey()
  final int totalHabits;
  @override
  @JsonKey()
  final int completedHabits;
  @override
  @JsonKey()
  final double completionPercentage;
  @override
  @JsonKey()
  final bool isFullyCompleted;

  @override
  String toString() {
    return 'DailyCompletionStats(date: $date, totalHabits: $totalHabits, completedHabits: $completedHabits, completionPercentage: $completionPercentage, isFullyCompleted: $isFullyCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyCompletionStatsImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.totalHabits, totalHabits) ||
                other.totalHabits == totalHabits) &&
            (identical(other.completedHabits, completedHabits) ||
                other.completedHabits == completedHabits) &&
            (identical(other.completionPercentage, completionPercentage) ||
                other.completionPercentage == completionPercentage) &&
            (identical(other.isFullyCompleted, isFullyCompleted) ||
                other.isFullyCompleted == isFullyCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, totalHabits,
      completedHabits, completionPercentage, isFullyCompleted);

  /// Create a copy of DailyCompletionStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyCompletionStatsImplCopyWith<_$DailyCompletionStatsImpl>
      get copyWith =>
          __$$DailyCompletionStatsImplCopyWithImpl<_$DailyCompletionStatsImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyCompletionStatsImplToJson(
      this,
    );
  }
}

abstract class _DailyCompletionStats implements DailyCompletionStats {
  const factory _DailyCompletionStats(
      {required final DateTime date,
      final int totalHabits,
      final int completedHabits,
      final double completionPercentage,
      final bool isFullyCompleted}) = _$DailyCompletionStatsImpl;

  factory _DailyCompletionStats.fromJson(Map<String, dynamic> json) =
      _$DailyCompletionStatsImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get totalHabits;
  @override
  int get completedHabits;
  @override
  double get completionPercentage;
  @override
  bool get isFullyCompleted;

  /// Create a copy of DailyCompletionStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyCompletionStatsImplCopyWith<_$DailyCompletionStatsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
