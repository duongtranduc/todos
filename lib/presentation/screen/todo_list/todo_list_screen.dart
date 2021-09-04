import 'package:beetask/domain/entity/tags.dart';
import 'package:beetask/domain/entity/todo_entity.dart';
import 'package:beetask/presentation/colorful_app.dart';
import 'package:beetask/presentation/screen/archive_list/archive_list_screen.dart';
import 'package:beetask/presentation/screen/todo_detail/todo_detail_screen.dart';
import 'package:beetask/presentation/screen/todo_list/todo_list_actions.dart';
import 'package:beetask/presentation/shared/widgets/box_decoration.dart';
import 'package:beetask/presentation/shared/widgets/dismissible.dart';
import 'package:beetask/presentation/shared/widgets/dropdown.dart' as CustomDropdown;
import 'package:beetask/presentation/shared/widgets/label.dart';
import 'package:beetask/presentation/shared/widgets/todo_adder.dart';
import 'package:beetask/presentation/shared/widgets/todo_tile.dart';
import 'package:beetask/utils/notification_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:beetask/presentation/screen/calendar/calendar_screen.dart';

import 'todo_list_bloc.dart';
import 'todo_list_state.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // Place variables here
  TodoListBloc _bloc;
  TextEditingController _todoNameController;
  ScrollController _listScrollController;

  @override
  void initState() {
    super.initState();
    _bloc = TodoListBloc();
    _todoNameController = TextEditingController();
    _listScrollController = ScrollController();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  // Place methods here
  void _archiveTodo(TodoEntity todo) {
    cancelNotification(todo);
    _bloc.actions.add(PerformOnTodo(operation: Operation.archive, todo: todo));
  }

  void _addTodo(TodoEntity todo) {
    _bloc.actions.add(PerformOnTodo(operation: Operation.add, todo: todo));

    // Auto-scrolls to bottom of the ListView
    if (todo.name.trim().isNotEmpty) {
      // Because sometimes last item is skipped (see below)
      final lastItemExtent = 60.0;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        _listScrollController.animateTo(
          _listScrollController.position.maxScrollExtent + lastItemExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _favoriteTodo(TodoEntity todo) {
    _bloc.actions.add(PerformOnTodo(operation: Operation.favorite, todo: todo));
  }

  void _showDetails(TodoEntity todo) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TodoDetailScreen(todo: todo, editable: true),
    ));
  }

  void _showArchive() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ArchiveListScreen(),
    ));
  }

  void _showCalendarList() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CalendarScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: _bloc.initialState,
      stream: _bloc.state,
      builder: (context, snapshot) {
        return _buildUI(snapshot.data);
      },
    );
  }

  Widget _buildUI(TodoListState state) {
    // Build your root view here
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: ColorfulApp.of(context).colors.dark),
        title: Text('All Jobs'),
        centerTitle: true,
        bottom: _buildFilter(state),
        leading: IconButton(
          onPressed: _showCalendarList,
          icon: Icon(Icons.event_note),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.trash),
            tooltip: 'Archive',
            onPressed: _showArchive,
          ),
        ],
      ),
      body: SafeArea(top: true, bottom: true, child: _buildBody(state)),
    );
  }

  Widget _buildFilter(TodoListState state) {
    final filters = presetTags.toList();
    filters.insertAll(0, ['All', 'Favorite']);

    return PreferredSize(
      preferredSize: const Size.fromHeight(40.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text('Filter by:'),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: roundedShape(context),
                child: CustomDropdown.DropdownButtonHideUnderline(
                  child: CustomDropdown.DropdownButton<String>(
                    isDense: true,
                    value: state.filter,
                    items: filters
                        .map((f) => CustomDropdown.DropdownMenuItem<String>(
                              child: Text(f),
                              value: f,
                            ))
                        .toList(),
                    onChanged: (filter) => _bloc.actions.add(FilterBy(filter: filter)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(TodoListState state) {
    return Container(
      decoration: BoxDecoration(gradient: ColorfulApp.of(context).colors.brightGradient),
      child: Column(
        children: <Widget>[
          Expanded(
            child: state.todos.length == 0
                ? Center(
                    child: SingleChildScrollView(
                      child: buildCentralLabel(text: 'Job list is empty!', context: context),
                    ),
                  )
                : ListView.builder(
                    controller: _listScrollController,
                    itemCount: state.todos.length,
                    itemBuilder: (context, index) {
                      final todo = state.todos[index];
                      return Dismissible(
                        key: Key(todo.addedDate.toIso8601String()),
                        background: buildDismissibleBackground(context: context, leftToRight: true),
                        secondaryBackground: buildDismissibleBackground(context: context, leftToRight: false),
                        onDismissed: (_) => _archiveTodo(todo),
                        child: TodoTile(
                          todo: todo,
                          onTileTap: () => _showDetails(todo),
                          onFavoriteTap: () => _favoriteTodo(todo),
                        ),
                      );
                    },
                  ),
          ),
          TodoAdder(
            onAdd: _addTodo,
            showError: state.todoNameHasError,
            todoNameController: _todoNameController,
          ),
        ],
      ),
    );
  }
}

// For disabling scroll 'glow'. Wrap the `ListView` with `ScrollConfiguration`
//----------
// class _NoHighlightBehavior extends ScrollBehavior {
//   @override
//   Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
//     return child;
//   }
// }
