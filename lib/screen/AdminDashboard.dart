import 'package:flutter/material.dart';
import 'addcard_page.dart'; // Import trang AddCard_Page

void main() {
  runApp(AdminDashboardApp());
}

class AdminDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              children: [
                Header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ManageSection(
                          title: 'Manage Cards',
                          items: [],
                          itemType: 'Card',
                        ),
                        SizedBox(height: 20),
                        ManageSection(
                          title: 'Manage News',
                          items: [],
                          itemType: 'News',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Color(0xFF2C3E50),
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Admin Dashboard',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          SidebarItem(
            icon: Icons.people,
            label: 'Users',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UsersScreen()));
            },
          ),
          SidebarItem(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
          SidebarItem(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Add logout logic here
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  SidebarItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage('https://placehold.co/40x40'),
              ),
              SizedBox(width: 10),
              Text('Admin Name', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class ManageSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final String itemType;

  ManageSection({required this.title, required this.items, required this.itemType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            if (itemType == 'Card') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemonCardEntryPage(), // Navigate to AddCard_Page
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text('Add $itemType'),
        ),
        SizedBox(height: 10),
        ...items.map((item) {
          return ListTile(
            title: Text(item),
          );
        }).toList(),
      ],
    );
  }
}

class UsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: Center(child: Text('User management screen')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(child: Text('Settings screen')),
    );
  }
}
