import 'package:cuidapet_curso/app/modules/home/enderecos/enderecos_module.dart';
import 'package:cuidapet_curso/app/repository/categorias_repository.dart';
import 'package:cuidapet_curso/app/services/categorias_service.dart';

import 'home_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'home_page.dart';

class HomeModule extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => CategoriasRepository()),
        Bind((i) => CategoriasService(i.get())),
        Bind((i) => HomeController(i.get(), i.get(), i.get())),
      ];

  @override
  List<ModularRouter> get routers => [
        ModularRouter(Modular.initialRoute, child: (_, args) => HomePage()),
        ModularRouter('/enderecos', module: EnderecosModule()),
      ];

  static Inject get to => Inject<HomeModule>.of();
}
