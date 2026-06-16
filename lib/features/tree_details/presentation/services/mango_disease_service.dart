import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

/// Result from a model prediction containing the classified disease info.
class PredictionResult {
  /// Index of the predicted class (argmax of output probabilities).
  final int predictedClass;

  /// Confidence score of the predicted class (max probability, 0.0–1.0).
  final double confidence;

  /// Raw probabilities for all 8 classes.
  final List<double> probabilities;

  const PredictionResult({
    required this.predictedClass,
    required this.confidence,
    required this.probabilities,
  });

  /// Whether the model considers this leaf healthy (class 5 = Healthy).
  bool get isHealthy => predictedClass == 5;

  /// Human-readable disease class name.
  String get className {
    switch (predictedClass) {
      case 0:
        return 'Anthracnose';
      case 1:
        return 'Bacterial Canker';
      case 2:
        return 'Cutting Weevil';
      case 3:
        return 'Die Back';
      case 4:
        return 'Gall Midge';
      case 5:
        return 'Healthy';
      case 6:
        return 'Powdery Mildew';
      case 7:
        return 'Sooty Mould';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() =>
      'PredictionResult(class=$predictedClass: $className, confidence=${(confidence * 100).toStringAsFixed(1)}%)';
}

/// Service that loads the TFLite mango disease model and runs inference.
///
/// The model expects a [1, 224, 224, 3] float32 input (RGB, normalized [0,1])
/// and outputs 8 class probabilities [1, 8] (Anthracnose, Bacterial Canker,
/// Cutting Weevil, Die Back, Gall Midge, Healthy, Powdery Mildew, Sooty Mould).
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
      debugPrint('[MangoDiseaseService] Loading model from $_modelPath...');
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _loaded = true;
      debugPrint('[MangoDiseaseService] Model loaded successfully.');

      // Log expected input/output tensor shapes for debugging
      try {
        final inputTensor = _interpreter!.getInputTensors();
        final outputTensor = _interpreter!.getOutputTensors();
        for (var i = 0; i < inputTensor.length; i++) {
          debugPrint('[MangoDiseaseService] Input tensor[$i]: shape=${inputTensor[i].shape}, type=${inputTensor[i].type}');
        }
        for (var i = 0; i < outputTensor.length; i++) {
          debugPrint('[MangoDiseaseService] Output tensor[$i]: shape=${outputTensor[i].shape}, type=${outputTensor[i].type}');
        }
      } catch (e) {
        debugPrint('[MangoDiseaseService] Could not inspect tensors: $e');
      }
    } catch (e, stack) {
      _loaded = false;
      debugPrint('[MangoDiseaseService] Model loading FAILED: $e\n$stack');
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
  /// Returns a [PredictionResult] with the predicted class and confidence.
  /// The model outputs 8 class probabilities [1, 8]: Anthracnose, Bacterial Canker,
  /// Cutting Weevil, Die Back, Gall Midge, Healthy, Powdery Mildew, Sooty Mould.
  Future<PredictionResult> predict(File imageFile) async {
    await _ensureLoaded();

    debugPrint('[MangoDiseaseService] Reading image file: ${imageFile.path}');

    // 1. Decode and resize to 224×224
    final bytes = await imageFile.readAsBytes();
    debugPrint('[MangoDiseaseService] Image bytes read: ${bytes.length} bytes');

    final image = img.decodeImage(bytes);
    if (image == null) {
      debugPrint('[MangoDiseaseService] FAILED to decode image');
      throw Exception('Failed to decode image');
    }
    debugPrint('[MangoDiseaseService] Image decoded: ${image.width}x${image.height}');

    final resized = img.copyResize(image, width: 224, height: 224);
    debugPrint('[MangoDiseaseService] Image resized to 224x224');

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

    debugPrint('[MangoDiseaseService] Input tensor prepared [1,224,224,3]');

    // 3. Allocate output buffer — the model outputs 8 class probabilities [1, 8]
    final output = List.filled(1 * 8, 0.0).reshape([1, 8]);

    // 4. Run inference
    debugPrint('[MangoDiseaseService] Running inference...');
    try {
      _interpreter!.run(input, output);
    } catch (e, stack) {
      debugPrint('[MangoDiseaseService] Inference FAILED: $e\n$stack');
      rethrow;
    }

    // 5. Extract probabilities and determine predicted class
    final probabilities = <double>[
      for (var i = 0; i < output[0].length; i++) output[0][i],
    ];
    var maxProb = probabilities[0];
    var predictedClass = 0;
    for (var i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        predictedClass = i;
      }
    }

    debugPrint('[MangoDiseaseService] Probabilities: $probabilities');
    debugPrint('[MangoDiseaseService] Predicted: class=$predictedClass (confidence=${(maxProb * 100).toStringAsFixed(1)}%)');

    return PredictionResult(
      predictedClass: predictedClass,
      confidence: maxProb,
      probabilities: probabilities,
    );
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
