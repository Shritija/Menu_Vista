import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:menu_vista/firebase_options.dart';
import 'LoginPage.dart';
import 'RestaurantListPage.dart';
import 'MenuPage.dart';
import 'CartPage.dart';
import 'ForgotPasswordPage.dart';
import 'ItemPage.dart';
import 'ProfilePage.dart';
import 'RestaurantSignUpPage.dart';
import 'ReviewPage.dart';
import 'SignUpPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBFwOrZUiMrCXz6LWQ0wEfmlt8_qWTgtks",
        appId: "1:722133009908:web:a1f557a260aa0927f5e5a1",
        messagingSenderId: "722133009908",
        projectId: "menuvista-cebae",
        authDomain: "menuvista-cebae.firebaseapp.com",
        storageBucket: "menuvista-cebae.appspot.com",
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(MenuVistaApp());
}

class MenuVistaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // FirebaseMessaging.instance.requestPermission(
    //     alert: true,
    //     announcement: false,
    //     badge: true,
    //     carPlay: false,
    //     criticalAlert: false,
    //     provisional: false,
    //     sound: true,
    //   );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      // Use onGenerateRoute for dynamic routing
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/forgot_password':
            return MaterialPageRoute(builder: (context) => ForgotPasswordPage());
          case '/signup':
            return MaterialPageRoute(builder: (context) => SignUpPage());
          case '/restaurant_list':
            return MaterialPageRoute(builder: (context) => RestaurantListPage());
          case '/menu':
            final Rid = settings.arguments as String; // Retrieve the Rid argument
            return MaterialPageRoute(
              builder: (context) => MenuPage(Rid: Rid), // Pass Rid to MenuPage
            );
          case '/profile':
            final documentId = settings.arguments as String;
            return MaterialPageRoute(
                builder: (context) => ProfilePage(documentId: documentId),
            );
          case '/cart':
            final args = settings.arguments as Map<String, String>; // Expect a Map for cart
            return MaterialPageRoute(
              builder: (context) => CartPage(
                   restaurantId: args['restaurantId']!, // Get restaurantId
                   itemId: args['itemId']!,
                  userId: args['userId']!,
                  extraInstructions: args['extraInstructions']!,
                  selectedSize: args['selectedSize']!,
                  price: args['price'] as int,
        ),
            );
          case '/item':
            final itemArgs = settings.arguments as Map<String, String>; // Expect a Map for item
            return MaterialPageRoute(
              builder: (context) => ItemPage(
                restaurantId: itemArgs['restaurantId']!, // Get restaurantId
                itemId: itemArgs['itemId']!, // Get itemId
              ),
            );
          case '/review':
            final reviewArgs = settings.arguments as Map<String, String>; // Expect a Map for review
            return MaterialPageRoute(
              builder: (context) => ReviewPage(
                restaurantId: reviewArgs['restaurantId']!, // Get restaurantId
                itemId: reviewArgs['itemId']!, // Get itemId
              ),
            );
          case '/restaurantsignup':
            return MaterialPageRoute(builder: (context) => RestaurantSignUpPage());
          default:
            return null; // Return null for unknown routes
        }
      },
    );
  }
}



class UnderConstructionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Under Construction'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          'Under Construction',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}