import 'dart:io';

import 'package:cuidapet_curso/app/models/usuario_model.dart';
import 'package:cuidapet_curso/app/repository/shared_prefs_repository.dart';
import 'package:cuidapet_curso/app/services/usuario_service.dart';
import 'package:cuidapet_curso/app/shared/auth_store.dart';
import 'package:cuidapet_curso/app/shared/components/loader.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:image_picker/image_picker.dart';

class HomeDrawer extends Drawer {
  HomeDrawer()
      : super(
            child: Container(
          margin: EdgeInsets.only(top: ScreenUtil.statusBarHeight),
          child: Observer(
            builder: (_) {
              var user = Modular.get<AuthStore>().usuarioLogado;
              return Column(
                children: <Widget>[
                  Container(
                    height: 200,
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topCenter,
                          child: CircleAvatar(
                            radius: 100,
                            backgroundImage: user.imgAvatar != null
                                ? NetworkImage(user.imgAvatar)
                                : null,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: InkWell(
                              onTap: () => _alterarImagemPerfil(),
                              child: Container(
                                color: Colors.white54,
                                child: Text(
                                  'Alterar imagem',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(user.email),
                  Container(),
                  ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      ListTile(
                        onTap: () => Modular.to.pushNamed('/meus_agendamentos'),
                        leading: Icon(Icons.receipt),
                        title: Text('Meus Agendamentos'),
                      ),
                      ListTile(
                        onTap: () => Modular.to.pushNamed('/chat_lista'),
                        leading: Icon(Icons.chat),
                        title: Text('Chats'),
                      ),
                      ListTile(
                        onTap: () async {
                          final prefs = await SharedPrefsRepository.instance;
                          await prefs.logout();
                        },
                        leading: Icon(Icons.exit_to_app),
                        title: Text('Sair'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ));

  static Future<void> _alterarImagemPerfil() async {
    Loader.show();
    var imageFile = await ImagePicker().getImage(source: ImageSource.camera);
    var reference = FirebaseStorage.instance
        .ref()
        .child('/perfil/${DateTime.now().millisecondsSinceEpoch.toString()}');

    //*Enviando a imagem para o firebase storage
    var uploadTask = reference.putFile(File(imageFile.path));
    var storageTask = await uploadTask.onComplete;
    var url = await storageTask.ref.getDownloadURL();
    //*o backend sabe qual usuário atualizar pelo token que é enviado na requisição autenticada
    var novoUsuario =
        await Modular.get<UsuarioService>().atualizarImagemPerfil(url);
    final prefs = await SharedPrefsRepository.instance;
    prefs.registerUserData(novoUsuario);
    Modular.get<AuthStore>().loadUsuario();
    Loader.hide();
  }
}
