import 'package:flutter/material.dart';
import 'package:internalsystem/constants/constants.dart';
import 'package:internalsystem/data/side_menu_data.dart';
import 'package:internalsystem/utils/navigation_utils.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideMenuWidget extends StatefulWidget {
  const SideMenuWidget({super.key});

  @override
  State<SideMenuWidget> createState() => _SideMenuWidgetState();
}

class _SideMenuWidgetState extends State<SideMenuWidget> {
  int selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredMenuOptions = [];
  

  @override
  void initState() {
    super.initState();
    _loadSelectedIndex();
    _filteredMenuOptions = SideMenuData().allMenuOptions;
    _searchController.addListener(_filterMenuOptions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedIndex = prefs.getInt('selectedIndex') ?? 0;
    });
  }

  void _filterMenuOptions() {
    setState(() {
      _filteredMenuOptions = SideMenuData().allMenuOptions.where((option) {
        return option['text']
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Container(
      color: menuColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
              ),
            ),
          ),
          const Divider(
            color: Colors.grey,
            height: 1,
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              height: 44,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                        left: 17.5,
                        right: 15),
                    child: Icon(MdiIcons.magnify, size: 19.5, color: Colors.white,),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: textFieldColor, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: textFieldColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.white38, width: 2),
                  ),
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, // Centraliza verticalmente o texto
                    horizontal: 15, // Adiciona margem do lado esquerdo do texto
                  ),
                ),
                style: const TextStyle(color: textFieldColor),
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _filteredMenuOptions.map((option) {
                  return buttonDefault(
                    text: option['text']!,
                    icon: option['icon']!,
                    route: option['route']!,
                    currentRoute: currentRoute,
                    onClick: () {
                      if (option['route'] != currentRoute) {
                        navigateTo(option['route']!, context);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget buttonDefault({
    required String text,
    required IconData icon,
    required String route,
    required String? currentRoute,
    VoidCallback? onClick,
  }) {
    final isSelected = route == currentRoute;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: isSelected ? Colors.white : Colors.transparent,
            overlayColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: TextStyle(
              fontSize: 15,
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
          onPressed: onClick,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 5),
              Icon(icon,
                  color: isSelected ? Colors.black : Colors.white, size: 20),
              const SizedBox(width: 15),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
