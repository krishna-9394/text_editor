import 'package:flutter/material.dart';

void main() => runApp(TextEditorApp());

class TextEditorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TextEditorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TextEditorScreen extends StatefulWidget {
  @override
  _TextEditorScreenState createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  String? addedText;
  double fontSize = 16;
  String fontFamily = 'Roboto';
  bool isBold = false;
  bool isUnderlined = false;
  Offset textPosition = Offset(100, 100);

  List<Map<String, dynamic>> history = [];
  int historyIndex = -1;

  TextEditingController textController = TextEditingController();

  void addText() {
    if (addedText == null && textController.text.isNotEmpty) {
      setState(() {
        addedText = textController.text;
        saveState();
        textController.clear();
      });
    }
  }

  void deleteText() {
    setState(() {
      addedText = null;
      saveState();
    });
  }

  void updateTextProperties({
    double? newFontSize,
    String? newFontFamily,
    bool? newBold,
    bool? newUnderlined,
  }) {
    setState(() {
      if (newFontSize != null) fontSize = newFontSize;
      if (newFontFamily != null) fontFamily = newFontFamily;
      if (newBold != null) isBold = newBold;
      if (newUnderlined != null) isUnderlined = newUnderlined;
      saveState();
    });
  }

  void moveText(Offset delta) {
    if (addedText != null) {
      setState(() {
        textPosition += delta;
        saveState();
      });
    }
  }

  void saveState() {
    if (historyIndex < history.length - 1) {
      history = history.sublist(0, historyIndex + 1);
    }
    history.add({
      'addedText': addedText,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'isBold': isBold,
      'isUnderlined': isUnderlined,
      'textPosition': textPosition,
    });
    historyIndex++;
  }

  void undo() {
    if (historyIndex > 0) {
      historyIndex--;
      loadState();
    }
  }

  void redo() {
    if (historyIndex < history.length - 1) {
      historyIndex++;
      loadState();
    }
  }

  void loadState() {
    final state = history[historyIndex];
    setState(() {
      addedText = state['addedText'];
      fontSize = state['fontSize'];
      fontFamily = state['fontFamily'];
      isBold = state['isBold'];
      isUnderlined = state['isUnderlined'];
      textPosition = state['textPosition'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Text Editor"),
        actions: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: historyIndex > 0 ? undo : null,
          ),
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: historyIndex < history.length - 1 ? redo : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              moveText(details.delta);
            },
            child: Container(
              color: Colors.grey[200],
              child: addedText != null
                  ? Stack(
                      children: [
                        Positioned(
                          left: textPosition.dx,
                          top: textPosition.dy,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              moveText(details.delta);
                            },
                            child: Text(
                              addedText!,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontFamily: fontFamily,
                                fontWeight: isBold
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                decoration: isUnderlined
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: 'Enter text',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: addText,
                        child: Text("Add Text"),
                      ),
                      if (addedText != null) SizedBox(width: 10),
                      if (addedText != null)
                        ElevatedButton(
                          onPressed: deleteText,
                          child: Text("Delete"),
                        ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Font Size"),
                            Slider(
                              value: fontSize,
                              min: 12,
                              max: 48,
                              divisions: 36,
                              label: fontSize.round().toString(),
                              onChanged: (value) {
                                updateTextProperties(newFontSize: value);
                              },
                            ),
                          ],
                        ),
                      ),
                      DropdownButton<String>(
                        value: fontFamily,
                        items: ['Roboto', 'Arial', 'Georgia', 'Courier']
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (value) {
                          updateTextProperties(newFontFamily: value!);
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.format_bold,
                          color: isBold ? Colors.blue : Colors.black,
                        ),
                        onPressed: () {
                          updateTextProperties(newBold: !isBold);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.format_underline,
                          color: isUnderlined ? Colors.blue : Colors.black,
                        ),
                        onPressed: () {
                          updateTextProperties(newUnderlined: !isUnderlined);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
