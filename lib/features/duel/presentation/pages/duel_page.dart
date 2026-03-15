import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game/injection.dart';
import 'package:game/features/duel/duel_bloc.dart';

@RoutePage()
class DuelPage extends StatelessWidget {
  const DuelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DuelBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Duel'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Reset duel
              },
            ),
          ],
        ),
        body: BlocBuilder<DuelBloc, DuelState>(
          builder: (context, state) {
            if (state is DuelInitial) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Start duel with sample decks
                    context.read<DuelBloc>().add(
                      const StartDuel(playerDeck: [], enemyDeck: []),
                    );
                  },
                  child: const Text('Start Duel'),
                ),
              );
            } else if (state is DuelInProgress) {
              return Column(
                children: [
                  // Enemy LP
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.red[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Enemy LP: ',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          '${state.enemyLP}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Turn indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Turn ${state.turn} - ${state.playerTurn ? "Your Turn" : "Enemy Turn"}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const Spacer(),
                  // Player LP
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Your LP: ', style: TextStyle(fontSize: 20)),
                        Text(
                          '${state.playerLP}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: state.playerTurn
                              ? () => context.read<DuelBloc>().add(
                                  const Attack(1000),
                                )
                              : null,
                          child: const Text('Attack'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<DuelBloc>().add(const NextTurn()),
                          child: const Text('End Turn'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is DuelEnded) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${state.winner} Wins!',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DuelBloc>().add(const EndDuel());
                      },
                      child: const Text('Back to Menu'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
