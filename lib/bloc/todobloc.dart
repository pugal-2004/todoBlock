import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo/model/todoModels.dart';

// Events
abstract class TodoEvent {}

class AddTodo extends TodoEvent {
  final String title;
  AddTodo(this.title);
}

class ToggleTodo extends TodoEvent {
  final int id;
  ToggleTodo(this.id);
}

class DeleteTodo extends TodoEvent {
  final int id;
  DeleteTodo(this.id);
}

// Bloc
class TodoBloc extends Bloc<TodoEvent, List<Todo>> {
  int _idCounter = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TodoBloc() : super([]) {
    on<AddTodo>((event, emit) async {
      final newTodo = Todo(id: _idCounter++, title: event.title);

      // Save to Firestore
      await _firestore.collection('todos').add({
        'id': newTodo.id,
        'title': newTodo.title,
        'isCompleted': newTodo.isCompleted,
        'createdAt': FieldValue.serverTimestamp(),
      });

      emit([...state, newTodo]);
    });

    on<ToggleTodo>((event, emit) async {
      final updatedTodos = state.map((todo) {
        if (todo.id == event.id) {
          return todo.copyWith(isCompleted: !todo.isCompleted);
        }
        return todo;
      }).toList();

      // Update Firestore isCompleted status
      final todoToUpdate = updatedTodos.firstWhere((todo) => todo.id == event.id);
      final snapshot = await _firestore
          .collection('todos')
          .where('id', isEqualTo: event.id)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'isCompleted': todoToUpdate.isCompleted});
      }

      emit(updatedTodos);
    });

    on<DeleteTodo>((event, emit) async {
      final updatedTodos = state.where((todo) => todo.id != event.id).toList();

      // Delete from Firestore
      final snapshot = await _firestore
          .collection('todos')
          .where('id', isEqualTo: event.id)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      emit(updatedTodos);
    });
  }
}
