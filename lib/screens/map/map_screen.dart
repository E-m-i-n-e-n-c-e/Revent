import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:events_manager/models/map_marker.dart';
import 'package:events_manager/providers/stream_providers.dart';
import 'package:events_manager/utils/firedata.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController mapController = MapController();
  bool _isSatelliteMode = true;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _addMarker(LatLng position) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String description = '';
        String? imageUrl;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: const Color(0xFF06222F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      style: const TextStyle(color: Color(0xFFAEE7FF)),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Color(0xFF83ACBD)),
                        hintText: 'Enter location name',
                        hintStyle: TextStyle(color: Color(0xFF83ACBD)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF17323D)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFAEE7FF)),
                        ),
                      ),
                      onChanged: (value) => title = value,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: const TextStyle(color: Color(0xFFAEE7FF)),
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Color(0xFF83ACBD)),
                        hintText: 'Enter location description',
                        hintStyle: TextStyle(color: Color(0xFF83ACBD)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF17323D)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFAEE7FF)),
                        ),
                      ),
                      maxLines: 3,
                      onChanged: (value) => description = value,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () async {
                        final XFile? image = await _imagePicker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          try {
                            final url = await uploadMapMarkerImage(image.path);
                            setState(() {
                              imageUrl = url;
                            });
                          } catch (e) {
                            if (mounted) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to upload image: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.image, color: Color(0xFF83ACBD)),
                      label: const Text(
                        'Add Image',
                        style: TextStyle(color: Color(0xFF83ACBD)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF83ACBD)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFAEE7FF),
                            foregroundColor: const Color(0xFF06222F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (title.isNotEmpty) {
                              final marker = MapMarker(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                position: position,
                                title: title,
                                description: description,
                                imageUrl: imageUrl,
                                createdAt: DateTime.now(),
                              );
                              try {
                                await addMapMarker(marker);
                                if (mounted) {
                                  ref.invalidate(mapMarkersProvider);
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to add marker: $e'),
                                      backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          },
                          child: const Text('Add Marker'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _editMarker(MapMarker marker) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = marker.title;
        String description = marker.description;
        String? imageUrl = marker.imageUrl;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: const Color(0xFF06222F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      style: const TextStyle(color: Color(0xFFAEE7FF)),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Color(0xFF83ACBD)),
                        hintStyle: TextStyle(color: Color(0xFF83ACBD)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF17323D)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFAEE7FF)),
                        ),
                      ),
                      controller: TextEditingController(text: title),
                      onChanged: (value) => title = value,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: const TextStyle(color: Color(0xFFAEE7FF)),
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Color(0xFF83ACBD)),
                        hintStyle: TextStyle(color: Color(0xFF83ACBD)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF17323D)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFAEE7FF)),
                        ),
                      ),
                      controller: TextEditingController(text: description),
                      maxLines: 3,
                      onChanged: (value) => description = value,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () async {
                        final XFile? image = await _imagePicker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          try {
                            final url = await uploadMapMarkerImage(image.path);
                            setState(() {
                              imageUrl = url;
                            });
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to upload image: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.image, color: Color(0xFF83ACBD)),
                      label: const Text(
                        'Change Image',
                        style: TextStyle(color: Color(0xFF83ACBD)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            try {
                              await deleteMapMarker(marker.id);
                              if (mounted) {
                                ref.invalidate(mapMarkersProvider);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to delete marker: $e'),
                                    backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Color(0xFF83ACBD)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFAEE7FF),
                                foregroundColor: const Color(0xFF06222F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                if (title.isNotEmpty) {
                                  final updatedMarker = MapMarker(
                                    id: marker.id,
                                    position: marker.position,
                                    title: title,
                                    description: description,
                                    imageUrl: imageUrl,
                                    createdAt: marker.createdAt,
                                  );
                                  try {
                                    await updateMapMarker(updatedMarker);
                                    if (mounted) {
                                      ref.invalidate(mapMarkersProvider);
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to update marker: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                     }
                                    }
                                  }
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final markersAsync = ref.watch(mapMarkersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: const Color(0xFF06222F),
        actions: [
          IconButton(
            icon: Icon(_isSatelliteMode ? Icons.map : Icons.satellite),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () {
              setState(() {
                _isSatelliteMode = !_isSatelliteMode;
              });
            },
          ),
        ],
      ),
      body: markersAsync.when(
        data: (markers) {
          return FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(9.754969, 76.650201),
              initialZoom: 17.0,
              onTap: (tapPosition, point) => _addMarker(point),
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatelliteMode
                    ? 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                tileProvider: NetworkTileProvider(),
              ),
              MarkerLayer(
                markers: markers.map((marker) {
                  return Marker(
                    width: 150.0,
                    height: 80.0,
                    point: marker.position,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF06222F),
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 4,
                                      width: 40,
                                      margin: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF83ACBD),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    if (marker.imageUrl != null)
                                      Container(
                                        height: 200,
                                        width: double.infinity,
                                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            marker.imageUrl!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            marker.title,
                                            style: const TextStyle(
                                              color: Color(0xFFAEE7FF),
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            marker.description,
                                            style: const TextStyle(
                                              color: Color(0xFF83ACBD),
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                color: Color(0xFF83ACBD),
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${marker.position.latitude.toStringAsFixed(6)}, ${marker.position.longitude.toStringAsFixed(6)}',
                                                style: const TextStyle(
                                                  color: Color(0xFF83ACBD),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          onLongPress: () => _editMarker(marker),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFAEE7FF),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF06222F).withValues(alpha:0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF06222F),
                              size: 24.0,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 140,
                            ),
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF06222F).withValues(alpha:0.9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF17323D)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha:0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IntrinsicWidth(
                              child: Text(
                                marker.title,
                                style: const TextStyle(
                                  color: Color(0xFFAEE7FF),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                softWrap: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error loading markers: $error'),
        ),
      ),
    );
  }
}
