import 'package:flutter/material.dart';
// Importa las páginas placeholder (ajusta los imports según tu estructura real)
import 'package:vecigest/presentation/chat/thread_list_page.dart'; // Changed import
import 'package:vecigest/presentation/incidents/incident_list_page.dart'; // Corrected path
import 'package:vecigest/presentation/documents/doc_list_page.dart'; // Corrected path
import 'package:vecigest/presentation/polls/poll_list_page.dart'; // Corrected path

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ThreadListPage(), // Changed to ThreadListPage
    IncidentListPage(),
    DocListPage(),
    PollListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Incidencias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Documentos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.poll), label: 'Encuestas'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
