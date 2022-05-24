import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pay/product.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

Future<void> main() async {

  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<product> listproduct = [];
  Razorpay? razorpay;

  get() async {
    //get-1 ,post-2
    var url = Uri.parse('https://fakestoreapi.com/products?limit=5');
    var response = await http.get(url);
    var result = jsonDecode(response.body);

    result.forEach((element) {
      setState(() {
        listproduct.add(product.fromJson(element));
      });
    });
  }

  void initState() {
    super.initState();
    get();
    razorpay = Razorpay();
    razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay!.clear();
  }

  void openCheckout(int id) async {
    var options = {
      'key': 'rzp_test_evMx1LkuS52SQ7',
      'amount': id *
          100,
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      razorpay!.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Success Response: $response');
    /*Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Error Response: $response');
    /* Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External SDK Response: $response');
    /* Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("hellio")),
      body: listproduct.length == 0
          ? CircularProgressIndicator()
          : ListView.builder(
              itemCount: listproduct.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("${listproduct[index].title}"),
                  subtitle: Text("${listproduct[index].price}"),
                  leading: Image.network("${listproduct[index].image}"),
                  trailing: TextButton(
                      onPressed: () {
                        openCheckout(listproduct[index].id ?? 0);
                      },
                      child: Text("buy")),
                );
              },
            ),
    );
  }
}
