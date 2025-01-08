import 'package:flutter/material.dart';
import 'package:cardholder/model/PokeCard.dart'; // Import model PokeCard

class PokemonCardDetailPage extends StatelessWidget {
  final PokeCard card;

  PokemonCardDetailPage({required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card.name ?? 'Chi tiết thẻ bài'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: card.imageUrl != null
                    ? Image.network(
                  card.imageUrl!,
                  height: 200,
                  fit: BoxFit.contain,
                )
                    : const Text('Không có hình ảnh'),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Tên:', card.name),
              _buildDetailRow('Bộ:', card.cardSet),
              _buildDetailRow('Series:', card.series),
              _buildDetailRow('Thế hệ:', card.generation),
              _buildDetailRow(
                'Ngày phát hành:',
                card.releaseDate != null
                    ? '${card.releaseDate!.day}/${card.releaseDate!.month}/${card.releaseDate!.year}'
                    : 'Chưa xác định',
              ),
              _buildDetailRow('Số lượng:', card.setNum),
              _buildDetailRow('Loại:', card.types),
              _buildDetailRow('Supertype:', card.supertype),
              _buildDetailRow('HP:', card.hp?.toString()),
              _buildDetailRow('Tiến hóa từ:', card.evolvesfrom),
              _buildDetailRow('Tiến hóa tới:', card.evolvesto),
              _buildDetailRow('Độ hiếm:', card.rarity),
              const SizedBox(height: 16),
              const Text(
                'Mô tả:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                card.flavortext ?? 'Không có mô tả',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$title ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value ?? 'Chưa xác định',
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
