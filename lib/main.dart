import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'dart:js' as js;

void main() {
  configureJsInterop();

  // Register a div container to hold the image
  ui.platformViewRegistry.registerViewFactory(
    'img-view',
        (int viewId) {
      final div = html.DivElement()
        ..id = 'image-container'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = '#cccccc' // Grey background
        ..style.borderRadius = '12px'
        ..style.display = 'flex'
        ..style.justifyContent = 'center'
        ..style.alignItems = 'center';

      return div;
    },
  );

  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: const HomePage());
  }
}

/// [Widget] displaying the home page consisting of an image and buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String imageUrl = '';
  OverlayEntry? overlayEntry;

  /// Toggles the context menu
  void toggleMenu(BuildContext context) {
    if (overlayEntry == null) {
      showMenuOverlay(context);
    } else {
      closeMenuOverlay();
    }
  }

  /// Displays the floating menu using Overlay
  void showMenuOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayState = overlay.context.findRenderObject() as RenderBox?;
    final size = overlayState?.size ?? Size.zero;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Dimmed background
            GestureDetector(
              onTap: closeMenuOverlay, // Close menu on tap outside
              child: Container(
                width: size.width,
                height: size.height,
                color: Colors.black54,
              ),
            ),
            // Menu above FAB
            Positioned(
              bottom: 80, // Adjust this to position correctly
              right: 24,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildMenuItem("Enter Fullscreen", Icons.fullscreen, () {
                      js.context.callMethod('enterFullScreen');
                      closeMenuOverlay();
                    }),
                    _buildMenuItem("Exit Fullscreen", Icons.fullscreen_exit, () {
                      js.context.callMethod('exitFullScreen');
                      closeMenuOverlay();
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(overlayEntry!);
  }

  /// Closes the floating menu
  void closeMenuOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  /// Builds each menu item
  Widget _buildMenuItem(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  final doc = html.document;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: GestureDetector(
                onDoubleTap: (){

                  if(imageUrl.isNotEmpty){
                    if(html.document.fullscreenElement != null){
                      html.document.exitFullscreen();
                    } else{
                      html.document.documentElement?.requestFullscreen();
                    }
                  }
                },
                child: AspectRatio(
                  aspectRatio: 1,
                  child: HtmlElementView(viewType: 'img-view'),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(hintText: 'Image URL'),
                    onChanged: (value) => setState(() => imageUrl = value),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (imageUrl.isNotEmpty) {
                      js.context.callMethod('updateImage', [imageUrl]);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                    child: Icon(Icons.arrow_forward),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => toggleMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// JavaScript functions to handle image rendering and fullscreen.
void configureJsInterop() {
  js.context['updateImage'] = (String url) {
    final imgElement = html.ImageElement()
      ..src = url
      ..style.maxWidth = '100%'
      ..style.maxHeight = '100%'
      ..style.objectFit = 'contain'
      ..style.borderRadius = '12px';

    final container = html.document.getElementById('image-container');
    if (container != null) {
      container.innerHtml = ''; // Clear previous image
      container.append(imgElement);
    } else {
      debugPrint("Error: image-container div not found");
    }
  };

  js.context['enterFullScreen'] = () {
    final doc = html.document.documentElement;
    if (doc != null) {
      doc.requestFullscreen();
    }
  };

  js.context['exitFullScreen'] = () {
    if (html.document.fullscreenElement != null) {
      html.document.exitFullscreen();
    }
  };
}
