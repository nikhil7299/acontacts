import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Main',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        '/new-contact': (context) => const NewContactView(),
      },
    );
  }
}

class Contact {
  final String id;
  final String name;
  Contact({
    required this.name,
  }) : id = const Uuid().v4();
}

//Singleton class
class ContactBook extends ValueNotifier<List<Contact>> {
  //ValueNotifier needs the value to be passed in constructor
  //Now valuenotifier manages a value of type written after ValueNotifier
  //private constructor
  ContactBook._sharedInstance() : super([]);
  //private object
  static final ContactBook _shared = ContactBook._sharedInstance();
  //factory keyword to implement constructors that do not produce
  //new instances of an existing class.

  factory ContactBook() => _shared;

  // final List<Contact> _contacts = []; No need as ValueNotifier has a value

  // int get length => _contacts.length;
  int get length => value.length;

  void add({required Contact contact}) {
    // _contacts.add(contact);
    // As we changing the internals of value not the value itself
    // so no notifyListener() is called, we can explicity call it or do this:
    final contacts = value;
    contacts.add(contact);
    // value = contacts; no need as both are same
    notifyListeners();

    //OR
    // value.add(contact);
    // notifyListeners();
  }

  void remove({required Contact contact}) {
    // _contacts.remove(contact);
    // value.remove(contact);
    final contacts = value;
    if (contacts.contains(contact)) {
      contacts.remove(contact);
      // value = contacts;
      notifyListeners();
    }
  }

  Contact? contact({required int atIndex}) =>
      // _contacts.length > atIndex ? _contacts[atIndex] : null;
      value.length > atIndex ? value[atIndex] : null;
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final contactBook = ContactBook();
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Book"),
      ),
      body: ValueListenableBuilder(
          valueListenable: ContactBook(),
          builder: (context, value, child) {
            final contacts = value as List<Contact>;
            return ListView.builder(
              // itemCount: contactBook.length,
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                // final contact = contactBook.contact(atIndex: index)!;
                final contact = contacts[index];
                return Dismissible(
                  onDismissed: (direction) {
                    // contacts.remove(contact);
                    ContactBook().remove(contact: contact);
                  },
                  key: ValueKey(contact.id),
                  child: Material(
                    color: Colors.white,
                    elevation: 6.0,
                    child: ListTile(
                      title: Text(contact.name),
                    ),
                  ),
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed('/new-contact');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class NewContactView extends StatefulWidget {
  const NewContactView({super.key});

  @override
  State<NewContactView> createState() => _NewContactViewState();
}

class _NewContactViewState extends State<NewContactView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a new contact"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter a new contact name here..',
            ),
          ),
          TextButton(
            onPressed: () {
              final contact = Contact(name: _controller.text);
              ContactBook().add(contact: contact);
              Navigator.of(context).pop();
            },
            child: Text(
              'Add contact',
            ),
          ),
        ],
      ),
    );
  }
}
