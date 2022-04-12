import 'package:cuidapet_curso/app/models/endereco_model.dart';
import 'package:cuidapet_curso/app/shared/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:google_maps_webservice/places.dart';
import 'enderecos_controller.dart';

class EnderecosPage extends StatefulWidget {
  final String title;
  const EnderecosPage({Key key, this.title = "Enderecos"}) : super(key: key);

  @override
  _EnderecosPageState createState() => _EnderecosPageState();
}

class _EnderecosPageState
    extends ModularState<EnderecosPage, EnderecosController> {
  //use 'controller' variable to access controller

  @override
  void initState() {
    super.initState();
    controller.buscarEnderecosCadastrados();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //Antes de sair dessa tela, irá chamar esse metódo.
        //Se a verificação for falsa, não deixa sair da tela
        var enderecoSelecionado = await controller.enderecoFoiSelecionado();
        if (enderecoSelecionado) {
          return true;
        } else {
          Get.snackbar('Erro', 'Por favor, selecione um endereço!');
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'Adicione ou escolha um endereço',
                    style: ThemeUtils.theme.textTheme.headline5.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  //*Utilizando material para inserir elevation no typeaheadfield, que por default não tem essa caracteristica.
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(20),
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: controller.enderecoTextController,
                          focusNode: controller.enderecoFocusNode,
                          decoration: InputDecoration(
                            prefixIcon:
                                Icon(Icons.location_on, color: Colors.black),
                            hintText: 'Insira um endereço',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(style: BorderStyle.none),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(style: BorderStyle.none),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(style: BorderStyle.none),
                            ),
                          ),
                        ),
                        suggestionsCallback: (String pattern) async {
                          //* Pattern, o que está sendo digitado
                          var teste = await controller.buscarEnderecos(pattern);
                          print(teste);
                          return teste;
                        },
                        itemBuilder:
                            (BuildContext context, Prediction itemData) {
                          return ListTile(
                            leading: Icon(Icons.location_on),
                            title: Text(itemData.description),
                          );
                        },
                        onSuggestionSelected: (Prediction suggestion) {
                          controller.enderecoTextController.text =
                              suggestion.description;
                          controller.enviarDetalhe(suggestion);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    onTap: () => controller.minhaLocalizacao(),
                    leading: CircleAvatar(
                      child: Icon(Icons.near_me, color: Colors.white),
                      radius: 30,
                      backgroundColor: Colors.red,
                    ),
                    title: Text('Localização Atual'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  SizedBox(height: 10),
                  Observer(builder: (_) {
                    return FutureBuilder<List<EnderecoModel>>(
                        future: controller.enderecosFuture,
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              return Container();
                              break;
                            case ConnectionState.waiting:
                              return Center(child: CircularProgressIndicator());
                              break;
                            case ConnectionState.active:
                              break;
                            case ConnectionState.done:
                              if (snapshot.hasData) {
                                var data = snapshot.data;
                                return ListView.builder(
                                  //*skrinkwrap = true pois está dentro de uma column
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) =>
                                      _buildItemEndereco(data[index]),
                                  itemCount: data.length,
                                );
                              } else {
                                return Center(
                                  child: Text('Nenhum endereço cadastrado'),
                                );
                              }
                              break;
                            default:
                              return Container();
                          }
                        });
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemEndereco(EnderecoModel model) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        onTap: () => controller.selecionarEndereco(model),
        leading: CircleAvatar(
          radius: 30,
          child: Icon(Icons.location_on, color: Colors.black),
          backgroundColor: Colors.white,
        ),
        title: Text(model.endereco),
        subtitle: Text(model.complemento),
      ),
    );
  }
}
