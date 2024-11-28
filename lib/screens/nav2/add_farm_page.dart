import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_iq/screens/nav3/crop_recommendation_page.dart';

class AddFarmPage extends StatefulWidget {
  const AddFarmPage(
      {super.key, required this.onAddFarm, required Map<String, dynamic> farm});

  final void Function(Map<String, dynamic> newFarm) onAddFarm;

  @override
  _AddFarmPageState createState() => _AddFarmPageState();
}

class _AddFarmPageState extends State<AddFarmPage> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController farmNameController = TextEditingController();
  String? selectedSeason; // Default season
  String? imagePath;
  bool isLoading = false;
  bool isSoilCompositionDetected = false;
  Map<String, dynamic>? soilComposition;
  String loadingText = "Detecting soil composition...";

  // Dropdown options for season
  List<String> seasons = ['Dry', 'Wet'];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imagePath = image.path;
      });
    }
  }

  Future<void> _detectSoilComposition() async {
    setState(() {
      isLoading = true;
      loadingText = "Detecting soil composition...";
    });

    final composition = await _getSoilComposition();
    setState(() {
      soilComposition = composition;
      isSoilCompositionDetected = true;
      isLoading = false;
    });
  }

  Future<Map<String, dynamic>> _getSoilComposition() async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'components': {
        'Sandy': '40%',
        'Silty': '35%',
        'Clay': '15%',
        'Loam': '10%',
      },
      'pH': 6.5,
      'nutrients': {
        'Nitrogen': 'High',
        'Phosphorus': 'Medium',
        'Potassium': 'Low',
      },
    };
  }

  Future<List<Map<String, dynamic>>> _getRecommendations() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
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
  }
  Future<void> _navigateToRecommendations() async {
    if (locationController.text.isEmpty || selectedSeason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all the required fields.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      loadingText = "Getting results...";
    });

    final crops = await _getRecommendations();

    setState(() {
      isLoading = false;
    });

    if (soilComposition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Soil composition not detected.")),
      );
      return;
    }

    final Map<String, dynamic>? selectedCrop = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropRecommendationPage(
          crops: crops,
          soilComposition: soilComposition!,
        ),
      ),
    );

    if (selectedCrop != null) {
      widget.onAddFarm({
        'farmName': farmNameController.text,
        'description': selectedCrop['description'],
        'season': selectedSeason, // Season from dropdown
        'image': selectedCrop['image'],
        'location': locationController.text,
        'date': DateTime.now().toString(),
        'soilComposition': soilComposition,
        'crops': [selectedCrop], // Store the selected crop here
      });

      // Show a success message after adding the farm with the selected crop
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully added crop to the farm.")),
      );

      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Add Farm'),
          backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: farmNameController,
              decoration: const InputDecoration(labelText: 'Farm Name (Optional)'),
            ),
            const SizedBox(height: 16),
            // Dropdown for season
            DropdownButtonFormField<String>(
              value: selectedSeason,
              onChanged: (String? newValue) {
                setState(() {
                  selectedSeason = newValue!;
                });
              },
              items: seasons
                  .map<DropdownMenuItem<String>>((String season) {
                return DropdownMenuItem<String>(
                  value: season,
                  child: Text(season),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Season'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Upload Image (Optional)')),
            if (imagePath != null) Text('Image Selected: $imagePath'),
            const SizedBox(height: 16),
            isLoading
                ? Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16), // Add spacing between loader and text
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.green, width: 1.0),
                  ),
                  child: Text(
                    loadingText,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
                  : !isSoilCompositionDetected
                ? ElevatedButton(
              onPressed: _detectSoilComposition,
              child: const Text('Detect Soil Composition'),
            )
                : const SizedBox.shrink(),


    if (isSoilCompositionDetected) ...[
              const Text('Soil Composition:'),
              Text('Sandy: ${soilComposition!['components']['Sandy']}'),
              Text('Silty: ${soilComposition!['components']['Silty']}'),
              Text('Clay: ${soilComposition!['components']['Clay']}'),
              Text('Loam: ${soilComposition!['components']['Loam']}'),
              Text('pH: ${soilComposition!['pH']}'),
              const Text('Nutrients:'),
              Text('Nitrogen: ${soilComposition!['nutrients']['Nitrogen']}'),
              Text('Phosphorus: ${soilComposition!['nutrients']['Phosphorus']}'),
              Text('Potassium: ${soilComposition!['nutrients']['Potassium']}'),
            ],
            const SizedBox(height: 16),
            if (isSoilCompositionDetected)
              ElevatedButton(
                onPressed: _navigateToRecommendations,
                child: const Text('Get Recommendations'),
              ),
          ],
        ),
      ),
    );
  }
}
