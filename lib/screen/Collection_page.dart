import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:cardholder/model/PokeCard.dart';
import 'package:cardholder/services/card_service.dart';
import 'package:cardholder/services/collection_card_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screen/ocr_screen.dart';
import 'package:camera/camera.dart';
import '../config/config_url.dart';
import '../model/CardHolder.dart';
import '../services/auth_service.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon Cards',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PokemonCardBrowser(),
    );
  }
}

class PokemonCardBrowser extends StatefulWidget {
  @override
  _PokemonCardBrowserState createState() => _PokemonCardBrowserState();
}

class _PokemonCardBrowserState extends State<PokemonCardBrowser> {
  final ApiService _apiService = ApiService();
  final CollectionCardService _collectionService = CollectionCardService();
  final AuthService _authService = AuthService();

  List<PokeCard> databaseCards = [];
  List<CardHolder> userCards = [];
  bool isLoading = true;
  String searchQuery = '';
  String filterOption = 'all';
  bool isSearching = false;

  final Map<String, Image> _imageCache = {};

  static const int cardsPerPage = 12;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      await Future.wait([
        _loadDatabaseCards(),
        _loadUserCollection(),
      ]);
      _precacheImages();
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadDatabaseCards() async {
    final cards = await _apiService.fetchCards();
    setState(() => databaseCards = cards);
  }

  Future<void> _loadUserCollection() async {
    final collection = await _collectionService.getUserCards();
    setState(() => userCards = collection);
  }

