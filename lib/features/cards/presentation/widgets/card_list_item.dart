import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:game/features/cards/domain/entities/card.dart' as yugi;
import 'package:game/router.dart';

class CardListItem extends StatelessWidget {
  final yugi.Card card;

  const CardListItem({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.router.push(CardDetailRoute(card: card));
      },
      child: Hero(
        tag: 'card-${card.id}',
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: card.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: card.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // แสดงประเภทการ์ด
                    if (card.type != null)
                      Text(
                        card.type!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    // แสดงพลังโจมตี/ป้องกันเฉพาะมอนสเตอร์
                    if (card.isMonsterCard)
                      Text(
                        'พลังโจมตี: ${card.atk} | พลังป้องกัน: ${card.def}',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
