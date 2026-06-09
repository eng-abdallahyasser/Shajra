import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/add_greenhouse_controller.dart';

/// Step 1 — Define the greenhouse: name, facility type, orientation, dimensions.
class StepOneView extends GetView<AddGreenhouseController> {
  const StepOneView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          // ---- Wizard Progress Bar ----
          _ProgressHeader(),
          const SizedBox(height: 32),
          // ---- Header Section ----
          _HeaderSection(),
          const SizedBox(height: 24),
          // ---- Facility Visualization Card ----
          _FacilityCard(),
          const SizedBox(height: 32),
          // ---- Form Fields ----
          _GreenhouseForm(),
          const SizedBox(height: 24),
          // ---- Descriptive Note Card ----
          _InfoNoteCard(),
        ],
      ),
    );
  }
}

/// Progress bar showing step labels and a 3-segment bar.
class _ProgressHeader extends GetView<AddGreenhouseController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP 0${controller.currentStep.value + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: Color(0xFF00450D),
                ),
              ),
              Text(
                controller.currentStepLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: Color(0xFF41493E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 3-segment progress bar
          SizedBox(
            height: 8,
            child: Row(
              children: List.generate(3, (i) {
                final isFilled = i <= controller.currentStep.value;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: i > 0 ? 4 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: isFilled
                          ? const Color(0xFF00450D)
                          : const Color(0xFFDEE5D6),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// "New Greenhouse Setup" heading + subtitle.
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Greenhouse Setup',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 32,
            letterSpacing: -0.64,
            color: Color(0xFF171D14),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Configure the core physical parameters of your growing environment to enable high-precision climate monitoring.',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 24 / 16,
            color: Color(0xFF41493E),
          ),
        ),
      ],
    );
  }
}

/// Facility visualization card with greenhouse image placeholder.
class _FacilityCard extends StatelessWidget {
  const _FacilityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 192,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFC0C9BB)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Image placeholder with gradient overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE9F0E1),
                    Color(0xFFCDE0C0),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.warehouse_rounded,
                  size: 64,
                  color: const Color(0xFF1B5E20).withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
          // Gradient overlay at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(0, 69, 13, 0),
                    Color.fromRGBO(0, 69, 13, 0.4),
                  ],
                ),
              ),
            ),
          ),
          // Badge at bottom-left
          Positioned(
            left: 17,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: const Text(
                'MODERN GREENHOUSE',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: Color(0xFF00450D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Form fields: name, facility type, orientation, dimensions.
class _GreenhouseForm extends GetView<AddGreenhouseController> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greenhouse Name
        _FieldLabel('Greenhouse Name'),
        SizedBox(height: 8),
        _NameField(),
        SizedBox(height: 24),
        // Facility Type
        _FieldLabel('Facility Type'),
        SizedBox(height: 8),
        _FacilityTypeDropdown(),
        SizedBox(height: 24),
        // Solar Orientation
        _FieldLabel('Solar Orientation'),
        SizedBox(height: 8),
        _SolarOrientationDropdown(),
        SizedBox(height: 24),
        // Dimensions
        _FieldLabel('Dimensions (Meters)'),
        SizedBox(height: 8),
        _DimensionFields(),
      ],
    );
  }
}

/// Bold uppercase label for a form field.
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 0.6,
        color: Color(0xFF41493E),
      ),
    );
  }
}

/// Greenhouse name text input.
class _NameField extends GetView<AddGreenhouseController> {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49,
      child: TextField(
        controller: controller.nameController,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: Color(0xFF171D14),
        ),
        decoration: const InputDecoration(
          hintText: 'e.g. North Sector Glasshouse A',
          hintStyle: TextStyle(color: Color(0xFF6B7280)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Color(0xFFC0C9BB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Color(0xFFC0C9BB)),
          ),
        ),
      ),
    );
  }
}

/// Facility type dropdown.
class _FacilityTypeDropdown extends GetView<AddGreenhouseController> {
  const _FacilityTypeDropdown();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropdownField(
        value: controller.selectedFacilityType.value.isEmpty
            ? null
            : controller.selectedFacilityType.value,
        hint: 'Glasshouse',
        items: AddGreenhouseController.facilityTypes,
        onChanged: (v) => controller.selectedFacilityType.value = v,
      ),
    );
  }
}

/// Solar orientation dropdown.
class _SolarOrientationDropdown extends GetView<AddGreenhouseController> {
  const _SolarOrientationDropdown();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropdownField(
        value: controller.selectedSolarOrientation.value.isEmpty
            ? null
            : controller.selectedSolarOrientation.value,
        hint: 'North-South Alignment',
        items: AddGreenhouseController.solarOrientations,
        onChanged: (v) => controller.selectedSolarOrientation.value = v,
      ),
    );
  }
}

/// A styled dropdown button matching the Figma design.
class _DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFC0C9BB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              hint,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xFF171D14),
              ),
            ),
          ),
          isExpanded: true,
          icon: Padding(
            padding: const EdgeInsets.only(right: 9),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: const Color(0xFF6B7280),
              size: 24,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  item,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Color(0xFF171D14),
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

/// Width (W) and Length (L) input fields side by side.
class _DimensionFields extends GetView<AddGreenhouseController> {
  const _DimensionFields();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          // Width
          Expanded(
            child: _DimensionInput(
              prefix: 'W',
              controller: controller.widthController,
            ),
          ),
          const SizedBox(width: 12),
          // Length
          Expanded(
            child: _DimensionInput(
              prefix: 'L',
              controller: controller.lengthController,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single dimension input with a prefix label (W or L).
class _DimensionInput extends StatelessWidget {
  final String prefix;
  final TextEditingController controller;

  const _DimensionInput({
    required this.prefix,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFC0C9BB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Prefix label with divider
          Container(
            width: 40,
            height: 16,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Color(0xFFC0C9BB)),
              ),
            ),
            child: Text(
              prefix,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.6,
                color: Color(0xFF717A6D),
              ),
            ),
          ),
          // Input
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Color(0xFF6B7280),
              ),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Color(0xFF6B7280),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Informational note card with icon and text.
class _InfoNoteCard extends StatelessWidget {
  const _InfoNoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6E7),
        border: Border.all(color: const Color(0xFFBDEFBE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.info_outline,
              size: 20,
              color: const Color(0xFF426E47),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'The facility profile you provide will be used to calibrate the climate model for your specific greenhouse geometry and orientation, ensuring accurate microclimate predictions.',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 20 / 14,
                color: Color(0xFF426E47),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
