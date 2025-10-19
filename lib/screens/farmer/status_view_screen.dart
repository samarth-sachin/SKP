import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../models/status_model.dart';
import '../../services/firebase_service.dart';

class StatusViewScreen extends StatefulWidget {
  final List<StatusModel> statuses;
  final int initialIndex;

  const StatusViewScreen({
    super.key,
    required this.statuses,
    this.initialIndex = 0,
  });

  @override
  State<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen> {
  late PageController _pageController;
  late int _currentIndex;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    // Increment view count for first status
    _incrementViewCount(widget.statuses[_currentIndex]);
  }

  void _incrementViewCount(StatusModel status) {
    FirebaseService.incrementStatusViewCount(status.id);
  }

  String _getTimeRemaining(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} दिवस शिल्लक';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} तास शिल्लक';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} मिनिटे शिल्लक';
    } else {
      return 'कालबाह्य';
    }
  }

  void _initializeVideoPlayer(String videoUrl) {
    _videoController?.dispose();
    _chewieController?.dispose();

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _videoController!.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF2E7D32),
          handleColor: const Color(0xFF2E7D32),
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey,
        ),
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.statuses[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            // Tap on left side - previous
            if (_currentIndex > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.pop(context);
            }
          } else {
            // Tap on right side - next
            if (_currentIndex < widget.statuses.length - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.pop(context);
            }
          }
        },
        child: Stack(
          children: [
            // Content
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _incrementViewCount(widget.statuses[index]);

                // Initialize video if needed
                final newStatus = widget.statuses[index];
                if (newStatus.type == StatusType.video && newStatus.imageUrl != null) {
                  _initializeVideoPlayer(newStatus.imageUrl!);
                } else {
                  _videoController?.pause();
                }
              },
              itemCount: widget.statuses.length,
              itemBuilder: (context, index) {
                return _buildStatusContent(widget.statuses[index]);
              },
            ),

            // Progress indicators at top
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: List.generate(
                    widget.statuses.length,
                        (index) => Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index <= _currentIndex
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Close button
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusContent(StatusModel status) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            status.categoryColor.withOpacity(0.2),
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60), // Space for progress bars

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [status.categoryColor, status.categoryColor.withOpacity(0.7)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: status.categoryColor.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(status.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SKP बळीराजा',
                          style: GoogleFonts.notoSansDevanagari(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _getTimeRemaining(status.expiresAt),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // View count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.visibility, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${status.viewCount}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: status.categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.category.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: status.categoryColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      Text(
                        status.titleMarathi,
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        status.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Image (if exists)
                      if (status.type == StatusType.image && status.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
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
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Icon(Icons.image, size: 60, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),

                      // Video (if exists)
                      if (status.type == StatusType.video && status.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _chewieController != null && _videoController != null
                              ? SizedBox(
                            height: 200,
                            child: Chewie(controller: _chewieController!),
                          )
                              : Container(
                            height: 200,
                            color: Colors.black87,
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                        ),

                      if (status.type != StatusType.text) const SizedBox(height: 24),

                      // Description
                      Text(
                        status.descriptionMarathi,
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        status.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
