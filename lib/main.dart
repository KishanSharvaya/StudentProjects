import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soleoserp/ui/res/localizations/app_localizations.dart';
import 'package:soleoserp/ui/res/style_resources.dart';
import 'package:soleoserp/ui/screens/DashBoard/home_screen.dart';
import 'package:soleoserp/ui/screens/authentication/login_screen.dart';
import 'package:soleoserp/ui/screens/authentication/registration_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/Customer/CustomerAdd_Edit/customer_add_edit.dart';
import 'package:soleoserp/ui/screens/DashBoard/Customer/customer_list_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/inquiry/add_inquiry_product_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/inquiry/customer_search/customer_search_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/inquiry/inquiry_add_edit.dart';
import 'package:soleoserp/ui/screens/DashBoard/inquiry/inquiry_list_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/inquiry/inquiry_product_list_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/inquiry/search_inquiry_product_screen.dart';
import 'package:soleoserp/ui/screens/DashBoard/inquiry/search_inquiry_screen.dart';
import 'package:soleoserp/utils/general_utils.dart';
import 'package:soleoserp/utils/offline_db_helper.dart';
import 'package:soleoserp/utils/shared_pref_helper.dart';

import 'ui/screens/dashboard/Customer/search_customer_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefHelper.createInstance();
  await OfflineDbHelper.createInstance();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  ///handles screen transaction based on route name
  static MaterialPageRoute globalGenerateRoute(RouteSettings settings) {
    //if screen have no argument to pass data in next screen while transiting
    // final GlobalKey<ScaffoldState> key = settings.arguments;

    switch (settings.name) {
      case RegistrationScreen.routeName:
        return getMaterialPageRoute(RegistrationScreen());
      case LoginScreen.routeName:
        return getMaterialPageRoute(LoginScreen());
      case HomeScreen.routeName:
        return getMaterialPageRoute(HomeScreen());
      case CustomerListScreen.routeName:
        return getMaterialPageRoute(CustomerListScreen());
      case Customer_ADD_EDIT.routeName:
        return getMaterialPageRoute(Customer_ADD_EDIT(settings.arguments));
      case SearchCustomerScreen.routeName:
        return getMaterialPageRoute(SearchCustomerScreen());

      case InquiryListScreen.routeName:
        return getMaterialPageRoute(InquiryListScreen());

      case InquiryAddEditScreen.routeName:
        return getMaterialPageRoute(InquiryAddEditScreen(settings.arguments));

      case InquiryProductListScreen.routeName:
        return getMaterialPageRoute(
            InquiryProductListScreen(settings.arguments));

      case SearchInquiryCustomerScreen.routeName:
        return getMaterialPageRoute(SearchInquiryCustomerScreen());
      case AddInquiryProductScreen.routeName:
        return getMaterialPageRoute(
            AddInquiryProductScreen(settings.arguments));
      case SearchInquiryProductScreen.routeName:
        return getMaterialPageRoute(SearchInquiryProductScreen());
      case SearchInquiryScreen.routeName:
        return getMaterialPageRoute(SearchInquiryScreen());
      //SearchInquiryScreen
      default:
        return null;
    }
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        onGenerateRoute: MyApp.globalGenerateRoute,
        debugShowCheckedModeBanner: false,
        supportedLocales: [
          Locale('en', 'US'),
        ],
        localizationsDelegates: [
          // A class which loads the translations from JSON files
          AppLocalizations.delegate,
          // Built-in localization of basic text for Material widgets
          GlobalMaterialLocalizations.delegate,
          // Built-in localization for text direction LTR/RTL
          GlobalWidgetsLocalizations.delegate,
        ],
        // Returns a locale which will be used by the app
        localeResolutionCallback: (locale, supportedLocales) {
          // Check if the current device locale is supported
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          // If the locale of the device is not supported, use the first one
          // from the list (English, in this case).
          return supportedLocales.first;
        },
        title: "Flutter base app",
        theme: buildAppTheme(),
        initialRoute: getInitialRoute());
  }

  ///returns initial route based on condition of logged in/out
  String getInitialRoute() {
    // return LoginScreen.routeName;

    if (SharedPrefHelper.instance.isLogIn()) {
      return HomeScreen.routeName;
    } else if (SharedPrefHelper.instance.isRegisteredIn()) {
      return LoginScreen.routeName;
    }

    return RegistrationScreen.routeName;
  }
}
