import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/main_controller.dart';
import '../utils/app_colors.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();

    return Obx(
      () => Container(
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
                    assetIconPath: 'assets/icons/home/Home Icon.png',
                    label: 'الرئيسية',
                    index: 0,
                    isSelected: controller.currentIndex.value == 0,
                    onTap: () => controller.changeTab(0),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    assetIconPath: 'assets/icons/home/Category Icon.png',
                    label: 'الاختصاصات',
                    index: 1,
                    isSelected: controller.currentIndex.value == 1,
                    onTap: () => controller.changeTab(1),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    assetIconPath: 'assets/icons/home/statistics_page_icon.png',
                    label: 'الاحصائيات',
                    index: 2,
                    isSelected: controller.currentIndex.value == 2,
                    onTap: () => controller.changeTab(2),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    assetIconPath: 'assets/icons/home/Setting Icon.png',
                    label: 'الإعدادات',
                    index: 3,
                    isSelected: controller.currentIndex.value == 3,
                    onTap: () => controller.changeTab(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    IconData? icon,
    String? assetIconPath,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: isSelected ? 1.0 : 0.45,
              child: assetIconPath != null
                  ? Image.asset(
                      assetIconPath,
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                    )
                  : Icon(icon, color: AppColors.bottomNavUnselected, size: 34),
            ),
          ],
        ),
      ),
    );
  }
}
