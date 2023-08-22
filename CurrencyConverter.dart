import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: CurrencyConverterPage(),
    );
  }
}

class CurrencyConverterPage extends StatefulWidget {
  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedCurrency = 'USD';
  double _exchangeRate = 1.0; // Default exchange rate: 1 INR to selected currency

  double _convertedAmount = 0.0;

  Future<void> _fetchExchangeRate() async {
    final response = await http.get(
      Uri.parse('https://api.exchangerate-api.com/v4/latest/INR'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = data['rates'];
      setState(() {
        _exchangeRate = rates[_selectedCurrency];
      });
    }
  }

  void _convertCurrency() {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _convertedAmount = amount * _exchangeRate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('CURRENCY CONVERTER'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Enter amount in INR'),
            ),
            SizedBox(height: 20.0),
            DropdownButton<String>(
              dropdownColor: Colors.green[50],
              value: _selectedCurrency,
              onChanged: (newValue) {
                setState(() {
                  _selectedCurrency = newValue!;
                  _fetchExchangeRate();
                });
              },
              items: ['USD', 'EUR', 'GBP', 'JPY'].map<
                  DropdownMenuItem<String>>(
                    (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.green),),
                  );
                },
              ).toList(),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(

              onPressed: () {
                _fetchExchangeRate();
                _convertCurrency();
              },
              child: Text('Convert'),
            ),
            SizedBox(height: 20.0),
            Text(
                'Converted Amount: $_convertedAmount $_selectedCurrency',
                style: TextStyle(fontSize: 20, color: Colors.green)
            ),
          ],
        ),
      ),
    );
  }
}

