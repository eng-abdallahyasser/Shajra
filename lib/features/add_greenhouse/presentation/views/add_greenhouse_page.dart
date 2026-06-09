import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_greenhouse_controller.dart';
import 'steps/step_one_view.dart';
import 'steps/step_three_view.dart';
import 'steps/step_two_view.dart';

/// Main page hosting the three-step greenhouse creation wizard.
class AddGreenhousePage extends GetView<AddGreenhouseController> {
  const AddGreenhousePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FCED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FCED),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: const Color(0xFF171D14),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // PageView with the three steps
          Expanded(
            child: PageView(
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                StepOneView(),
                StepTwoView(),
                StepThreeView(),
              ],
            ),
          ),

          // Bottom footer
          _WizardFooter(),
        ],
      ),
    );
  }
}

/// Footer with Cancel, Back, and Next/Submit buttons matching the design.
class _WizardFooter extends GetView<AddGreenhouseController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFC0C9BB)),
        ),
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Cancel button
            TextButton(
              onPressed: controller.cancel,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 34.5,
                  vertical: 12,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: Color(0xFF00450D),
                ),
              ),
            ),
            // Back + Next buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Back button (always visible per design)
                OutlinedButton(
                  onPressed: controller.isFirstStep
                      ? null
                      : controller.previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 27.5,
                    ),
                    minimumSize: const Size(92, 72),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(
                      color: controller.isFirstStep
                          ? const Color(0xFFDEE5D6)
                          : const Color(0xFFC0C9BB),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.6,
                      color: controller.isFirstStep
                          ? const Color(0xFFDEE5D6)
                          : const Color(0xFF41493E),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Next / Submit button
                _NextButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Next (step 1-2) or Submit (step 3) button.
class _NextButton extends GetView<AddGreenhouseController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final isLast = controller.isLastStep;
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF00450D),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0x1A000000),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0x1A000000),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.isSubmitting.value
                  ? null
                  : (isLast ? controller.submit : controller.nextStep),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLast ? 32 : 40,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLast ? 'Submit' : 'Next',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.6,
                        color: Colors.white,
                      ),
                    ),
                    if (!isLast) ...[
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: Colors.white,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
