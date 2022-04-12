import 'package:cuidapet_curso/app/models/fornecedor_busca_model.dart';
import 'package:cuidapet_curso/app/shared/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/screenutil.dart';

class EstabelecimentoItemGrid extends StatelessWidget {
  final FornecedorBuscaModel _fornecedor;
  const EstabelecimentoItemGrid(this._fornecedor, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Modular.to.pushNamed('/estabelecimento/${_fornecedor.id}'),
      child: Stack(
        children: <Widget>[
          Card(
            margin: EdgeInsets.only(top: 40, left: 10, right: 10),
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: ScreenUtil.screenWidthDp,
              height: 120,
              child: Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(_fornecedor.nome,
                        textAlign: TextAlign.center,
                        style: ThemeUtils.theme.textTheme.subtitle2),
                    Text(
                        '${_fornecedor.distancia.toStringAsFixed(2)} km de distancia'),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(
                  _fornecedor.logo,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
