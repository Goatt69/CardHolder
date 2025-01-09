import 'package:flutter/material.dart';
import 'addcard_page.dart'; // Import trang AddCard_Page
import 'Admin_page.dart';

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

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Simulating database with mock data
  List<String> cards = ['Card 1', 'Card 2', 'Card 3'];
  List<String> news = ['News 1', 'News 2', 'News 3'];

  // Controllers for input fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String? _editingNews;

  String currentView = ''; // Track which section is currently being viewed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            onViewCards: _viewCards,
            onViewNews: _viewNews,
            onAddCard: _addCard,
            onAdmin: _admin,
          ),
          Expanded(
            child: Column(
              children: [
                Header(),
                Expanded(
                  child: Center(
                    child: currentView.isEmpty
                        ? Text('Welcome to the Admin Dashboard')
                        : _buildViewContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Display cards
  void _viewCards() {
    setState(() {
      currentView = 'cards';
    });
  }

  // Display news
  void _viewNews() {
    setState(() {
      currentView = 'news';
    });
  }

  // Show AddCardPage in the body
  void _addCard() {
    setState(() {
      currentView = 'addCard';
    });
  }

  // Show AdminPage when "Add News" is clicked
  void _admin() {
    setState(() {
      currentView = 'adminPage';
    });
  }

  // Create a ListView for cards or news
  Widget _buildListView(List<String> items, String itemType) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(items[index]),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _editItem(items[index]),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteItem(index),
              ),
            ],
          ),
        );
      },
    );
  }

  // Edit a card or news item
  void _editItem(String item) {
    setState(() {
      _editingNews = item;
      _titleController.text = item; // Pre-fill the input fields for editing
      _contentController.text = "Content for $item"; // Example content
      _imageUrlController.text = 'http://example.com/$item.png'; // Example image URL
    });
  }

  // Delete a card or news item
  void _deleteItem(int index) {
    setState(() {
      if (currentView == 'cards') {
        cards.removeAt(index);
      } else if (currentView == 'news') {
        news.removeAt(index);
      }
    });
  }

  // Add or update news
  void _submitNews() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty || _imageUrlController.text.isEmpty) {
      return; // Handle validation
    }

    if (_editingNews == null) {
      setState(() {
        news.add(_titleController.text); // Add new news to list
      });
    } else {
      setState(() {
        int index = news.indexOf(_editingNews!);
        news[index] = _titleController.text; // Update existing news
      });
    }

    // Clear input fields after submission
    _titleController.clear();
    _contentController.clear();
    _imageUrlController.clear();
  }

  // Build content based on the current view
  Widget _buildViewContent() {
    if (currentView == 'cards') {
      return _buildListView(cards, 'Cards');
    } else if (currentView == 'news') {
      return _buildListView(news, 'News');
    } else if (currentView == 'addCard') {
      return PokemonCardEntryPage(); // Show the AddCardPage
    } else if (currentView == 'adminPage') {
      return AdminPage(); // Show AdminPage content here in the body
    } else {
      return Text('No content to display');
    }
  }
}

class Sidebar extends StatelessWidget {
  final VoidCallback onViewCards;
  final VoidCallback onViewNews;
  final VoidCallback onAddCard;
  final VoidCallback onAdmin;

  Sidebar({required this.onViewCards, required this.onViewNews, required this.onAddCard, required this.onAdmin});

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
          Divider(color: Colors.white),
          SidebarItem(
            icon: Icons.add_card,
            label: 'Add Card',
            onTap: onAddCard,
          ),
          SidebarItem(
            icon: Icons.add_box,
            label: 'Add News',
            onTap: onAdmin,
          ),
          SidebarItem(
            icon: Icons.remove_red_eye,
            label: 'View Added Cards',
            onTap: onViewCards,
          ),
          SidebarItem(
            icon: Icons.remove_red_eye,
            label: 'View Added News',
            onTap: onViewNews,
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

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(child: Text('Settings screen')),
    );
  }
}
