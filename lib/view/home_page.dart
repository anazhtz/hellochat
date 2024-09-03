// home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hellochat/components/appcolor.dart';
import 'package:hellochat/components/my_drawer.dart';
import 'package:hellochat/firebase_helper/firebase_helper.dart';
import 'package:hellochat/services/chat_services/chat_service.dart';
import 'package:hellochat/view/chat_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Chat and auth service
  final ChatService _chatService = ChatService();
  final FireHelper _fireHelper = FireHelper();

  // Refresh controller for pull-to-refresh
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // List to store all users and filtered users
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_onSearchChanged);
  }

  void _fetchUsers() async {
    final usersStream = _chatService.getUsersStreamExcludingBlocked();
    usersStream.listen((users) {
      setState(() {
        allUsers = users;
        filteredUsers = users;
      });
    });
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = allUsers.where((user) {
        String name = user['Name']?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    });
  }

  void _onRefresh() async {
    // Fetch new data and refresh the list
    _fetchUsers();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: Text(
          "HelloChat",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearchDialog(context);
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: WaterDropHeader(
          waterDropColor: AppColors.primary,
          complete: Icon(Icons.check, color: AppColors.primary),
        ),
        onRefresh: _onRefresh,
        child: filteredUsers.isEmpty
            ? Center(
                child: Text(
                  "No users found",
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  return _buildUserListItem(filteredUsers[index]);
                },
              ),
      ),
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData) {
    final name = userData["Name"] as String?;
    final email = userData["Email"] as String?;
    final avatarUrl = userData["avatarUrl"] as String?;
    final isOnline = userData["isOnline"] as bool? ?? false;

    if (name == null || email == null) {
      return const SizedBox();
    }

    final currentUserEmail = _fireHelper.currentUser?.email;

    if (email == currentUserEmail) {
      return Container();
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => ChatPage(
              receiverEmail: email,
              receiverID: userData['UID'],
            ));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? CachedNetworkImageProvider(avatarUrl)
                      : const NetworkImage(
                          "https://img.freepik.com/premium-vector/vector-professional-icon-business-illustration-line-symbol-people-management-career-set-c_1013341-74706.jpg",
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isOnline ? AppColors.online : AppColors.offline,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cardBackground,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
