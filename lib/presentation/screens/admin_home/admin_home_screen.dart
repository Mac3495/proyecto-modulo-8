import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_modulo/presentation/screens/employees/employee_screen.dart';
import 'package:proyecto_modulo/presentation/screens/inventory/inventory_screen.dart';
import 'package:proyecto_modulo/presentation/screens/profile/profile_screen.dart';
import 'package:proyecto_modulo/presentation/screens/sales/sales_screen.dart';
import 'package:proyecto_modulo/presentation/screens/subsidiaries/subsidiary_screen.dart';
import 'package:proyecto_modulo/presentation/modules/subsidiaries/subsidiary_bloc.dart';
import 'package:proyecto_modulo/presentation/modules/subsidiaries/subsidiary_event.dart';
import '../../modules/admin_home/admin_home_cubit.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  static const routeName = '/admin-home';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminHomeCubit(),
      child: BlocBuilder<AdminHomeCubit, int>(
        builder: (context, currentIndex) {
          final cubit = context.read<AdminHomeCubit>();

          // 🔹 En lugar de tener _pages estático, lo construimos dinámico:
          Widget currentPage;
          switch (currentIndex) {
            case 0:
              currentPage = const InventoryScreen();
              break;
            case 1:
              // 👉 Aquí inyectamos el BlocProvider correctamente
              currentPage = BlocProvider(
                create: (_) => SubsidiaryBloc()..add(LoadSubsidiaries()),
                child: const SubsidiaryScreen(),
              );
              break;
            case 2:
              currentPage = const EmployeeScreen();
              break;
            case 3:
              currentPage = const SalesScreen();
              break;
            case 4:
              currentPage = const ProfileScreen();
              break;
            default:
              currentPage = const InventoryScreen();
          }

          return Scaffold(
            body: currentPage,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: cubit.changeTab,
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  label: 'Inventario',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store_mall_directory_outlined),
                  label: 'Sucursales',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt_outlined),
                  label: 'Empleados',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.point_of_sale_outlined),
                  label: 'Ventas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Perfil',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
