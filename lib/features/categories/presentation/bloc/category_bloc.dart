import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';
import 'package:pocketree/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:pocketree/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:pocketree/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:pocketree/features/categories/domain/usecases/update_category_usecase.dart';
import 'package:pocketree/features/categories/presentation/bloc/category_event.dart';
import 'package:pocketree/features/categories/presentation/bloc/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategories;
  final CreateCategoryUseCase createCategory;
  final UpdateCategoryUseCase updateCategory;
  final DeleteCategoryUseCase deleteCategory;

  CategoryBloc({
    required this.getCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
  }) : super(const CategoryInitial()) {
    on<CategoryDataRequested>(_onDataRequested);
    on<CategoryCreateRequested>(_onCreateRequested);
    on<CategoryUpdateRequested>(_onUpdateRequested);
    on<CategoryDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onDataRequested(
    CategoryDataRequested event,
    Emitter<CategoryState> emit,
  ) async {
    if (state is! CategoryLoaded) {
      emit(const CategoryLoading());
    }

    final result = await getCategories(type: event.type);

    result.fold(
      (failure) => emit(CategoryError(_mapFailureToMessage(failure))),
      (categories) => emit(CategoryLoaded(
        categories: categories,
        activeFilter: event.type,
      )),
    );
  }

  Future<void> _onCreateRequested(
    CategoryCreateRequested event,
    Emitter<CategoryState> emit,
  ) async {
    final currentFilter = _currentFilter;

    if (state is CategoryLoaded) {
      emit((state as CategoryLoaded).copyWith(isPerformingAction: true));
    }

    final result = await createCategory(
      name: event.name,
      type: event.type,
      icon: event.icon,
      color: event.color,
      parentId: event.parentId,
    );

    result.fold(
      (failure) => emit(CategoryError(_mapFailureToMessage(failure))),
      (_) {
        emit(const CategoryActionSuccess('Category created successfully'));
        add(CategoryDataRequested(type: currentFilter));
      },
    );
  }

  Future<void> _onUpdateRequested(
    CategoryUpdateRequested event,
    Emitter<CategoryState> emit,
  ) async {
    final currentFilter = _currentFilter;

    if (state is CategoryLoaded) {
      emit((state as CategoryLoaded).copyWith(isPerformingAction: true));
    }

    final result = await updateCategory(
      categoryId: event.categoryId,
      name: event.name,
      icon: event.icon,
      color: event.color,
    );

    result.fold(
      (failure) => emit(CategoryError(_mapFailureToMessage(failure))),
      (_) {
        emit(const CategoryActionSuccess('Category updated successfully'));
        add(CategoryDataRequested(type: currentFilter));
      },
    );
  }

  Future<void> _onDeleteRequested(
    CategoryDeleteRequested event,
    Emitter<CategoryState> emit,
  ) async {
    final currentFilter = _currentFilter;

    if (state is CategoryLoaded) {
      emit((state as CategoryLoaded).copyWith(isPerformingAction: true));
    }

    final result = await deleteCategory(event.categoryId);

    result.fold(
      (failure) => emit(CategoryError(_mapFailureToMessage(failure))),
      (_) {
        emit(const CategoryActionSuccess('Category deleted successfully'));
        add(CategoryDataRequested(type: currentFilter));
      },
    );
  }

  CategoryType? get _currentFilter {
    final current = state;
    return current is CategoryLoaded ? current.activeFilter : null;
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure f => f.message,
      NetworkFailure _ =>
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      UnauthorizedFailure _ => failure.message,
      CacheFailure _ => 'Terjadi kesalahan lokal. Silakan coba lagi.',
    };
  }
}