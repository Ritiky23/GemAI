import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';


class GeminiChat extends StatefulWidget {
  const GeminiChat({Key? key}) : super(key: key);

  @override
  State<GeminiChat> createState() => _GeminiChatState();
}

class _GeminiChatState extends State<GeminiChat> {
  final ImagePicker picker = ImagePicker();
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  bool loading = false;
  bool isTextWithImage = false;
  String? searchedText, result;
  Uint8List? selectedImage;
  List<Uint8List> imageList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GemAI'),
        backgroundColor: Color.fromARGB(255, 94, 94, 94),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Radio(
                value: false,
                groupValue: isTextWithImage,
                onChanged: (val) {
                  setState(() {
                    isTextWithImage = val ?? false;
                  });
                },
              ),
              const Text("Search With Text"),
              Radio(
                value: true,
                groupValue: isTextWithImage,
                onChanged: (val) {
                  setState(() {
                    isTextWithImage = val ?? false;
                  });
                },
              ),
              const Text("Search With Image"),
            ],
          ),
          if (searchedText != null)
            MaterialButton(
              color: const Color.fromARGB(255, 255, 255, 255),
              onPressed: () {
                setState(() {
                  searchedText = null;
                  result = null;
                });
              },
              child: Text(
                'Question : $searchedText',
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : result != null
                            ? Markdown(
  data: result!,
  padding: const EdgeInsets.symmetric(horizontal: 12),
)
                            : const Center(
                                child: Text('Search something!'),
                              ),
                  ),
                  if (selectedImage != null)
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.memory(
                          selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      hintText: 'Write Something...',
                      border: InputBorder.none,
                    ),
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                ),
                if (isTextWithImage)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? photo = await picker.pickImage(
                              source: ImageSource.camera);

                          if (photo != null) {
                            photo.readAsBytes().then((value) => setState(() {
                                  selectedImage = value;
                                }));
                          }
                        },
                        icon: const Icon(Icons.file_copy_outlined)),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
  if (isTextWithImage) {
    if (selectedImage != null) {
      searchedText = controller.text;
      imageList.add(selectedImage!);
      controller.clear();
      setState(() {
        loading = true;
      });

     gemini.textAndImage(text: searchedText!, images: imageList)
          .then((value) {
        setState(() {
          result = value?.content?.parts?.last.text;
          print('hiii: ${result}');
          loading = false;
        });
      }).catchError((error) {
        setState(() {
          loading = false;
        });
        print('Error: $error');
      });
    } else {
      Toast.show("Please Select The Picture");
    }
  } else {
    searchedText = controller.text;
    controller.clear();
    setState(() {
      loading = true;
    });

    gemini.text(searchedText!).then((value) {
      setState(() {
        result = value?.content?.parts?.last.text;
        loading = false;
      });
    }).catchError((error) {
      setState(() {
        loading = false;
      });
      print('Error: $error');
    });
  }
} else {
  Toast.show("Toast plugin app");
}
                      },
                      icon: const Icon(Icons.send_rounded)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
