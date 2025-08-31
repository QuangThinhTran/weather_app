import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchCities extends SearchEvent {
  final String query;

  const SearchCities(this.query);

  @override
  List<Object> get props => [query];
}

class LoadSearchHistory extends SearchEvent {
  const LoadSearchHistory();
}

class ClearSearchHistory extends SearchEvent {
  const ClearSearchHistory();
}

class ClearSearchResults extends SearchEvent {
  const ClearSearchResults();
}