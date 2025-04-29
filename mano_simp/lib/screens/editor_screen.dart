import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mano_simp/providers/editor_provider.dart';
import 'package:mano_simp/config/theme_config.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editorProvider = Provider.of<EditorProvider>(context);
    final editorConfig =
        ThemeConfig.config['layout']['screens']['Editor']['console'];
    final runButtonConfig =
        ThemeConfig.config['layout']['screens']['Editor']['runButton'];

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Code editor
              Container(
                width: editorConfig['w'].toDouble(),
                height: editorConfig['h'].toDouble(),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: editorProvider.codeController,
                  style: TextStyle(
                    fontFamily: ThemeConfig.config['theme']['fontFamilyMono'],
                    fontSize: editorConfig['fontSize'].toDouble(),
                  ),
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8.0),
                    hintText: 'Enter Mano assembly code here...',
                  ),
                  onChanged: (_) => editorProvider.updateCode(),
                ),
              ),

              // Error messages
              if (editorProvider.errors.isNotEmpty)
                Container(
                  width: editorConfig['w'].toDouble(),
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(top: 8.0),
                  decoration: BoxDecoration(
                    color: ThemeConfig.getColorFromHex(
                            ThemeConfig.config['theme']['errorColor'])
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: editorProvider.errors
                        .map((error) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                error,
                                style: TextStyle(
                                  color: ThemeConfig.getColorFromHex(ThemeConfig
                                      .config['theme']['errorColor']),
                                  fontSize: 12.0,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),

              // Run button
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: runButtonConfig['w'].toDouble(),
                  height: runButtonConfig['h'].toDouble(),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.getColorFromHex(
                          ThemeConfig.config['theme']['primaryColor']),
                    ),
                    onPressed: () => editorProvider.runCode(context),
                    child: Text(
                      runButtonConfig['text'],
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
              ),

              // Sample code button (for easy testing)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton(
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
                  child: const Text('Load Sample Code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
