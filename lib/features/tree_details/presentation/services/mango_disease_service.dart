import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

/// Service that loads the TFLite mango disease model and runs inference.
///
/// The model expects a [1, 224, 224, 3] float32 input (RGB, normalized [0,1])
/// and outputs a sigmoid score [1, 1] where ≥0.5 indicates disease detected.
class MangoDiseaseService {
  static const String _modelPath = 'assets/ai_models/mango_disease_model.tflite';

  Interpreter? _interpreter;
  bool _loaded = false;

  /// Whether the model has been loaded successfully.
  bool get isLoaded => _loaded;

  /// Load the TFLite interpreter from the bundled asset.
  Future<void> loadModel() async {
    if (_loaded) return;
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _loaded = true;
    } catch (e) {
      _loaded = false;
      rethrow;
    }
  }

  /// Unload the interpreter to free resources.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _loaded = false;
  }

  /// Run inference on a leaf image file.
  ///
  /// Returns a confidence score in [0.0, 1.0] where values ≥ 0.5
  /// indicate disease is likely present.
  Future<double> predict(File imageFile) async {
    await _ensureLoaded();

    // 1. Decode and resize to 224×224
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    final resized = img.copyResize(image, width: 224, height: 224);

    // 2. Convert to float32 tensor [1, 224, 224, 3], normalized to [0, 1]
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    // 3. Allocate output buffer — the model outputs a single sigmoid value
    final output = List.filled(1 * 1, 0.0).reshape([1, 1]);

    // 4. Run inference
    _interpreter!.run(input, output);

    // 5. Return the sigmoid probability
    return output[0][0];
  }

  /// Ensure the model is loaded before inference.
  Future<void> _ensureLoaded() async {
    if (!_loaded) {
      await loadModel();
    }
  }

  /// Singleton access pattern.
  static final MangoDiseaseService instance = MangoDiseaseService._();
  MangoDiseaseService._();
}
