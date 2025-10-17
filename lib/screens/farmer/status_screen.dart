import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/status_model.dart';
import 'status_view_screen.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  // Demo statuses - later fetch from Firebase
  final List<StatusModel> _statuses = [
    StatusModel(
      id: '1',
      title: 'New Fertilizer Arrived',
      titleMarathi: 'नवीन खत आले',
      description: 'Premium quality NPK fertilizer now available at best prices!',
      descriptionMarathi: 'उत्तम दर्जाचे NPK खत आता उपलब्ध! उत्तम किमतीत मिळवा.',
      type: StatusType.image,
      imageUrl: 'assets/images/fertilizer_sample.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      expiresAt: DateTime.now().add(const Duration(hours: 22)),
      icon: Icons.grass,
      categoryColor: Colors.green,
      category: 'खत',
    ),
    StatusModel(
      id: '2',
      title: 'Weather Alert',
      titleMarathi: 'हवामान सूचना',
      description: 'Heavy rain expected in next 48 hours. Postpone fertilizer application.',
      descriptionMarathi: 'पुढील ४८ तासांत मुसळधार पाऊस अपेक्षित. खत देणे पुढे ढकला.',
      type: StatusType.text,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      expiresAt: DateTime.now().add(const Duration(hours: 19)),
      icon: Icons.cloud,
      categoryColor: Colors.blue,
      category: 'हवामान',
    ),
    StatusModel(
      id: '3',
      title: 'Farming Tip',
      titleMarathi: 'शेती टीप',
      description: 'Apply zinc sulfate 15 days before flowering for better yield.',
      descriptionMarathi: 'चांगल्या उत्पादनासाठी फुलण्याच्या १५ दिवस आधी झिंक सल्फेट द्या.',
      type: StatusType.text,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      expiresAt: DateTime.now().add(const Duration(hours: 16)),
      icon: Icons.lightbulb,
      categoryColor: Colors.orange,
      category: 'टीप',
    ),
    StatusModel(
      id: '4',
      title: 'Government Scheme',
      titleMarathi: 'सरकारी योजना',
      description: 'New subsidy scheme for organic farming. Register before 30th November.',
      descriptionMarathi: 'जैविक शेतीसाठी नवीन अनुदान योजना. ३० नोव्हेंबरपूर्वी नोंदणी करा.',
      type: StatusType.text,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      expiresAt: DateTime.now().add(const Duration(hours: 36)),
      icon: Icons.agriculture,
      categoryColor: Colors.purple,
      category: 'योजना',
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
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
                          'अपडेट्स',
                          style: GoogleFonts.notoSansDevanagari(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Updates & Notifications',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'स्टेटस 24 तासांसाठी सक्रिय राहतो',
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Status circles (like WhatsApp/Instagram)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _statuses.length,
              itemBuilder: (context, index) {
                final status = _statuses[index];
                return _buildStatusCircle(status, index);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Recent Updates Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'अलीकडील अपडेट्स',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Recent Updates',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_statuses.length} अपडेट्स',
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Status cards list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _statuses.length,
              itemBuilder: (context, index) {
                final status = _statuses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildStatusCard(status, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCircle(StatusModel status, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StatusViewScreen(
              statuses: _statuses,
              initialIndex: index,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            // Status Circle
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    status.categoryColor,
                    status.categoryColor.withOpacity(0.7),
                  ],
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: status.categoryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                status.icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            // Category Name
            SizedBox(
              width: 75,
              child: Column(
                children: [
                  Text(
                    status.category,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: status.categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getTimeRemaining(status.expiresAt).split(' ').first,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: status.categoryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(StatusModel status, int index) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StatusViewScreen(
                  statuses: _statuses,
                  initialIndex: index,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: status.categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    status.icon,
                    color: status.categoryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                const SizedBox(height: 2),
                                Text(
                                  status.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: status.categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getTimeRemaining(status.expiresAt),
                              style: GoogleFonts.notoSansDevanagari(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: status.categoryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Text(
                        status.descriptionMarathi,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSansDevanagari(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Arrow Icon
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF2E7D32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}