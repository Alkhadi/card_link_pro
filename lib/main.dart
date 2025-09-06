import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'screens/edit_profile_screen.dart';
import 'screens/profile_screen.dart';
import 'services/profile_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await ProfileStore.ensureReady();
  runApp(CardLinkApp(store: store));
}

class CardLinkApp extends StatelessWidget {
  const CardLinkApp({super.key, required this.store});

  final ProfileStore store;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: store,
      child: MaterialApp(
        title: 'CardLink Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF111827),
          scaffoldBackgroundColor: Colors.black,
          textTheme: GoogleFonts.montserratTextTheme().apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
          useMaterial3: true,
        ),
        routes: {
          '/': (_) => const ProfileScreen(),
          '/edit': (_) => const EditProfileScreen(),
        },
      ),
    );
  }
}
