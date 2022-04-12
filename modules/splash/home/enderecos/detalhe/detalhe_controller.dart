import 'package:cuidapet_curso/app/models/endereco_model.dart';
import 'package:cuidapet_curso/app/services/endereco_service.dart';
import 'package:cuidapet_curso/app/shared/components/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

part 'detalhe_controller.g.dart';

@Injectable()
class DetalheController = _DetalheControllerBase with _$DetalheController;

abstract class _DetalheControllerBase with Store {
  final EnderecoService _service;
  TextEditingController complementoController = TextEditingController();

  _DetalheControllerBase(this._service);

  Future<void> salvarEndereco(EnderecoModel model) async {
    try {
      Loader.show();
      model.complemento = complementoController.text;
      await _service.salvarEndereco(model);
      Loader.hide();
      Modular.to.pop();
    } catch (e) {
      Loader.hide();
      print('erro ao salvar endereço $e');
      Get.snackbar('Erro', 'Erro ao salvar endereço');
    }
  }
}
