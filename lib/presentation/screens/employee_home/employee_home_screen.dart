import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_modulo/presentation/screens/employee/employee_inventory_screen.dart';
import 'package:proyecto_modulo/presentation/screens/employee_sales/employee_sales_screen.dart';
import 'package:proyecto_modulo/presentation/screens/profile/profile_screen.dart';
import '../../modules/employee_home/employee_home_cubit.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  static const routeName = '/employee-home';

  final List<Widget> _pages = const [
    EmployeeInventoryScreen(),
    EmployeeSalesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmployeeHomeCubit(),
      child: BlocBuilder<EmployeeHomeCubit, int>(
        builder: (context, currentIndex) {
          final cubit = context.read<EmployeeHomeCubit>();
          return Scaffold(
            body: _pages[currentIndex],
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
