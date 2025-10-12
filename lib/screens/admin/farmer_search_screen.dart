import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/local_storage_service.dart';
import '../../models/farmer_model.dart';

class FarmerSearchScreen extends StatefulWidget {
  const FarmerSearchScreen({super.key});

  @override
  State<FarmerSearchScreen> createState() => _FarmerSearchScreenState();
}

class _FarmerSearchScreenState extends State<FarmerSearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, village, or phone',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),
        Expanded(
          child: _searchQuery.isEmpty
              ? _buildAllFarmers()
              : _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildAllFarmers() {
    final storageService = Provider.of<LocalStorageService>(context);
    final farmers = storageService.getAllFarmers();

    if (farmers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: farmers.length,
      itemBuilder: (context, index) {
        final farmer = farmers[index];
        return _buildFarmerCard(farmer);
      },
    );
  }

  Widget _buildSearchResults() {
    final storageService = Provider.of<LocalStorageService>(context);
    
    return StreamBuilder<List<FarmerModel>>(
      stream: storageService.searchFarmers(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 100, color: Colors.grey[300]),
                const SizedBox(height: 20),
                Text(
                  'No farmers found',
                  style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final farmer = snapshot.data![index];
            return _buildFarmerCard(farmer);
          },
        );
      },
    );
  }

  Widget _buildFarmerCard(FarmerModel farmer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
          child: const Icon(Icons.person, color: Color(0xFF2E7D32)),
        ),
        title: Text(
          farmer.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Village: ${farmer.village}'),
            Text('Phone: ${farmer.phoneNumber}'),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showFarmerDetails(farmer);
        },
      ),
    );
  }

  void _showFarmerDetails(FarmerModel farmer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      farmer.name,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoTile(Icons.location_on, 'Village', farmer.village),
                  _buildInfoTile(Icons.phone, 'Phone', farmer.phoneNumber),
                  if (farmer.alternatePhone != null)
                    _buildInfoTile(
                      Icons.phone_android,
                      'Alternate Phone',
                      farmer.alternatePhone!,
                    ),
                  _buildInfoTile(
                    Icons.calendar_today,
                    'Registration Date',
                    '${farmer.registrationDate.day}/${farmer.registrationDate.month}/${farmer.registrationDate.year}',
                  ),
                  _buildInfoTile(
                    Icons.landscape,
                    'Total Lands',
                    '${farmer.landIds.length}',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'No farmers registered yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Demo farmers will appear here',
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
