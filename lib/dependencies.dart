import 'package:flutter/foundation.dart';
import 'package:beetask/data/dao/dao.dart';
import 'package:beetask/data/repository/todo_repository.dart';
import 'package:beetask/domain/interactor/todo_interactor.dart';

class Dependencies {
  final TodoInteractor todoInteractor;

  const Dependencies({
    @required this.todoInteractor,
  });

  static Dependencies standard() {
    final dao = Dao();
    final todoRepository = TodoRepository(dao: dao.todoDao);

    return Dependencies(
      todoInteractor: TodoInteractor(todoRepository: todoRepository),
    );
  }
}
