import 'package:flutter/material.dart';

class AddedCropsPage extends StatefulWidget {
  final Map<String, dynamic> farm;
  const AddedCropsPage({super.key, required this.farm});

  @override
  _AddedCropsPageState createState() => _AddedCropsPageState();
}

class _AddedCropsPageState extends State<AddedCropsPage> {
  bool isLoading = false;
  String loadingText = "Fetching recommended crops...";
  List<Map<String, dynamic>> selectedCrops = [];

  Future<List<Map<String, dynamic>>> _getRecommendedCrops() async {
    setState(() {
      isLoading = true;
      loadingText = "Fetching recommended crops...";
    });

    await Future.delayed(const Duration(seconds: 2));

    final recommendedCrops = [
      {
        'name': 'Maize',
        'description': 'Best suited for this soil composition.',
        'image': 'assets/images/maize.webp',
      },
      {
        'name': 'Wheat',
        'description': 'Thrives in moderately acidic soils.',
        'image': 'assets/images/wheat.jpeg',
      },
      {
        'name': 'Rice',
        'description': 'Ideal for clay-loam soil.',
        'image': 'assets/images/rice.png',
      },
    ];

    setState(() {
      isLoading = false;
    });

    return recommendedCrops;
  }

  void _addSelectedCrops() {
    final List<Map<String, dynamic>> updatedCrops = List.from(widget.farm['crops']);

    for (var selectedCrop in selectedCrops) {
      final isDuplicate =
      updatedCrops.any((crop) => crop['name'] == selectedCrop['name']);
      if (!isDuplicate) {
        updatedCrops.add(selectedCrop);
      }
    }

    setState(() {
      widget.farm['crops'] = updatedCrops;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Successfully added to your list")),
    );
  }

  void _deleteCrop(int index) {
    setState(() {
      widget.farm['crops'].removeAt(index); // Remove the crop at the specified index
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Crop deleted successfully")),
    );
  }

  void _showSelectCropsModal() async {
    final recommendedCrops = await _getRecommendedCrops();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Recommended Crops"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: recommendedCrops.map((crop) {
                    return CheckboxListTile(
                      title: Text(crop['name'] ?? 'Unnamed Crop'),
                      subtitle: Text(crop['description'] ?? 'No description'),
                      value: selectedCrops.contains(crop),
                      onChanged: (bool? value) {
                        setStateDialog(() {
                          if (value == true) {
                            selectedCrops.add(crop);
                          } else {
                            selectedCrops.remove(crop);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _addSelectedCrops();
                Navigator.of(context).pop();
              },
              child: const Text("Add Selected"),
            ),
          ],
        );
      },
    );
  }

  void _showCropDetails(Map<String, dynamic> crop) {
    List<Map<String, dynamic>> tasks = List.from(crop['tasks'] ?? [
      {'task': 'Water the crop daily', 'done': false},
      {'task': 'Fertilize with nitrogen-rich fertilizer', 'done': false},
      {'task': 'Check for pests weekly', 'done': false},
      {'task': 'Ensure proper sunlight exposure', 'done': false},
    ]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(crop['name'] ?? 'Unnamed Crop'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                crop['image'] != null
                    ? Image.asset(
                  crop['image'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.image, size: 100),
                const SizedBox(height: 10),
                Text(crop['description'] ?? 'No description available.'),
                const SizedBox(height: 10),
                const Text('To-Do List for Managing the Crop:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Column(
                  children: tasks.map((task) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return CheckboxListTile(
                          title: Text(task['task']),
                          value: task['done'],
                          onChanged: (bool? value) {
                            setState(() {
                              task['done'] = value ?? false;
                            });
                            crop['tasks'] = tasks;
                          },
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> crops = (widget.farm['crops'] as List?)
        ?.map((e) => e as Map<String, dynamic>)
        .toList() ??
        [];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.farm['farmName'] ?? 'Unnamed Farm'} - Crops'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (!isLoading)
            crops.isEmpty
                ? const Center(
              child: Text(
                "No crops added yet for this farm.",
                style: TextStyle(fontSize: 16),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: crops.length,
                itemBuilder: (context, index) {
                  final crop = crops[index];
                  return Dismissible(
                    key: Key(crop['name'] ?? index.toString()),
                    onDismissed: (direction) {
                      _deleteCrop(index);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: crop['image'] != null
                            ? Image.asset(
                          crop['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.image),
                        title: Text(crop['name'] ?? 'Unnamed Crop'),
                        subtitle: Text(
                            crop['description'] ?? 'No description'),
                        onTap: () => _showCropDetails(crop),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteCrop(index);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSelectCropsModal,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
