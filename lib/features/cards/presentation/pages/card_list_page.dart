import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game/injection.dart';
import 'package:game/router.dart';
import 'package:game/features/cards/domain/entities/card.dart' as yugi;
import '../bloc/card_bloc.dart';
import '../widgets/card_list_item.dart';

@RoutePage()
class CardListPage extends StatefulWidget {
  const CardListPage({super.key});

  @override
  State<CardListPage> createState() => _CardListPageState();
}

class _CardListPageState extends State<CardListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<yugi.Card> _filterCards(List<yugi.Card> cards) {
    return cards.where((card) {
      // กรองตามชื่อการ์ด
      final matchesSearch =
          _searchQuery.isEmpty ||
          card.name.toLowerCase().contains(_searchQuery.toLowerCase());

      // กรองตามประเภทการ์ด
      bool matchesType = true;
      if (_selectedType != null && _selectedType != 'ทั้งหมด') {
        final cardType = card.type?.toLowerCase() ?? '';
        final selectedType = _selectedType!.toLowerCase();

        // ตรวจสอบประเภทการ์ด (รองรับหลายรูปแบบจาก API)
        if (selectedType == 'monster') {
          matchesType = cardType.contains('monster');
        } else if (selectedType == 'spell') {
          matchesType = cardType.contains('spell');
        } else if (selectedType == 'trap') {
          matchesType = cardType.contains('trap');
        } else {
          matchesType = cardType.contains(selectedType);
        }
      }

      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CardBloc>()..add(const LoadCards()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('คลังการ์ด'),
          backgroundColor: const Color(0xFF1a237e),
          foregroundColor: Colors.amber,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<CardBloc>().add(const RefreshCards());
              },
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () {
                context.router.push(const ScanRoute());
              },
            ),
          ],
        ),
        body: BlocBuilder<CardBloc, CardState>(
          builder: (context, state) {
            if (state is CardLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text(
                      'กำลังโหลดการ์ด...',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is CardLoaded) {
              final filteredCards = _filterCards(state.cards);
              return Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'ค้นหาการ์ด...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  // Card Type Filter
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['ทั้งหมด', 'Monster', 'Spell', 'Trap'].map((
                          type,
                        ) {
                          final isSelected =
                              _selectedType == type ||
                              (type == 'ทั้งหมด' && _selectedType == null);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(type),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedType = selected ? type : null;
                                  if (type == 'ทั้งหมด') {
                                    _selectedType = null;
                                  }
                                });
                              },
                              selectedColor: const Color(0xFF1a237e),
                              backgroundColor: Colors.grey[800],
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.amber
                                    : Colors.grey[600]!,
                                width: isSelected ? 2 : 1,
                              ),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.amber : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  // Results Count - Show both total and filtered
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ทั้งหมด ${state.cards.length} ใบ',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'แสดง ${filteredCards.length} ใบ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Cards Grid
                  Expanded(
                    child: filteredCards.isEmpty
                        ? const Center(
                            child: Text(
                              'ไม่พบการ์ด',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemCount: filteredCards.length,
                            itemBuilder: (context, index) {
                              final card = filteredCards[index];
                              return CardListItem(card: card);
                            },
                          ),
                  ),
                ],
              );
            } else if (state is CardError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('กดรีเฟรชเพื่อโหลดการ์ด'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.router.push(const MainMenuRoute());
          },
          child: const Icon(Icons.home),
        ),
      ),
    );
  }
}
