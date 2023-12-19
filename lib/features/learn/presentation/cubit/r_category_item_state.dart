part of 'r_category_item_cubit.dart';

abstract class RCategoryItemState extends Equatable {
  const RCategoryItemState();

  @override
  List<Object?> get props => [];
}

class RCategoryItemInitial extends RCategoryItemState {}

class RCategoryItemLoading extends RCategoryItemState {}

class RCategoryItemSuccess extends RCategoryItemState {
  final List<RCategoryItemEntity> items;

  const RCategoryItemSuccess(this.items);

  @override
  List<Object?> get props => [items];
}

class RCategoryItemError extends RCategoryItemState {
  final String message;

  const RCategoryItemError(this.message);

  @override
  List<Object?> get props => [message];
}
