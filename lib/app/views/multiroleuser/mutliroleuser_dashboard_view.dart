import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/custome_widgets/app_language_switcher.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class MultiRoleUserDashboardView extends StatefulWidget {
  const MultiRoleUserDashboardView({super.key});

  @override
  State<MultiRoleUserDashboardView> createState() =>
      _MultiRoleUserDashboardViewState();
}

class _MultiRoleUserDashboardViewState
    extends State<MultiRoleUserDashboardView> {
  String? selectedRoleName;
  List<String> _roleNames = [];

  @override
  void initState() {
    super.initState();
    _roleNames = _readRoleNames(Get.arguments);
    if (_roleNames.isEmpty) {
      _loadSavedRoleNames();
    }
  }

  List<String> _readRoleNames(dynamic arguments) {
    final dynamic roleNames = arguments is Map ? arguments["roleNames"] : null;
    if (roleNames is! List) return [];
    return roleNames
        .map((value) => value?.toString().trim() ?? "")
        .where((value) => value.isNotEmpty)
        .toList();
  }

  Future<void> _loadSavedRoleNames() async {
    final roleNames = await SharedPrefsHelper.getList("roleNames");
    if (!mounted || roleNames.isEmpty) return;
    setState(() {
      _roleNames = roleNames;
    });
  }

  List<_RoleModule> get availableModules {
    final modules = <_RoleModule>[];
    for (final roleName in _roleNames) {
      final module = _RoleModule.fromRoleName(roleName);
      if (module != null) modules.add(module);
    }
    return modules;
  }

  Future<void> accessSelectedModule() async {
    final modules = availableModules;
    _RoleModule? selectedModule;
    for (final module in modules) {
      if (module.roleName == selectedRoleName) {
        selectedModule = module;
        break;
      }
    }
    if (selectedModule == null) {
      errorToast("Please select a module.".tr);
      return;
    }

    await SharedPrefsHelper.setString("roleName", selectedModule.roleName);
    Get.toNamed(selectedModule.route);
  }

  @override
  Widget build(BuildContext context) {
    final modules = availableModules;
    final arguments = Get.arguments;
    final fullName =
        arguments is Map ? arguments["fullName"]?.toString() ?? "" : "";

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: Text(
          "Multi Role User Dashboard".tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: const [AppLanguageSwitcher()],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.dashboard_customize_outlined,
                    color: Colors.blue,
                    size: 72,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    fullName.isEmpty
                        ? "Choose a module to continue".tr
                        : "${"Welcome".tr}, $fullName",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Select the module you want to access.".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 32),
                  DropdownButtonFormField<String>(
                    initialValue: modules.any(
                      (module) => module.roleName == selectedRoleName,
                    )
                        ? selectedRoleName
                        : null,
                    decoration: InputDecoration(
                      labelText: "Module".tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    hint: Text("Select a module".tr),
                    items: modules
                        .map(
                          (module) => DropdownMenuItem<String>(
                            value: module.roleName,
                            child: Text(module.roleName.tr),
                          ),
                        )
                        .toList(),
                    onChanged: modules.isEmpty
                        ? null
                        : (value) => setState(() {
                              selectedRoleName = value;
                            }),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: modules.isEmpty ? null : accessSelectedModule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Access Module".tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (modules.isEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      "No supported modules were found for this account.".tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleModule {
  const _RoleModule({
    required this.roleName,
    required this.route,
  });

  final String roleName;
  final String route;

  static _RoleModule? fromRoleName(String roleName) {
    final normalizedRole =
        roleName.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]"), "");
    if (normalizedRole.contains("security") ||
        normalizedRole.contains("guard")) {
      return _RoleModule(
        roleName: roleName,
        route: Routes.securityDashboard,
      );
    }
    if (normalizedRole.contains("warden")) {
      return _RoleModule(
        roleName: roleName,
        route: Routes.WARDEN_ATTENDANCE,
      );
    }
    if (normalizedRole.contains("teacher") ||
        normalizedRole.contains("lecturer")) {
      return _RoleModule(
        roleName: roleName,
        route: Routes.dashboard,
      );
    }
    if (normalizedRole.contains("student")) {
      return _RoleModule(
        roleName: roleName,
        route: Routes.dashboard,
      );
    }
    if (normalizedRole.contains("kitchen")) {
      return _RoleModule(
        roleName: roleName,
        route: Routes.kitchenDashboard,
      );
    }
    if (normalizedRole.contains("masjid") &&
        normalizedRole.contains("incharge")) {
      return _RoleModule(
        roleName: roleName,
        route: Routes.masjidDashboard,
      );
    }
    if (normalizedRole.contains("sponsor")) {
      return _RoleModule(
        roleName: roleName,
        route: Routes.sponsorDashboard,
      );
    }
    return null;
  }
}
