import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/search_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _searchRepository;
  Timer? _debounceTimer;

  SearchBloc({required SearchRepository searchRepository})
      : _searchRepository = searchRepository,
        super(SearchInitial()) {
    
    on<SearchCities>(_onSearchCities);
    on<LoadSearchHistory>(_onLoadSearchHistory);
    on<ClearSearchHistory>(_onClearSearchHistory);
    on<ClearSearchResults>(_onClearSearchResults);
  }

  Future<void> _onSearchCities(
    SearchCities event,
    Emitter<SearchState> emit,
  ) async {
    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    if (event.query.trim().isEmpty) {
      emit(const SearchEmpty());
      return;
    }

    if (event.query.trim().length < 2) {
      return; // Don't search for queries less than 2 characters
    }

    // Emit loading state immediately
    emit(SearchLoading());

    // Await the debounced search instead of using Timer
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (emit.isDone) {
      return;
    }
    
    try {
      final cities = await _searchRepository.searchCities(event.query);
      
      // Check if emitter is still active before emitting
      if (!emit.isDone) {
        if (cities.isEmpty) {
          emit(const SearchEmpty());
        } else {
          emit(SearchLoaded(cities, event.query));
        }
      }
    } catch (e) {
      // Check if emitter is still active before emitting
      if (!emit.isDone) {
        emit(SearchError('Failed to search cities: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadSearchHistory(
    LoadSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final history = await _searchRepository.getSearchHistory();
      emit(SearchHistoryLoaded(history));
    } catch (e) {
      emit(SearchError('Failed to load search history: ${e.toString()}'));
    }
  }

  Future<void> _onClearSearchHistory(
    ClearSearchHistory event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _searchRepository.clearSearchHistory();
      emit(const SearchHistoryLoaded([]));
    } catch (e) {
      emit(SearchError('Failed to clear search history: ${e.toString()}'));
    }
  }

  Future<void> _onClearSearchResults(
    ClearSearchResults event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  // Helper method to add city to search history
  Future<void> addToHistory(String cityName) async {
    try {
      await _searchRepository.addToSearchHistory(cityName);
    } catch (e) {
      // Silently fail - search history is not critical
    }
  }
}