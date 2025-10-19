import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';
import '../../models/status_model.dart';
import '../../services/firebase_service.dart';

class AdminStatusScreen extends StatefulWidget {
  const AdminStatusScreen({super.key});

  @override
  State<AdminStatusScreen> createState() => _AdminStatusScreenState();
}

class _AdminStatusScreenState extends State<AdminStatusScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedMedia;
  MediaType _selectedMediaType = MediaType.text;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedMedia = File(image.path);
          _selectedMediaType = MediaType.image;
        });
      }
    } catch (e) {
      _showErrorSnackbar('प्रतिमा निवडताना त्रुटी: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );

      if (video != null) {
        setState(() {
          _selectedMedia = File(video.path);
          _selectedMediaType = MediaType.video;
          _initializeVideoPlayer(File(video.path));
        });
      }
    } catch (e) {
      _showErrorSnackbar('व्हिडिओ निवडताना त्रुटी: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedMedia = File(image.path);
          _selectedMediaType = MediaType.image;
        });
      }
    } catch (e) {
      _showErrorSnackbar('कॅमेरा वापरताना त्रुटी: $e');
    }
  }

  Future<void> _takeVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );

      if (video != null) {
        setState(() {
          _selectedMedia = File(video.path);
          _selectedMediaType = MediaType.video;
          _initializeVideoPlayer(File(video.path));
        });
      }
    } catch (e) {
      _showErrorSnackbar('व्हिडिओ रेकॉर्ड करताना त्रुटी: $e');
    }
  }

  void _initializeVideoPlayer(File videoFile) {
    _videoController?.dispose();
    _chewieController?.dispose();

    _videoController = VideoPlayerController.file(videoFile);
    _videoController!.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFFF6F00),
          handleColor: const Color(0xFFFF6F00),
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey,
        ),
      );
      setState(() {});
    });
  }

  void _clearMedia() {
    setState(() {
      _selectedMedia = null;
      _selectedMediaType = MediaType.text;
      _videoController?.dispose();
      _chewieController?.dispose();
      _videoController = null;
      _chewieController = null;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.notoSansDevanagari()),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: StreamBuilder<List<StatusModel>>(
        stream: FirebaseService.getAllStatusesForAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6F00)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error loading statuses', style: GoogleFonts.poppins(color: Colors.red)),
                ],
              ),
            );
          }

          final statuses = snapshot.data ?? [];

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'स्टेटस व्यवस्थापन',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Status Management',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${statuses.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Active Status Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange[50]!, Colors.orange[100]!],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Color(0xFFFF6F00)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'सक्रिय स्टेटस: ${statuses.where((s) => !s.isExpired).length}',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[900],
                              ),
                            ),
                            Text(
                              'सर्व शेतकरी हे स्टेटस पाहू शकतात',
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 12,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (statuses.any((s) => s.isExpired))
                        IconButton(
                          icon: const Icon(Icons.delete_sweep, color: Colors.red),
                          onPressed: () => _deleteExpiredStatuses(),
                          tooltip: 'Delete Expired',
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Status List
              Expanded(
                child: statuses.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: statuses.length,
                  itemBuilder: (context, index) {
                    final status = statuses[index];
                    return _buildStatusCard(status);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStatusDialog(),
        backgroundColor: const Color(0xFFFF6F00),
        icon: const Icon(Icons.add),
        label: Text(
          'नवीन स्टेटस',
          style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle_notifications_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'स्टेटस नाही',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'नवीन स्टेटस जोडण्यासाठी + दाबा',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(StatusModel status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: status.categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(status.icon, color: status.categoryColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.titleMarathi,
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status.category.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: status.categoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('हटवा', style: GoogleFonts.notoSansDevanagari(fontSize: 14)),
                        ],
                      ),
                      onTap: () => Future.delayed(Duration.zero, () => _deleteStatus(status)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Media Preview
            if (status.type == StatusType.image && status.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  status.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),

            if (status.type == StatusType.image) const SizedBox(height: 12),

            Text(
              status.descriptionMarathi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  status.timeRemaining,
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.isExpired ? Colors.red[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.isExpired ? 'समाप्त' : 'सक्रिय',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: status.isExpired ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStatusDialog({StatusModel? status}) {
    final titleController = TextEditingController(text: status?.titleMarathi ?? '');
    final titleEnController = TextEditingController(text: status?.title ?? '');
    final descController = TextEditingController(text: status?.descriptionMarathi ?? '');
    final descEnController = TextEditingController(text: status?.description ?? '');
    String selectedCategory = status?.category ?? 'खत';
    int expiryHours = 24;

    if (status == null) {
      _clearMedia();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            status == null ? 'नवीन स्टेटस जोडा' : 'स्टेटस संपादित करा',
            style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media Type Selection
                Text(
                  'मीडिया प्रकार',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildMediaTypeChip(MediaType.text, 'मजकूर', Icons.text_fields, setDialogState),
                    _buildMediaTypeChip(MediaType.image, 'प्रतिमा', Icons.image, setDialogState),
                    _buildMediaTypeChip(MediaType.video, 'व्हिडिओ', Icons.videocam, setDialogState),
                  ],
                ),
                const SizedBox(height: 12),

                // Media Picker Buttons
                if (_selectedMediaType != MediaType.text)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectedMediaType == MediaType.image ? _pickImage : _pickVideo,
                              icon: const Icon(Icons.photo_library),
                              label: Text('गॅलरीतून निवडा', style: GoogleFonts.notoSansDevanagari(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectedMediaType == MediaType.image ? _takePhoto : _takeVideo,
                              icon: const Icon(Icons.camera_alt),
                              label: Text('कॅमेरा वापरा', style: GoogleFonts.notoSansDevanagari(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),

                // Media Preview
                if (_selectedMedia != null)
                  Container(
                    width: double.infinity,
                    height: 150,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                    ),
                    child: Stack(
                      children: [
                        if (_selectedMediaType == MediaType.image)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_selectedMedia!, fit: BoxFit.cover, width: double.infinity),
                          )
                        else if (_selectedMediaType == MediaType.video && _chewieController != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Chewie(controller: _chewieController!),
                          ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              _clearMedia();
                              setDialogState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Category selection
                Text(
                  'प्रकार निवडा',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildCategoryChip('खत', Icons.grass, Colors.green, selectedCategory, (val) {
                      setDialogState(() => selectedCategory = val);
                    }),
                    _buildCategoryChip('हवामान', Icons.cloud, Colors.blue, selectedCategory, (val) {
                      setDialogState(() => selectedCategory = val);
                    }),
                    _buildCategoryChip('टीप', Icons.lightbulb, Colors.orange, selectedCategory, (val) {
                      setDialogState(() => selectedCategory = val);
                    }),
                    _buildCategoryChip('योजना', Icons.agriculture, Colors.purple, selectedCategory, (val) {
                      setDialogState(() => selectedCategory = val);
                    }),
                  ],
                ),
                const SizedBox(height: 16),

                // Title Marathi
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'शीर्षक (मराठी)',
                    labelStyle: GoogleFonts.notoSansDevanagari(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),

                // Title English
                TextField(
                  controller: titleEnController,
                  decoration: InputDecoration(
                    labelText: 'Title (English)',
                    labelStyle: GoogleFonts.poppins(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),

                // Description Marathi
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'तपशील (मराठी)',
                    labelStyle: GoogleFonts.notoSansDevanagari(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),

                // Description English
                TextField(
                  controller: descEnController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description (English)',
                    labelStyle: GoogleFonts.poppins(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),

                // Expiry time
                Text(
                  'समाप्ती वेळ',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<int>(
                        title: Text('12 तास', style: GoogleFonts.notoSansDevanagari(fontSize: 13)),
                        value: 12,
                        groupValue: expiryHours,
                        onChanged: (val) => setDialogState(() => expiryHours = val!),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<int>(
                        title: Text('24 तास', style: GoogleFonts.notoSansDevanagari(fontSize: 13)),
                        value: 24,
                        groupValue: expiryHours,
                        onChanged: (val) => setDialogState(() => expiryHours = val!),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('रद्द करा', style: GoogleFonts.notoSansDevanagari()),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty || descController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('कृपया सर्व माहिती भरा', style: GoogleFonts.notoSansDevanagari()),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (_selectedMediaType != MediaType.text && _selectedMedia == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('कृपया प्रतिमा किंवा व्हिडिओ निवडा', style: GoogleFonts.notoSansDevanagari()),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                _saveStatus(
                  status: status,
                  titleMr: titleController.text,
                  titleEn: titleEnController.text,
                  descMr: descController.text,
                  descEn: descEnController.text,
                  category: selectedCategory,
                  expiryHours: expiryHours,
                  mediaType: _selectedMediaType,
                  mediaFile: _selectedMedia,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F00),
              ),
              child: Text(
                status == null ? 'जोडा' : 'जतन करा',
                style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTypeChip(MediaType type, String label, IconData icon, StateSetter setState) {
    final isSelected = _selectedMediaType == type;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFFFF6F00)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 12,
              color: isSelected ? Colors.white : const Color(0xFFFF6F00),
            ),
          ),
        ],
      ),
      selectedColor: const Color(0xFFFF6F00),
      checkmarkColor: Colors.white,
      onSelected: (val) {
        setState(() {
          _selectedMediaType = type;
          if (type == MediaType.text) {
            _clearMedia();
          }
        });
      },
    );
  }

  Widget _buildCategoryChip(String value, IconData icon, Color color, String selected, Function(String) onSelected) {
    final isSelected = selected == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : color),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 12,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ],
      ),
      selectedColor: color,
      checkmarkColor: Colors.white,
      onSelected: (val) => onSelected(value),
    );
  }

  Future<void> _saveStatus({
    StatusModel? status,
    required String titleMr,
    required String titleEn,
    required String descMr,
    required String descEn,
    required String category,
    required int expiryHours,
    required MediaType mediaType,
    required File? mediaFile,
  }) async {
    // Show loading dialog
    bool isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('अपलोड होत आहे...', style: GoogleFonts.notoSansDevanagari()),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      isDialogOpen = false;
    });

    try {
      final StatusType statusType;
      if (mediaType == MediaType.image) {
        statusType = StatusType.image;
      } else if (mediaType == MediaType.video) {
        statusType = StatusType.video;
      } else {
        statusType = StatusType.text;
      }

      final newStatus = StatusModel(
        id: status?.id ?? '',
        title: titleEn,
        titleMarathi: titleMr,
        description: descEn,
        descriptionMarathi: descMr,
        type: statusType,
        createdAt: status?.createdAt ?? DateTime.now(),
        expiresAt: DateTime.now().add(Duration(hours: expiryHours)),
        category: category,
      );

      if (status == null) {
        await FirebaseService.addStatus(newStatus, mediaFile: mediaFile);
      } else {
        await FirebaseService.updateStatus(newStatus, newMediaFile: mediaFile);
      }

      _clearMedia();

      // ✅ Close loading dialog safely
      if (isDialogOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // ✅ Wait a moment before showing success message
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == null ? 'स्टेटस जोडला!' : 'स्टेटस अपडेट केला!',
            style: GoogleFonts.notoSansDevanagari(),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // ✅ Close loading dialog on error
      if (isDialogOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _deleteStatus(StatusModel status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('स्टेटस हटवा?', style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold)),
        content: Text('तुम्हाला नक्की हे स्टेटस हटवायचे आहे का?', style: GoogleFonts.notoSansDevanagari()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('नाही', style: GoogleFonts.notoSansDevanagari()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('हटवा', style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseService.deleteStatus(status.id);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('स्टेटस हटवला!', style: GoogleFonts.notoSansDevanagari()),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteExpiredStatuses() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('कालबाह्य स्टेटस हटवा?', style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold)),
        content: Text('सर्व कालबाह्य स्टेटस हटवायचे आहेत का?', style: GoogleFonts.notoSansDevanagari()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('नाही', style: GoogleFonts.notoSansDevanagari()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('हटवा', style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseService.deleteExpiredStatuses();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('कालबाह्य स्टेटस हटवले!', style: GoogleFonts.notoSansDevanagari()),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

enum MediaType { text, image, video }
