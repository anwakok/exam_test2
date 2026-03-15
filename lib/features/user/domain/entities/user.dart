import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String? email;
  final String? password;
  final int totalGames;
  final int bestTime; // in seconds
  final int bestMoves; // minimum moves
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    this.email,
    this.password,
    this.totalGames = 0,
    this.bestTime = 999999,
    this.bestMoves = 999999,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    int? totalGames,
    int? bestTime,
    int? bestMoves,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      totalGames: totalGames ?? this.totalGames,
      bestTime: bestTime ?? this.bestTime,
      bestMoves: bestMoves ?? this.bestMoves,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'password': password,
    'totalGames': totalGames,
    'bestTime': bestTime,
    'bestMoves': bestMoves,
    'createdAt': createdAt.toIso8601String(),
  };

  static User fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    username: json['username'],
    email: json['email'],
    password: json['password'],
    totalGames: json['totalGames'] ?? 0,
    bestTime: json['bestTime'] ?? 999999,
    bestMoves: json['bestMoves'] ?? 999999,
    createdAt: DateTime.parse(json['createdAt']),
  );

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    password,
    totalGames,
    bestTime,
    bestMoves,
    createdAt,
  ];
}
