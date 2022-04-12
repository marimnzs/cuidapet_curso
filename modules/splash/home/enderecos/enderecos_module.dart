import 'detalhe/detalhe_controller.dart';
import 'detalhe/detalhe_page.dart';
import 'enderecos_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'enderecos_page.dart';

class EnderecosModule extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => DetalheController(i.get())),
        Bind((i) => EnderecosController(i.get())),
      ];

  @override
  List<ModularRouter> get routers => [
        ModularRouter(Modular.initialRoute,
            child: (_, args) => EnderecosPage()),
        ModularRouter('/detalhe',
            child: (_, args) => DetalhePage(enderecoModel: args.data))
      ];

  static Inject get to => Inject<EnderecosModule>.of();
}
