import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('contacts_box');

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HiveHome(),
  ));
}

class HiveHome extends StatefulWidget {
  const HiveHome({super.key});

  @override
  State<HiveHome> createState() => _HiveHomeState();
}

class _HiveHomeState extends State<HiveHome> {
  final Box box = Hive.box('contacts_box');
  final controller = TextEditingController();

  // Menambahkan atau memperbarui data
  void showForm({int? index}) {
    controller.clear();

    if (index != null) {
      controller.text = box.getAt(index).toString();
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(index == null ? 'Tambah Data' : 'Update Data'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Masukkan data',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final value = controller.text.trim();

              if (value.isNotEmpty) {
                if (index == null) {
                  // CREATE
                  await box.add(value);
                } else {
                  // UPDATE
                  await box.putAt(index, value);
                }
              }

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Storage'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, child) {
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(box.getAt(index).toString()),
                onTap: () => showForm(index: index),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => box.deleteAt(index),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
