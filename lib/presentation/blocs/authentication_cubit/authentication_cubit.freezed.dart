// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'authentication_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthenticationState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthenticationState()';
}


}

/// @nodoc
class $AuthenticationStateCopyWith<$Res>  {
$AuthenticationStateCopyWith(AuthenticationState _, $Res Function(AuthenticationState) __);
}


/// Adds pattern-matching-related methods to [AuthenticationState].
extension AuthenticationStatePatterns on AuthenticationState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthenticationInitial value)?  initial,TResult Function( AuthenticationAuthenticated value)?  authenticated,TResult Function( AuthenticationUnauthenticated value)?  unauthenticated,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthenticationInitial() when initial != null:
return initial(_that);case AuthenticationAuthenticated() when authenticated != null:
return authenticated(_that);case AuthenticationUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthenticationInitial value)  initial,required TResult Function( AuthenticationAuthenticated value)  authenticated,required TResult Function( AuthenticationUnauthenticated value)  unauthenticated,}){
final _that = this;
switch (_that) {
case AuthenticationInitial():
return initial(_that);case AuthenticationAuthenticated():
return authenticated(_that);case AuthenticationUnauthenticated():
return unauthenticated(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthenticationInitial value)?  initial,TResult? Function( AuthenticationAuthenticated value)?  authenticated,TResult? Function( AuthenticationUnauthenticated value)?  unauthenticated,}){
final _that = this;
switch (_that) {
case AuthenticationInitial() when initial != null:
return initial(_that);case AuthenticationAuthenticated() when authenticated != null:
return authenticated(_that);case AuthenticationUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( UserEntity user)?  authenticated,TResult Function()?  unauthenticated,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthenticationInitial() when initial != null:
return initial();case AuthenticationAuthenticated() when authenticated != null:
return authenticated(_that.user);case AuthenticationUnauthenticated() when unauthenticated != null:
return unauthenticated();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( UserEntity user)  authenticated,required TResult Function()  unauthenticated,}) {final _that = this;
switch (_that) {
case AuthenticationInitial():
return initial();case AuthenticationAuthenticated():
return authenticated(_that.user);case AuthenticationUnauthenticated():
return unauthenticated();case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( UserEntity user)?  authenticated,TResult? Function()?  unauthenticated,}) {final _that = this;
switch (_that) {
case AuthenticationInitial() when initial != null:
return initial();case AuthenticationAuthenticated() when authenticated != null:
return authenticated(_that.user);case AuthenticationUnauthenticated() when unauthenticated != null:
return unauthenticated();case _:
  return null;

}
}

}

/// @nodoc


class AuthenticationInitial implements AuthenticationState {
  const AuthenticationInitial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthenticationState.initial()';
}


}




/// @nodoc


class AuthenticationAuthenticated implements AuthenticationState {
  const AuthenticationAuthenticated({required this.user});
  

 final  UserEntity user;

/// Create a copy of AuthenticationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthenticationAuthenticatedCopyWith<AuthenticationAuthenticated> get copyWith => _$AuthenticationAuthenticatedCopyWithImpl<AuthenticationAuthenticated>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationAuthenticated&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode {
    return Object.hash(runtimeType,user);
}

@override
String toString() {
    return 'AuthenticationState.authenticated(user: $user)';
}


}

/// @nodoc
abstract mixin class $AuthenticationAuthenticatedCopyWith<$Res> implements $AuthenticationStateCopyWith<$Res> {
  factory $AuthenticationAuthenticatedCopyWith(AuthenticationAuthenticated value, $Res Function(AuthenticationAuthenticated) _then) = _$AuthenticationAuthenticatedCopyWithImpl;
@useResult
$Res call({
 UserEntity user
});




}
/// @nodoc
class _$AuthenticationAuthenticatedCopyWithImpl<$Res>
    implements $AuthenticationAuthenticatedCopyWith<$Res> {
  _$AuthenticationAuthenticatedCopyWithImpl(this._self, this._then);

  final AuthenticationAuthenticated _self;
  final $Res Function(AuthenticationAuthenticated) _then;

/// Create a copy of AuthenticationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = null,}) {
  return _then(AuthenticationAuthenticated(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserEntity,
  ));
}


}

/// @nodoc


class AuthenticationUnauthenticated implements AuthenticationState {
  const AuthenticationUnauthenticated();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationUnauthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthenticationState.unauthenticated()';
}


}




// dart format on
