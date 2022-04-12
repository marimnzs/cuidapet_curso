import 'package:cuidapet_curso/app/models/fornecedor_busca_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import 'package:cuidapet_curso/app/models/categoria_model.dart';
import 'package:cuidapet_curso/app/models/endereco_model.dart';
import 'package:cuidapet_curso/app/repository/shared_prefs_repository.dart';
import 'package:cuidapet_curso/app/services/categorias_service.dart';
import 'package:cuidapet_curso/app/services/endereco_service.dart';
import 'package:cuidapet_curso/app/services/fornecedor_service.dart';

part 'home_controller.g.dart';

@Injectable()
class HomeController = _HomeControllerBase with _$HomeController;

abstract class _HomeControllerBase with Store {
  final EnderecoService _enderecoService;
  final CategoriasService _categoriasService;
  final FornecedorService _fornecedorService;
  final TextEditingController filtroNomeController = TextEditingController();

  @observable
  int paginaSelecionada = 0;

  @observable
  EnderecoModel enderecoSelecionado;

  @observable
  ObservableFuture<List<CategoriaModel>> categoriasFuture;

  @observable
  ObservableFuture<List<FornecedorBuscaModel>> estabelecimentosFuture;

  List<FornecedorBuscaModel> estabelecimentosOriginais;

  @observable
  int categoriaSelecionada;

  _HomeControllerBase(
    this._enderecoService,
    this._categoriasService,
    this._fornecedorService,
  );

  @action
  Future<void> initPage() async {
    await temEnderecoCadastrado();
    await recuperarEnderecoSelecionado();
    buscarCategorias();
    await buscarEstabelecimentos();
  }

  @action
  void alterarPaginaSelecionar(int pagina) => paginaSelecionada = pagina;

  @action
  Future<void> recuperarEnderecoSelecionado() async {
    var prefs = await SharedPrefsRepository.instance;
    enderecoSelecionado = await prefs.enderecoSelecionado;
    if (enderecoSelecionado == null) {
      await Modular.to.pushNamed('/home/enderecos');
      await recuperarEnderecoSelecionado();
    }
  }

  @action
  void buscarCategorias() {
    categoriasFuture = ObservableFuture(_categoriasService.buscarCategorias());
  }

  @action
  Future<void> temEnderecoCadastrado() async {
    var temEndereco = await _enderecoService.existeEnderecoCadastrado();
    //*Não deve ser possivel acessar a página home sem endereço
    if (!temEndereco) {
      //* pode utilizar .link quando é uma rota que está dentro do modulo, aí ficaria: /enderecos
      await Modular.to.pushNamed('/home/enderecos');
    }
  }

  @action
  Future<void> buscarEstabelecimentos() async {
    categoriaSelecionada = null;
    filtroNomeController.text = '';
    estabelecimentosFuture = ObservableFuture(
        _fornecedorService.buscarFornecedoresProximos(enderecoSelecionado));
    estabelecimentosOriginais = await estabelecimentosFuture;
  }

  @action
  void filtrarPorCategoria(int id) {
    if (categoriaSelecionada == id) {
      //tirando a seleção da categoria
      categoriaSelecionada = null;
    } else {
      categoriaSelecionada = id;
    }
    _filtrarEstabelecimentos();
  }

  @action
  void filtrarEstabelecimentoPorNome() {
    _filtrarEstabelecimentos();
  }

  @action
  void _filtrarEstabelecimentos() {
    var fornecedores = estabelecimentosOriginais;

    if (categoriaSelecionada != null) {
      fornecedores = fornecedores
          .where((e) => e.categoria.id == categoriaSelecionada)
          .toList();
    }

    if (filtroNomeController.text.isNotEmpty) {
      fornecedores = fornecedores
          .where((e) => e.nome
              .toLowerCase()
              .contains(filtroNomeController.text.toLowerCase()))
          .toList();
    }

    estabelecimentosFuture = ObservableFuture(Future.value(fornecedores));
  }
}