  Future<void> _addCardToCollection(PokeCard card) async {
    if (card.id == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await _collectionService.addCardToCollection(card.id!);
      Navigator.pop(context); // Đóng loading dialog

      if (success) {
        // Cập nhật lại danh sách card của user
        await _loadUserCollection();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm thẻ thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể thêm thẻ. Vui lòng thử lại!')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Đóng loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xảy ra lỗi. Vui lòng thử lại!')),
      );
    }
  }


  void _precacheImages() {
    for (var card in [
      ...databaseCards,
      ...userCards.map((ch) => ch.card!).where((card) => card != null)
    ]) {
      if (card.imageUrl != null && card.imageUrl!.isNotEmpty) {
        _imageCache[card.imageUrl!] = Image.network(card.imageUrl!);
        precacheImage(_imageCache[card.imageUrl!]!.image, context);
      }
    }
  }

  void _filterCards(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      currentPage = 0; // Reset lại trang về 0
    });
  }

  List<PokeCard> _getFilteredCards() {
    List<PokeCard> filteredCards = databaseCards
        .where((card) =>
    searchQuery.isEmpty ||
        (card.name?.toLowerCase().contains(searchQuery) ?? false))
        .toList();

    if (filterOption == 'owned') {
      filteredCards = filteredCards
          .where((card) => userCards.any((uc) => uc.card?.id == card.id))
          .toList();
    } else if (filterOption == 'missing') {
      filteredCards = filteredCards
          .where((card) => userCards.every((uc) => uc.card?.id != card.id))
          .toList();
    }

    filteredCards.sort((a, b) => (a.id ?? '').compareTo(b.id ?? ''));
    return filteredCards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm thẻ bài...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black),
          ),
          autofocus: true,
          style: const TextStyle(color: Colors.black),
          onChanged: _filterCards,
        )
            : const Text('Collections'),
        actions: [
          if (isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  isSearching = false;
                  searchQuery = ''; // Xóa dữ liệu tìm kiếm
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() => isSearching = true);
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                filterOption = value;
                currentPage = 0; // Reset lại trang về 0 khi thay đổi bộ lọc
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Tất cả thẻ bài')),
              const PopupMenuItem(value: 'owned', child: Text('Thẻ đã sở hữu')),
              const PopupMenuItem(value: 'missing', child: Text('Thẻ chưa sở hữu')),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: _buildCardGrid(_getFilteredCards()),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onCameraButtonPressed,
          child: const Icon(Icons.camera_alt),
        ),
      );
    }

  Widget _buildCardGrid(List<PokeCard> cards) {
    final int totalPages = (cards.length / cardsPerPage).ceil();
    final int startIndex = currentPage * cardsPerPage;

    if (startIndex >= cards.length) {
      return const Center(child: Text('Không có thẻ bài nào trên trang này'));
    }

    final int endIndex = math.min(startIndex + cardsPerPage, cards.length);
    final List<PokeCard> currentPageCards = cards.sublist(startIndex, endIndex);

    return Column(
      children: [
        Expanded(
          child: currentPageCards.isEmpty
              ? const Center(child: Text('Chưa có thẻ bài nào'))
              : GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: currentPageCards.length,
            itemBuilder: (context, index) =>
                _buildCardItem(currentPageCards[index]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: _buildPagination(totalPages),
        ),
      ],
    );
  }

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 16,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 0 ? () => setState(() => currentPage--) : null,
        ),
        Container(
          height: 24,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _pageButton(0),
              if (currentPage > 2) const Text('...', style: TextStyle(fontSize: 12)),
              if (currentPage > 1) _pageButton(currentPage - 1),
              if (currentPage != 0 && currentPage != totalPages - 1)
                _pageButton(currentPage),
              if (currentPage < totalPages - 2) _pageButton(currentPage + 1),
              if (currentPage < totalPages - 3)
                const Text('...', style: TextStyle(fontSize: 12)),
              if (totalPages > 1) _pageButton(totalPages - 1),
            ],
          ),
        ),
        IconButton(
          iconSize: 16,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages - 1
              ? () => setState(() => currentPage++)
              : null,
        ),
      ],
    );
  }

  Widget _pageButton(int page) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: currentPage == page ? Colors.blue : null,
          foregroundColor: currentPage == page ? Colors.white : Colors.black,
        ),
        onPressed: () => setState(() => currentPage = page),
        child: Text(
          '${page + 1}',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildCardItem(PokeCard card) {
    final String? imageUrl = card.id != null && card.setNum != null
        ? '${Config_URL.imageUrl}/cards/${card.id}/${card.setNum}.jpg'
        : null;

    final bool isOwned = userCards.any((uc) => uc.card?.id == card.id);

    return Card(
      elevation: 4,
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: imageUrl != null
                ? GestureDetector(
              onTap: () => _showFullImageDialog(context, imageUrl),
              child: Opacity(
                opacity: isOwned ? 1.0 : 0.5,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) =>
                  const Center(child: Text('Không có hình ảnh')),
                ),
              ),
            )
                : const Center(child: Text('Không có hình ảnh')),
          ),
          Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.name ?? 'Chưa xác định',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Bộ: ${card.cardSet ?? 'Chưa xác định'}',
                          style: const TextStyle(fontSize: 8),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Độ hiếm: ${card.rarity ?? 'Chưa xác định'}',
                          style: const TextStyle(fontSize: 8),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        onPressed: () => _launchMarketUrl(card.id),
                        icon: const Icon(Icons.shopping_cart, size: 14),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        onPressed: () => _addCardToCollection(card),
                        icon: const Icon(Icons.add_circle_outline, size: 14),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) =>
                const Center(child: Text('Không có hình ảnh')),
              ),
            ),
          ),
        );
      },
    );
  }

  void _launchMarketUrl(String? cardId) async {
    if (cardId == null) return;
    final String url = 'https://prices.pokemontcg.io/cardmarket/$cardId';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn cách mở đường dẫn'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Mở bằng trình duyệt'),
          ),
        ],
      ),
    );
  }

  void _onCameraButtonPressed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn hành động'),
        content: const Text('Bạn muốn mở máy ảnh hay thư viện ảnh?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Đóng dialog
              try {
                final cameras = await availableCameras();

                // Điều hướng tới OCRScreen và nhận cardId
                final cardId = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OCRScreen(cameras: cameras),
                  ),
                );

                // Xử lý sau khi nhận được cardId
                if (cardId != null) {
                  print("Card ID returned from OCR: $cardId");

                  // Gọi addCardToCollection sau khi nhận được cardId
                  await _collectionService.addCardToCollection(cardId);

                  // Hiển thị thông báo thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Card added successfully!')),
                  );

                  // Cập nhật danh sách thẻ
                  await _loadUserCollection();
                }
              } catch (e) {
                print("Error initializing camera or adding card: $e");
              }
            },
            child: const Text('Máy ảnh'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Thêm xử lý mở thư viện ảnh
            },
            child: const Text('Thư viện'),
          ),
        ],
      ),
    );
  }
}
