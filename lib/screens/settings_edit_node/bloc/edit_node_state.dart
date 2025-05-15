part of 'edit_node_cubit.dart';

final class EditNodeState {
  const EditNodeState({this.isSaving = false, this.node});

  final bool isSaving;
  final Node? node;

  EditNodeState copyWith({
    bool? isSaving,
    Node? node,
  }) =>
      EditNodeState(
        isSaving: isSaving ?? this.isSaving,
        node: node ?? this.node,
      );
}
