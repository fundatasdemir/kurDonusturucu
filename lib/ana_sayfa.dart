import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnaSayfa extends StatefulWidget {
  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final String _apiKey = "fa490c213ea7359be4e637facafe2cda";

  final String _baseUrl =
      "http://api.exchangeratesapi.io/v1/latest?access_key=";

  TextEditingController _controller = TextEditingController();

  Map<String, double> _oranlar = {};

  String _secilenKur = "USD";
  double _sonuc = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_AnaSayfaState) {
      _verileriInternettenCek();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kur Dönüştürücü"),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.cyan,
          fontSize: 25,
          decoration: TextDecoration.none,
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        leading: Icon(Icons.change_circle),
        actions: [
          IconButton(
            icon: Icon(Icons.change_circle, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Miktarı giriniz:",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                        style: BorderStyle.solid,
                        strokeAlign: 15,
                      ),
                    ),
                  ),
                  onChanged: (String yeniDeger) {
                    _hesapla();
                  },
                ),
              ),
              SizedBox(
                width: 16,
              ),
              DropdownButton<String>(
                value: _secilenKur,
                items: _oranlar.keys.map((String kur) {
                  return DropdownMenuItem<String>(
                    value: kur,
                    child: Text(kur),
                  );
                }).toList(),
                onChanged: (String? yeniDeger) {
                  if (yeniDeger != null) {
                    _secilenKur = yeniDeger;
                    _hesapla();
                  }
                },
                icon: Icon(Icons.arrow_downward),
                underline: SizedBox(),
              ),
            ],
          ),
          SizedBox(height: 25),
          Text(
            "Sonuç:${_sonuc.toStringAsFixed(2)} TL",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Container(
            height: 3,
            color: Colors.black,
          ),
          SizedBox(
            height: 25,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: _oranlar.keys.length, itemBuilder: _buildListItem),
          )
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return ListTile(
      title: Text(_oranlar.keys.toList()[index]),
      trailing: Text(_oranlar.values.toList()[index].toStringAsFixed(2)),
    );
  }

  void _hesapla() {
    double? deger = double.tryParse(_controller.text);
    double? oran = _oranlar[_secilenKur];

    if (deger != null && oran != null) {
      setState(() {
        _sonuc = deger * oran;
      });
    }
  }

  void _verileriInternettenCek() async {
    Uri uri = Uri.parse(_baseUrl + _apiKey);
    http.Response response = await http.get(uri);

    Map<String, dynamic> parsedResponce = jsonDecode(response.body);

    Map<String, dynamic> rates = parsedResponce["rates"];

    double? baseTlKuru = rates["TRY"];

    if (baseTlKuru != null) {
      for (String ulkeKuru in rates.keys) {
        double? baseKur = double.tryParse(rates[ulkeKuru].toString());
        if (baseKur != null) {
          double tlKuru = baseTlKuru / baseKur;
          _oranlar[ulkeKuru] = tlKuru;
        }
      }
    }
    setState(() {});
  }
}


/*
API RESPONSE:
{
    "success": true,
    "timestamp": 1519296206,
    "base": "EUR",
    "date": "2021-03-17",
    "rates": {
        "AUD": 1.566015,
        "CAD": 1.560132,
        "CHF": 1.154727,
        "CNY": 7.827874,
        "GBP": 0.882047,
        "JPY": 132.360679,
        "USD": 1.23396,
    [...]
    }
}

*/