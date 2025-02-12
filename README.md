# Neural Effect

A Flutter widget for an animated 3D particle background effect.

## Features

- Dynamic 3D particle animation
- Customizable rotation and speed
- Engaging and interactive background effect
- Easy integration: simply wrap your content with the provided widget

## Installation

To add Neural Effect to your project, add the dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  neural_effect: ^1.0.1
```

Then, run:

```bash
flutter pub get
```

## Usage

Wrap your content with the `NeuralEffect` widget to display an animated 3D particle background:

```dart
import 'package:flutter/material.dart';
import 'package:neural_effect/neural_effect.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: NeuralEffect(
        child: Center(
          child: Text(
            'Hello, Neural Effect!',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    ),
  ));
}
```

## Customization

The Neural Effect package allows for further customization. For example:

- Adjust the particle speed, size, and connections by modifying the source in `lib/neural_effect.dart`.
- Modify rotation parameters based on user input for interactive effects.

Explore the code to tweak the behavior to suit your design needs.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests for bugs, feature requests, or improvements.

## License

This project is licensed under the MIT License.
