import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/helper/permissions.dart';
import 'package:fitness_zone_2/theme/app_colors.dart';
import 'package:fitness_zone_2/theme/app_shadows.dart';
import 'package:fitness_zone_2/theme/app_typography.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/design_system/design_system.dart';
/// Payment slip upload (1P5) — inline validation, no toast for missing image.
class UploadSlipScreen extends StatefulWidget {
  const UploadSlipScreen({
    super.key,
    required this.planId,
    required this.durationId,
    required this.price,
  });

  final String planId;
  final String price;
  final int durationId;

  @override
  State<UploadSlipScreen> createState() => _UploadSlipScreenState();
}

class _UploadSlipScreenState extends State<UploadSlipScreen> {
  final HomeController _homeController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey _uploadAreaKey = GlobalKey();

  bool _submitting = false;
  bool _pickerOpen = false;
  String? _slipError;

  @override
  Widget build(BuildContext context) {
    fhSetLightStatusBar();
    return FhScaffold(
      softBrandBackground: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.brandSoftBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            _homeController.planPicture = null;
            _homeController.update();
            Get.back();
          },
        ),
        title: Text('Upload slip', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth > 520 ? 520.0 : constraints.maxWidth;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Upload your payment receipt',
                        style: AppTypography.h3.copyWith(
                          color: AppColors.brandTextDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Snap or pick a clear photo of your transfer or deposit slip. '
                        'Our team verifies it within a few hours.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.brandTextMuted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: GetBuilder<HomeController>(builder: (cont) {
                          final picked = cont.planPicture;
                          return FormField<void>(
                            key: _uploadAreaKey,
                            validator: (_) {
                              if (_pickerOpen) return null;
                              if (cont.planPicture == null) {
                                return 'Please add a photo of your payment slip';
                              }
                              return null;
                            },
                            builder: (field) {
                              final showError =
                                  field.hasError || _slipError != null;
                              final errorText =
                                  field.errorText ?? _slipError;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _selectMediaBottomSheet(context),
                                      child: Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: showError
                                                ? AppColors.error
                                                : AppColors.surfaceBorder,
                                            width: showError ? 1.5 : 1,
                                          ),
                                          boxShadow: AppShadows.sm,
                                        ),
                                        child: picked != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.file(
                                                  File(picked.path),
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 72,
                                                    height: 72,
                                                    alignment: Alignment.center,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Color(0xFFF6FBF3),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: SizedBox(
                                                      width: 32,
                                                      height: 32,
                                                      child: SvgPicture.asset(
                                                          MyImgs.upload),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'Tap to upload slip',
                                                    style: AppTypography.body
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors
                                                          .brandTextDark,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'JPG or PNG, up to 5 MB',
                                                    style: AppTypography
                                                        .labelSmall
                                                        .copyWith(
                                                      color: AppColors
                                                          .brandTextMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                  if (errorText != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      errorText,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      FhButton(
                        label: 'Upload payment slip',
                        loading: _submitting,
                        onPressed: _submitSlip,
                      ),
                      const SizedBox(height: 8),
                      FhButton(
                        label: 'Back',
                        variant: FhButtonVariant.ghost,
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submitSlip() async {
    setState(() => _slipError = null);
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      final ctx = _uploadAreaKey.currentContext;
      if (ctx != null) {
        await Scrollable.ensureVisible(ctx, alignment: 0.2);
      }
      return;
    }
    if (_homeController.planPicture == null) return;

    setState(() => _submitting = true);
    try {
      final success = await _homeController.addPlanBuyImage(
        widget.planId,
        widget.durationId,
        widget.price,
      );
      if (!mounted) return;
      if (success) {
        await FhDialog.showSuccess(
          title: 'Successfully uploaded',
          message:
              'Our team is reviewing your payment. You will receive a confirmation '
              'when your plan is active.',
          onClose: () {
            Get.back();
            Get.back();
          },
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _selectMediaBottomSheet(BuildContext context) {
    FhBottomSheet.show(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _sourceTile(
              icon: Icons.photo_camera_outlined,
              label: 'Camera',
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            _sourceTile(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF6FBF3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 26, color: AppColors.brandPrimaryButton),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTypography.label),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _pickerOpen = true;
      _slipError = null;
    });
    try {
      final granted = source == ImageSource.camera
          ? await PermissionOfPhotos().getFromCamera(context)
          : await PermissionOfPhotos().getFromGallery(context);
      if (!granted) return;

      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;

      final dir = Directory.systemTemp;
      final targetPath =
          "${dir.absolute.path}/dp${Get.find<AuthController>().i}.jpg";
      final compressed = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        quality: 60,
      );
      if (compressed == null) {
        setState(() {
          _slipError = 'Could not process this image. Try another photo.';
        });
        return;
      }
      _homeController.planPicture = XFile(compressed.path);
      _homeController.update();
      Get.find<AuthController>().i++;
      Get.find<AuthController>().update();
      _formKey.currentState?.validate();
    } finally {
      if (mounted) setState(() => _pickerOpen = false);
    }
  }
}
