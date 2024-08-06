// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RequestStore on _RequestStore, Store {
  late final _$fetchDataAsyncAction =
      AsyncAction('_RequestStore.fetchData', context: context);

  @override
  Future<RequestModel> fetchData(String collection, String document) {
    return _$fetchDataAsyncAction
        .run(() => super.fetchData(collection, document));
  }

  late final _$fetchSecondaryDataAsyncAction =
      AsyncAction('_RequestStore.fetchSecondaryData', context: context);

  @override
  Future<List<Map<String, dynamic>>> fetchSecondaryData(
      String collection, String secondCollection, String document) {
    return _$fetchSecondaryDataAsyncAction.run(
        () => super.fetchSecondaryData(collection, secondCollection, document));
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
