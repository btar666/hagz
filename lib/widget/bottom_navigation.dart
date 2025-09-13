import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/main_controller.dart';
import '../utils/app_colors.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();
    
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildNavItem(
                  icon: Icons.local_hospital,
                  label: 'الرئيسية',
                  index: 0,
                  isSelected: controller.currentIndex.value == 0,
                  onTap: () => controller.changeTab(0),
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.medical_services,
                  label: 'الاختصاصات',
                  index: 1,
                  isSelected: controller.currentIndex.value == 1,
                  onTap: () => controller.changeTab(1),
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.settings,
                  label: 'الإعدادات',
                  index: 2,
                  isSelected: controller.currentIndex.value == 2,
                  onTap: () => controller.changeTab(2),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: isSelected
              ? BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? Colors.white 
                    : AppColors.bottomNavUnselected,
                size: 22,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : AppColors.bottomNavUnselected,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
