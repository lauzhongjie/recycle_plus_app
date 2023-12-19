part of 'r_category_cubit.dart';

abstract class RCategoryState extends Equatable {
  const RCategoryState();

  @override
  List<Object> get props => [];
}

class RCategoryStateInitial extends RCategoryState {}

class RCategoryStateLoading extends RCategoryState {}

class RCategoryStateSuccess extends RCategoryState {
  final List<RCategoryEntity> categories;

  const RCategoryStateSuccess(this.categories);

  @override
  List<Object> get props => [categories];
}

class RCategoryStateError extends RCategoryState {
  final String message;

  const RCategoryStateError(this.message);

  @override
  List<Object> get props => [message];
}

class RCategoryItemStateSuccess extends RCategoryState {
  final List<RCategoryItemEntity> items;

  const RCategoryItemStateSuccess(this.items);

  @override
  List<Object> get props => [items];
}