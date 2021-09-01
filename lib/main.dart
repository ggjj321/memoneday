import 'package:flutter/material.dart';

int taskNum = 0;
var wardList = [];

void main() => runApp(const MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatelessWidget(),
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget {
  const MyStatelessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyStatefulWidget();
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    myController.addListener(_printLatestValue);
  }

  void _printLatestValue() {
    print('Second text field: ${myController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('備忘錄'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3,
        children: List.generate(taskNum, (idx) {
          return Card(
              child: Container(
                  alignment: Alignment.topCenter,
                  width: 100,
                  height: 100,
                  color: Colors.white,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 150,
                        height: 100,
                        child: TextField(
                          controller: new TextEditingController(),
                          textInputAction: TextInputAction.newline,
                          keyboardType: TextInputType.multiline,
                          textAlign: TextAlign.start,
                          onChanged: (text) {
                            wardList[idx] = text;
                            print(text);
                            //setState(() {});
                          },
                          onEditingComplete: () {
                            setState(() {});
                          },
                          decoration: new InputDecoration(
                            suffix: IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {});
                                }),
                          ),
                        ),
                      ),
                      Text(
                        '${wardList[idx]}',
                      ),
                    ],
                  )));
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            taskNum += 1;
            wardList.add('');
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
