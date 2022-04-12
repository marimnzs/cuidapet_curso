import 'package:cuidapet_curso/app/models/categoria_model.dart';
import 'package:cuidapet_curso/app/models/fornecedor_busca_model.dart';
import 'package:cuidapet_curso/app/modules/home/components/estabelecimento_item_list.dart';
import 'package:cuidapet_curso/app/modules/home/components/estabelecimento_item_grid.dart';
import 'package:cuidapet_curso/app/modules/home/components/home_appbar.dart';
import 'package:cuidapet_curso/app/modules/home/components/home_drawer.dart';
import 'package:cuidapet_curso/app/shared/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ModularState<HomePage, HomeController> {
  HomeAppBar appBar;

  Map<String, IconData> categoriasIcons = {
    'P': Icons.pets,
    'V': Icons.local_hospital,
    'C': Icons.store_mall_directory
  };

  final _estabelecimentosPageController = PageController(initialPage: 0);

  _HomePageState() {
    appBar = HomeAppBar(controller);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.initPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: HomeDrawer(),
      appBar: appBar,
      body: RefreshIndicator(
        onRefresh: () => controller.buscarEstabelecimentos(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            width: ScreenUtil.screenWidthDp,
            //*para ajustar o scroll da tela e não dar scroll na appbar
            height: ScreenUtil.screenHeightDp -
                (appBar.preferredSize.height + ScreenUtil.statusBarHeight),
            child: Column(
              children: <Widget>[
                _buildEndereco(),
                _buildCategorias(),
                Expanded(child: _buildEstabelecimentos()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _buildEndereco() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Estabelecimentos próximos de '),
          Observer(builder: (_) {
            return Text(
              controller.enderecoSelecionado?.endereco ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            );
          })
        ],
      ),
    );
  }

  Widget _buildCategorias() {
    return Observer(builder: (_) {
      return FutureBuilder<List<CategoriaModel>>(
          future: controller.categoriasFuture,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Container();
                break;
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
                break;
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao buscar categorias'),
                  );
                }
                if (snapshot.hasData) {
                  var cats = snapshot.data;

                  return Container(
                    height: 130,
                    child: ListView.builder(
                      itemCount: cats.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var cat = cats[index];
                        return InkWell(
                          onTap: () => controller.filtrarPorCategoria(cat.id),
                          child: Container(
                            margin: EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Observer(builder: (_) {
                                  return CircleAvatar(
                                    radius: 30,
                                    backgroundColor:
                                        controller.categoriaSelecionada ==
                                                cat.id
                                            ? ThemeUtils.primaryColor
                                            : ThemeUtils.primaryColorLight,
                                    child: Icon(categoriasIcons[cat.tipo],
                                        size: 30, color: Colors.black),
                                  );
                                }),
                                SizedBox(height: 10),
                                Text(cat.nome),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Container();
                }

                break;
              default:
                return Container();
            }
          });
    });
  }

  Widget _buildEstabelecimentos() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Observer(builder: (_) {
            return Row(
              children: [
                Text('Estabelecimentos'),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    child: Icon(
                      Icons.view_headline,
                      color: controller.paginaSelecionada == 0
                          ? Colors.black
                          : Colors.grey,
                    ),
                    onTap: () {
                      _estabelecimentosPageController.previousPage(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.ease);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    onTap: () {
                      _estabelecimentosPageController.nextPage(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.ease);
                    },
                    child: Icon(
                      Icons.view_comfy,
                      color: controller.paginaSelecionada == 1
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
        Expanded(
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: _estabelecimentosPageController,
            onPageChanged: (pagina) =>
                controller.alterarPaginaSelecionar(pagina),
            children: [
              _buildEstabelecimentosLista(),
              _buildEstabelecimentosGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEstabelecimentosLista() {
    return Observer(builder: (_) {
      return FutureBuilder<List<FornecedorBuscaModel>>(
          future: controller.estabelecimentosFuture,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Container();
                break;
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
                break;
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao buscar estabelecimentos'),
                  );
                }
                if (snapshot.hasData) {
                  var fornecs = snapshot.data;
                  return ListView.separated(
                    separatorBuilder: (_, index) =>
                        Divider(color: Colors.transparent),
                    itemCount: fornecs.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return EstabelecimentoItemLista(fornecs[index]);
                    },
                  );
                } else {
                  return Container();
                }

                break;
              default:
                return Container();
            }
          });
    });
  }

  Widget _buildEstabelecimentosGrid() {
    return Observer(builder: (_) {
      return FutureBuilder<List<FornecedorBuscaModel>>(
          future: controller.estabelecimentosFuture,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Container();
                break;
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
                break;
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao buscar estabelecimentos'),
                  );
                }
                if (snapshot.hasData) {
                  var fornecs = snapshot.data;
                  return GridView.builder(
                    itemCount: fornecs.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return EstabelecimentoItemGrid(fornecs[index]);
                    },
                    //*Criando um grid com 2 colunas
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                    ),
                  );
                } else {
                  return Container();
                }

                break;
              default:
                return Container();
            }
          });
    });
  }
}
