// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internalsystem/models/register_model.dart';
import 'package:internalsystem/stores/request_store.dart';
import 'package:mobx/mobx.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

part 'register_store.g.dart';

class RegisterStore = _RegisterStore with _$RegisterStore;

abstract class _RegisterStore with Store {
  static const _url =
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAE8KFKXcg1ATVd6l-G9P7BHKrfXt--QZ8';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @action
  Future<void> signUpWithEmailAndPassword(
      RegisterModel data, Function onSuccess, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        body: jsonEncode({
          'email': data.email,
          'password': data.password,
          'returnSecureToken': true,
        }),
      );

      if (jsonDecode(response.body).containsKey('idToken')) {
        await zipCodeVerification(data, () async {
          duplicityCheck(data, () async {
            data.id = await verificateId(context);
            await registerData(
                'users', jsonDecode(response.body)['localId'], data, () async {
              await registerSecondaryData('users', 'permissions',
                  jsonDecode(response.body)['localId'], 'internalSystem', data);
              onSuccess();
            });
            print("Novo usuário registrado com sucesso.");
          });
        });
      } else {
        print("Token de autenticação não encontrado.");
      }
    } catch (e) {
      print("Erro ao registrar usuário: $e");
    }
  }

  Future<int> verificateId(BuildContext context) async {
    final store = Provider.of<RequestStore>(context, listen: false);

    // Buscando todos os usuários
    final existingUsers = await store.fetchData('users', information: ['id']);

    // Verifica se existingUsers não é nulo e contém elementos
    if (existingUsers != null && existingUsers.isNotEmpty) {
      final maxId = existingUsers
          .map(
              (user) => user['data']['id'] as int) // Acessa o ID dentro de data
          .reduce((a, b) => a > b ? a : b);
      return maxId + 1; // Retorna o maior ID + 1
    }

    return 0; // Se não houver usuários, retorna 0
  }

  @action
  Future<void> registerData(
    String collection,
    String document,
    RegisterModel data,
    Function onSuccess,
  ) async {
    try {
      await _firestore.collection(collection).doc(document).set(data.toMap());
      print('Id: $document');
      print('Email: ${data.email}');
      print('Cargo: ${data.role}');

      onSuccess();
    } catch (e) {
      print("Erro ao registrar dados do usuário: $e");
    }
  }

  @action
  Future<void> registerSecondaryData(
    String collection,
    String secondaryCollection,
    String document,
    String secondaryDocument,
    RegisterModel data,
  ) async {
    try {
      await _firestore
          .collection(collection)
          .doc(document)
          .collection(secondaryCollection)
          .doc(secondaryDocument)
          .set(data.secondaryData ?? {});

      print('Acesso web: ${data.secondaryData?['isAdmin'] ?? false}');
    } catch (e) {
      print("Erro ao registrar dados do usuário: $e");
    }
  }

  @action
  Future<void> duplicityCheck(RegisterModel data, Function onSuccess) async {
    try {
      final fieldsToCheck = {
        'name': data.name?.toLowerCase(),
        'email': data.email?.toLowerCase(),
        'cpf': data.cpf?.toLowerCase(),
      };

      for (final entry in fieldsToCheck.entries) {
        if (entry.value == null) continue;

        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(entry.key, isEqualTo: entry.value)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          print('Duplicidade encontrada para o campo ${entry.key}.');
          return;
        }
      }
      onSuccess();
    } catch (e) {
      print('Erro ao verificar duplicidade: $e');
    }
  }

  @action
  Future<void> zipCodeVerification(
      RegisterModel data, Function onSuccess) async {
    try {
      //Temporario
      if (data.address?['zipCode'] == null ||
          data.address?['zipCode'].isEmpty) {
        print('Nenhum CEP foi fornecido!');
        onSuccess();
        return;
      }
      //Temporario

      final rsp = await http.get(Uri.parse(
          "https://viacep.com.br/ws/${data.address?['zipCode']}/json/"));

      if (rsp.body.isEmpty) {
        print('Nenhuma informação foi encontrada!');
        return;
      }

      if (rsp.body.contains('"erro": true')) {
        print('CEP não encontrado!');
        return;
      }

      final responseData = json.decode(rsp.body);
      data = RegisterModel(
        address: {
          'zipCode': responseData['cep'],
          'street': responseData['logradouro'],
          'district': responseData['bairro'],
          'city': responseData['localidade'],
          'state': responseData['uf'],
        },
      );

      onSuccess();
    } catch (error) {
      print('Erro ao buscar CEP: $error');
    }
  }
}
