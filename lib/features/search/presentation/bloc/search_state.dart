import 'package:equatable/equatable.dart';
import '../../domain/entities/city.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<City> cities;
  final String query;

  const SearchLoaded(this.cities, this.query);

  @override
  List<Object> get props => [cities, query];
}

class SearchHistoryLoaded extends SearchState {
  final List<String> history;

  const SearchHistoryLoaded(this.history);

  @override
  List<Object> get props => [history];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}

class SearchEmpty extends SearchState {
  const SearchEmpty();
}