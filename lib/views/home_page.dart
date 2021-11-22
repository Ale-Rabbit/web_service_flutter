import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:web_service/services/via_cep_service.dart';

import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCepController = TextEditingController();
  bool _loading = false;
  bool _enableField = true;
  String? _result;

  var _resultJson;

  bool logradouroExiste = false;
  bool complementoExiste = false;
  bool bairroExiste = false;
  bool localidadeExiste = false;
  bool ufExiste = false;
  bool ibgeExiste = false;
  bool giaExiste = false;
  bool dddExiste = false;
  bool siafiExiste = false;

  @override
  void dispose() {
    super.dispose();
    _searchCepController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Consultar CEP'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSearchCepTextField(),
            _buildSearchCepButton(),
            _buildResultForm()
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCepTextField() {
    return TextField(
      autofocus: true,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(labelText: 'Cep'),
      controller: _searchCepController,
      enabled: _enableField,
    );
  }

  Widget _buildSearchCepButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ElevatedButton(
          onPressed: _searchCep,
          child: _loading ? _circularLoading() : const Text('Consultar'),
          style: ElevatedButton.styleFrom(
            primary: Colors.pinkAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 15.0,
          )),
    );
  }

  void _searching(bool enable) {
    setState(() {
      _result = enable ? '' : _result;
      _loading = enable;
      _enableField = !enable;
    });
  }

  Widget _circularLoading() {
    return const CircularProgressIndicator();
  }

  Future _searchCep() async {
    _searching(true);

    final cep = _searchCepController.text;

    if (cep.length > 8) {
      _avisarErroPorFlushbar(context, 'CEP inválido: maior de 8 caracteres');
    } else {
      final resultCep = await ViaCepService.fetchCep(cep: cep);

      if (resultCep == null) {
        // todo: melhorar esses cenários de erro da chamada na API
        _avisarErroPorFlushbar(context, 'CEP inválido: nenhum dado encontrado');
      }

      setState(() {
        _result = resultCep.toJson();
        _resultJson = resultCep;
      });

      //todo: arrumar formatação porque o VS Code deixou todo zoado
      logradouroExiste = _resultJson != null &&
          _resultJson.logradouro != null &&
          _resultJson.logradouro != "";
      complementoExiste = _resultJson != null &&
          _resultJson.complemento != null &&
          _resultJson.complemento != "";
      bairroExiste = _resultJson != null &&
          _resultJson.bairro != null &&
          _resultJson.bairro != "";
      localidadeExiste = _resultJson != null &&
          _resultJson.localidade != null &&
          _resultJson.localidade != "";
      ufExiste =
          _resultJson != null && _resultJson.uf != null && _resultJson.uf != "";
      ibgeExiste = _resultJson != null &&
          _resultJson.ibge != null &&
          _resultJson.ibge != "";
      giaExiste = _resultJson != null &&
          _resultJson.gia != null &&
          _resultJson.gia != "";
      dddExiste = _resultJson != null &&
          _resultJson.ddd != null &&
          _resultJson.ddd != "";
      siafiExiste = _resultJson != null &&
          _resultJson.siafi != null &&
          _resultJson.siafi != "";
    }

    _searching(false);
  }

  Widget _buildResultForm() {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: SizedBox(
        child: ListView(
          shrinkWrap: true,
          children: [
            logradouroExiste
                ? Card(
                    color: Colors.pink[50],
                    child: ListTile(
                        title: Text('Logradouro: ${_resultJson.logradouro}'),
                        trailing: const Icon(Icons.share),
                        onTap: () {
                          _compartilhar(context, _resultJson.cep);
                        }))
                : const Card(),
            complementoExiste
                ? Card(
                    color: Colors.pink[50],
                    child: ListTile(
                        title: Text('Complemento: ${_resultJson.complemento}')))
                : const Card(),
            bairroExiste
                ? Card(
                    color: Colors.pink[50],
                    child:
                        ListTile(title: Text('Bairro: ${_resultJson.bairro}')))
                : const Card(),
            localidadeExiste
                ? Card(
                    color: Colors.pink[50],
                    child: ListTile(
                        title: Text('Localidade: ${_resultJson.localidade}')))
                : const Card(),
            ufExiste
                ? Card(
                    color: Colors.pink[50],
                    child: ListTile(title: Text('UF: ${_resultJson.uf}')))
                : const Card(),
            ibgeExiste
                ? Card(
                    color: Colors.pink[50],
                    child: ListTile(title: Text('Ibge: ${_resultJson.ibge}')))
                : const Card(),
            giaExiste
                ? Card(
                    color: Colors.pink[50],
                    child: ListTile(title: Text('Gia: ${_resultJson.gia}')))
                : const Card(),
            dddExiste
                ? Card(
                    color: Colors.pink[50],
                    child: ListTile(title: Text('DDD: ${_resultJson.ddd}')))
                : const Card(),
            siafiExiste
                ? Card(
                    color: Colors.pink[50],
                    child: ListTile(title: Text('Siafi: ${_resultJson.siafi}')))
                : const Card()
            /* todo: melhoria para não repetir código: teste(logradouroExiste, "logradouro"),*/
          ],
        ),
      ),
    );
  }

/* todo: melhoria para não repetir código:
  Card teste(bool logradouroExiste, String campo) {
    //var campoParaJson = campo.toLowerCase();
    return logradouroExiste
        ? Card(child: ListTile(title: Text('campo: ${_resultJson.campo}')))
        : const Card();
  }
  */

  void _avisarErroPorFlushbar(BuildContext context, String mensagem) =>
      Flushbar(
        icon: const Icon(
          Icons.warning,
          size: 32,
          color: Colors.yellow,
        ),
        message: mensagem,
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        shouldIconPulse: false,
        margin: const EdgeInsets.fromLTRB(6, kToolbarHeight + 6, 6, 0),
        borderRadius: 10,
      )..show(context);

  void _compartilhar(BuildContext context, String cep) {
    Share.share('CEP do aplicativo da Alexandra: $cep');
  }
}
