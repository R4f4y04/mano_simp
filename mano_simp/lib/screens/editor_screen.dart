import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mano_simp/providers/editor_provider.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editorProvider = Provider.of<EditorProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simple title
              Text(
                'Mano Assembly Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),

              // Code editor
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.white,
                  ),
                  child: TextField(
                    controller: editorProvider.codeController,
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 14,
                    ),
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8.0),
                      hintText: 'Enter Mano assembly code here...',
                    ),
                    onChanged: (_) => editorProvider.updateCode(),
                  ),
                ),
              ),

              // Error messages
              if (editorProvider.errors.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(top: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    border: Border.all(color: Colors.black),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Errors:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      ...editorProvider.errors
                          .map((error) => Text(
                                '• $error',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12.0,
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                ),

              // Controls
              Container(
                margin: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    // Run button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => editorProvider.runCode(context),
                        child: Text('Run'),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Sample code button
                    OutlinedButton(
                      onPressed: () {
                        editorProvider.codeController.text = '''ORG 100
LDA 500
ADD 501
STA 502
HLT
ORG 500
DEC 75
DEC 25
DEC 0
END''';
                        editorProvider.updateCode();
                      },
                      child: Text('Sample Code'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
