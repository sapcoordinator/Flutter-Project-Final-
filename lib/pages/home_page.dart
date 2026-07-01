import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_page2/bloc/user/user_bloc.dart';
import 'package:login_page2/bloc/user/user_event.dart';
import 'package:login_page2/bloc/user/user_state.dart';
import 'package:login_page2/models/api_user_model.dart';
// import '../models/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  ApiUserModel? deletedUser;
  int? deletedIndex;

  @override
  void initState() {
    super.initState();

    context.read<UserBloc>().add(const LoadUsers());
    scrollController.addListener(() {

  if (scrollController.position.pixels >=
      scrollController.position.maxScrollExtent - 100) {

    context.read<UserBloc>().add(
      const LoadMoreUsers(),
    );
  }
});
  }

  @override
void dispose() {
  searchController.dispose();
  scrollController.dispose();
  super.dispose();
}

  void showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final companyController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: companyController,
              decoration: const InputDecoration(labelText: "Company"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final user = ApiUserModel(
                id: DateTime.now().millisecondsSinceEpoch,
                name: nameController.text,
                email: emailController.text,
                company: companyController.text,
                username: "",
                address: "",
                zip: "",
                state: "",
                country: "",
                phone: "",
                photo: "https://i.pravatar.cc/150?img=1",
              );

              context.read<UserBloc>().add(AddUser(user));

              Navigator.pop(context);
            },
            child: const Text("Add User"),
          ),
        ],
      ),
    );
  }

  void showEditUserDialog(ApiUserModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final companyController = TextEditingController(text: user.company);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: companyController,
              decoration: const InputDecoration(labelText: "Company"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedUser = ApiUserModel(
                id: user.id,
                name: nameController.text,
                email: emailController.text,
                company: companyController.text,
                username: user.username,
                address: user.address,
                zip: user.zip,
                state: user.state,
                country: user.country,
                phone: user.phone,
                photo: user.photo,
              );

              context.read<UserBloc>().add(UpdateUser(updatedUser));

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<bool?> showDeleteDialog(ApiUserModel user) async {
    deletedUser = user;

    final state = context.read<UserBloc>().state;

    if (state is UserLoaded) {
      deletedIndex = state.users.indexWhere((u) => u.id == user.id);
    }

    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Delete ${user.name} ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () {
              context.read<UserBloc>().add(DeleteUser(user.id));

              Navigator.pop(context, true);

              showUndoSnackBar();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void showUndoSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("User deleted"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            if (deletedUser != null) {
              context.read<UserBloc>().add(AddUser(deletedUser!));
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Repository",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 80, 58, 161),
        // centerTitle: true,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,

              decoration: InputDecoration(
                hintText: "Search by name or email",
                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onChanged: (value) {
                context.read<UserBloc>().add(SearchUsers(value));
              },
            ),
          ),

          Expanded(
  child: RefreshIndicator(
    onRefresh: () async {
      context.read<UserBloc>().add(
        const LoadUsers(),
      );

      // Small delay so the refresh animation is visible
      await Future.delayed(
        const Duration(milliseconds: 700),
      );
    },

    child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is UserLoaded) {
                  if (state.users.isEmpty) {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off,
          size: 80,
          color: Colors.grey,
        ),
        SizedBox(height: 20),
        Text(
          "No users found",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Try another search",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];

                      return Dismissible(
                        key: ValueKey(user.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),

                        confirmDismiss: (_) async {
                          return await showDeleteDialog(user);
                        },

                        child: Card(
                          margin: const EdgeInsets.all(10),

                          child: ListTile(
                            onTap: () {
                              showEditUserDialog(user);
                            },

                            leading: CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(user.photo),
                            ),

                            title: Text(user.name),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(user.email),
                                Text(user.company),
                                Text(user.phone),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                if (state is UserError) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        const Icon(
          Icons.cloud_off,
          size: 80,
          color: Colors.red,
        ),

        const SizedBox(height: 20),

        const Text(
          "Unable to load users",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          state.message,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 25),

        ElevatedButton.icon(
          onPressed: () {
            context.read<UserBloc>().add(
              const LoadUsers(),
            );
          },
          icon: const Icon(Icons.refresh),
          label: const Text("Retry"),
        ),
      ],
    ),
  );
}

                return const SizedBox();
              },
            ),
          ),
          ),
        ],
      ),

      // ➕ Floating button
      floatingActionButton: FloatingActionButton(
        onPressed: showAddUserDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../bloc/user/user_bloc.dart';
// import '../bloc/user/user_event.dart';
// import '../bloc/user/user_state.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {

//   @override
//   void initState() {
//     super.initState();

//     context.read<UserBloc>().add(const LoadUsers());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Users"),
//       ),

//       body: BlocBuilder<UserBloc, UserState>(
//         builder: (context, state) {

//           if (state is UserLoading) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           if (state is UserLoaded) {
//             return ListView.builder(
//               itemCount: state.users.length,

//               itemBuilder: (context, index) {

//                 final user = state.users[index];

//                 return Card(
//                   margin: const EdgeInsets.all(10),

//                   child: ListTile(

//                     leading: CircleAvatar(
//                       radius: 28,
//                       backgroundImage:
//                           NetworkImage(user.photo),
//                     ),

//                     title: Text(user.name),

//                     subtitle: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,

//                       children: [

//                         Text(user.email),

//                         Text(user.company),

//                         Text(user.phone),

//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           }

//           if (state is UserError) {
//             return Center(
//               child: Text(state.message),
//             );
//           }

//           return const SizedBox();
//         },
//       ),
//     );
//   }
// }
