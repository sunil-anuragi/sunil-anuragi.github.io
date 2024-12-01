import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mac Dock Simulation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MacDock(),
    );
  }
}

class MacDock extends StatefulWidget {
  const MacDock({super.key});

  @override
  _MacDockState createState() => _MacDockState();
}

class _MacDockState extends State<MacDock> {
  final List<IconData> apps = [
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.photo,
    Icons.music_note,
    Icons.settings,
    Icons.map,
  ];
  int? hoveredIndex; // Tracks the index of the icon being hovered
  IconData? draggingApp; // The app currently being dragged

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: const EdgeInsets.only(bottom: 10),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical:  20, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black45,
              //     blurRadius: 15,
              //     offset: Offset(0, 5),
              //   ),
              // ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: apps.asMap().entries.map((entry) {
                final index = entry.key;
                final app = entry.value;

                return DragTarget<IconData>(
                  onAccept: (draggedApp) {
                    setState(() {
                      final oldIndex = apps.indexOf(draggedApp);
                      apps.removeAt(oldIndex);
                      apps.insert(index, draggedApp);
                    });
                  },
                  onWillAccept: (data) => data != app,
                  builder: (context, candidateData, rejectedData) {
                    return Draggable<IconData>(
                      data: app,
                      onDragStarted: () => setState(() => draggingApp = app),
                      onDragCompleted: () => setState(() => draggingApp = null),
                      onDraggableCanceled: (_, __) =>
                          setState(() => draggingApp = null),
                      feedback: _buildAppIcon(app, isDragging: true),
                      childWhenDragging: const SizedBox(
                        width: 0,
                        height: 0,
                      ),
                      child: MouseRegion(
                        onEnter: (_) => setState(() => hoveredIndex = index),
                        onExit: (_) => setState(() => hoveredIndex = null),
                        child: _buildAppIcon(
                          app,
                          isHovered: hoveredIndex == index,
                          isDragging: draggingApp == app,
                          hoverScale: _calculateScale(index),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateScale(int index) {
    if (hoveredIndex == null) return 1.0;

    // Larger scale for the hovered icon and smaller increments for neighbors
    final distance = (hoveredIndex! - index).abs();
    if (distance == 0) return 1.5;
    if (distance == 1) return 1.3;
    if (distance == 2) return 1.1;

    return 1.0;
  }

  Widget _buildAppIcon(IconData app,
      {bool isHovered = false,
      bool isDragging = false,
      double hoverScale = 1.0}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 1.0, end: hoverScale),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height:isDragging ?80: 50,
              width: isDragging ?80 :50,
              decoration: BoxDecoration(
                color:  Colors.primaries[app.hashCode % Colors.primaries.length],
                borderRadius: BorderRadius.circular(8),
                boxShadow: isHovered || isDragging
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                app,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        );
      },
    );
  }
}
