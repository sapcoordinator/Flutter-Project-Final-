import 'package:flutter/material.dart';
import '../models/user_model.dart';

class HomePage extends StatefulWidget {
  final List<UserModel> users;

  const HomePage({super.key, required this.users});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Repository", 
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),),
        backgroundColor:  Color.fromARGB(255, 80, 58, 161),
        // centerTitle: true,
      ),
      
      body: widget.users.isEmpty
          ? const Center(
              child: Text(
                "No users found",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.users.length,
              itemBuilder: (context, index) {
                final user = widget.users[index];

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),

                    // 👤 Avatar
                    leading: CircleAvatar(
                      radius: 25,
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),

                    // 📄 Name
                    title: Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    // 📧 Email
                    subtitle: Text(user.email),

                    // 👉 Action Icon
                    trailing: const Icon(Icons.arrow_forward_ios),

                    // 👆 Tap interaction
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Clicked ${user.name}")),
                      );
                    },
                  ),
                );
              },
            ),

      // ➕ Floating button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // go back to form
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}